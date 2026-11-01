"""Unified Swiss tariff provider adapter with server-side caching.

Fetches from CKW, Groupe E, Primeo (all public SmartGridready APIs).
Results are cached in memory for 15 minutes to avoid rate-limiting.
"""

import time
from datetime import datetime
from decimal import Decimal
from typing import Any

import httpx

from app.core.logging import logger
from app.integrations.providers.base import (
    Component,
    LicenseStatus,
    PriceInterval,
    ProviderAdapter,
)

PROVIDER_ENDPOINTS = {
    "ckw": {
        "url": "https://e-ckw-public-data.de-c1.eu1.cloudhub.io/api/v1/netzinformationen/energie/dynamische-preise",
        "name": "CKW",
        "full_name": "Centralschweizerische Kraftwerke",
        "territory": "Luzern / Zentralschweiz",
        "color": "#0d9488",
    },
    "groupe-e": {
        "url": "https://api.tariffs.groupe-e.ch/v2/tariffs/",
        "name": "Groupe E",
        "full_name": "Groupe E VARIO",
        "territory": "Fribourg / Westschweiz",
        "color": "#2563eb",
    },
    "primeo": {
        "url": "https://tarife.primeo-energie.ch/api/v1/tariffs",
        "name": "Primeo",
        "full_name": "Primeo Energie (NetzDynamisch)",
        "territory": "Basel / Nordwestschweiz",
        "color": "#7c3aed",
    },
}

# In-memory cache: {provider_id: (timestamp, raw_json)}
_cache: dict[str, tuple[float, dict[str, Any]]] = {}
CACHE_TTL = 900  # 15 minutes


async def _fetch_raw(provider_id: str) -> dict[str, Any] | None:
    """Fetch raw JSON from a provider, with 15-minute caching."""
    now = time.time()
    if provider_id in _cache:
        ts, data = _cache[provider_id]
        if now - ts < CACHE_TTL:
            return data

    url = PROVIDER_ENDPOINTS[provider_id]["url"]
    try:
        async with httpx.AsyncClient(timeout=15.0) as client:
            response = await client.get(url)
            response.raise_for_status()
            data = response.json()
            _cache[provider_id] = (now, data)
            logger.info("Fetched %d intervals from %s", len(data.get("prices", [])), provider_id)
            return data
    except Exception as e:
        logger.error("Failed to fetch from %s: %s", provider_id, e)
        # Return stale cache if available
        if provider_id in _cache:
            return _cache[provider_id][1]
        return None


def _parse_intervals(data: dict, provider_id: str) -> list[PriceInterval]:
    """Parse the common SmartGridready-style response into PriceIntervals."""
    prices = data.get("prices", [])
    intervals: list[PriceInterval] = []

    for entry in prices:
        start = datetime.fromisoformat(entry["start_timestamp"])
        end = datetime.fromisoformat(entry["end_timestamp"])
        source_id = f"{provider_id}-{start.date()}"

        if "integrated" in entry and entry["integrated"]:
            val = entry["integrated"][0]["value"]
            intervals.append(PriceInterval(
                start_utc=start, end_utc=end,
                component=Component.ENERGY,
                chf_per_kwh=Decimal(str(val)),
                tax_included=True,
                quality="ACTUAL",
                source_id=source_id,
            ))

        if "grid" in entry and entry["grid"]:
            val = entry["grid"][0]["value"]
            intervals.append(PriceInterval(
                start_utc=start, end_utc=end,
                component=Component.GRID_USAGE,
                chf_per_kwh=Decimal(str(val)),
                tax_included=False,
                quality="ACTUAL",
                source_id=source_id,
            ))

    return intervals


class SwissTariffAdapter(ProviderAdapter):
    """Adapter that fetches real prices from any of the three Swiss providers."""

    license_status = LicenseStatus.APPROVED_PUBLIC

    def __init__(self, provider_id: str = "ckw"):
        if provider_id not in PROVIDER_ENDPOINTS:
            raise ValueError(f"Unknown provider: {provider_id}")
        self._config = PROVIDER_ENDPOINTS[provider_id]
        self.provider_id = provider_id
        self.provider_name = self._config["name"]

    async def fetch(
        self, product_id: str, start_utc: datetime, end_utc: datetime
    ) -> list[PriceInterval]:
        data = await _fetch_raw(self.provider_id)
        if not data:
            return []
        intervals = _parse_intervals(data, self.provider_id)
        return sorted(intervals, key=lambda i: (i.start_utc, i.component.value))

    async def health(self) -> dict:
        data = await _fetch_raw(self.provider_id)
        if data:
            count = len(data.get("prices", []))
            return {
                "status": "ok" if count > 0 else "degraded",
                "provider": self.provider_id,
                "name": self._config["full_name"],
                "intervals": count,
                "publication": data.get("publication_timestamp"),
            }
        return {"status": "error", "provider": self.provider_id, "error": "unreachable"}


async def fetch_all_raw() -> dict[str, dict[str, Any] | None]:
    """Fetch raw data from all providers (cached)."""
    results = {}
    for pid in PROVIDER_ENDPOINTS:
        results[pid] = await _fetch_raw(pid)
    return results


async def get_all_providers_response() -> dict:
    """Build the full provider comparison response for the frontend."""
    raw = await fetch_all_raw()
    providers = []

    for pid, config in PROVIDER_ENDPOINTS.items():
        data = raw.get(pid)
        if not data or not data.get("prices"):
            providers.append({
                "id": pid,
                "name": config["name"],
                "full_name": config["full_name"],
                "territory": config["territory"],
                "color": config["color"],
                "status": "unavailable",
                "publication": None,
                "interval_count": 0,
                "prices": [],
            })
            continue

        prices = data["prices"]
        provider_prices = []
        for p in prices:
            ts = p["start_timestamp"]
            integrated = p.get("integrated", [{}])[0].get("value", 0) if p.get("integrated") else 0
            grid = p.get("grid", [{}])[0].get("value", 0) if p.get("grid") else 0
            electricity = p.get("electricity", [{}])[0].get("value", 0) if p.get("electricity") else 0
            provider_prices.append({
                "start": ts,
                "end": p["end_timestamp"],
                "integrated": integrated,
                "grid": grid,
                "electricity": electricity,
            })

        int_vals = [pp["integrated"] for pp in provider_prices]
        grid_vals = [pp["grid"] for pp in provider_prices]

        providers.append({
            "id": pid,
            "name": config["name"],
            "full_name": config["full_name"],
            "territory": config["territory"],
            "color": config["color"],
            "status": "ok",
            "publication": data.get("publication_timestamp"),
            "tariff_name": data.get("tariff_name"),
            "interval_count": len(prices),
            "summary": {
                "integrated_min": min(int_vals) if int_vals else 0,
                "integrated_max": max(int_vals) if int_vals else 0,
                "integrated_avg": sum(int_vals) / len(int_vals) if int_vals else 0,
                "grid_min": min(grid_vals) if grid_vals else 0,
                "grid_max": max(grid_vals) if grid_vals else 0,
                "grid_avg": sum(grid_vals) / len(grid_vals) if grid_vals else 0,
            },
            "prices": provider_prices,
        })

    return {"providers": providers}
