"""Groupe E VARIO dynamic tariff adapter.

Endpoint: https://api.tariffs.groupe-e.ch/v2/tariffs/
Resolution: 15-minute intervals
Publication: Day-ahead by ~18:00 CET/CEST

Status: NEEDS_ACCESS — Azure API management token/subscription required.
"""

from datetime import datetime
from decimal import Decimal

import httpx

from app.core.config import settings
from app.integrations.providers.base import (
    Component,
    LicenseStatus,
    PriceInterval,
    ProviderAdapter,
)


class GroupeEAdapter(ProviderAdapter):
    provider_id = "groupe-e"
    provider_name = "Groupe E VARIO"
    license_status = LicenseStatus.NEEDS_ACCESS

    BASE_URL = settings.groupe_e_api_base_url

    async def fetch(
        self, product_id: str, start_utc: datetime, end_utc: datetime
    ) -> list[PriceInterval]:
        url = f"{self.BASE_URL}/tariffs/"
        headers = {}
        if settings.groupe_e_api_key:
            headers["Ocp-Apim-Subscription-Key"] = settings.groupe_e_api_key

        params = {
            "date": start_utc.strftime("%Y-%m-%d"),
        }

        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.get(url, params=params, headers=headers)
            response.raise_for_status()
            data = response.json()

        intervals = []
        entries = data if isinstance(data, list) else data.get("intervals", [])
        for entry in entries:
            intervals.append(
                PriceInterval(
                    start_utc=datetime.fromisoformat(entry["start"]),
                    end_utc=datetime.fromisoformat(entry["end"]),
                    component=Component.ENERGY,
                    chf_per_kwh=Decimal(str(entry.get("price_chf_per_kwh", entry.get("price", 0)))),
                    tax_included=entry.get("tax_included", True),
                    quality="ACTUAL",
                    source_id=f"groupe-e-{start_utc.date()}",
                )
            )

        return sorted(intervals, key=lambda i: i.start_utc)

    async def health(self) -> dict:
        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                response = await client.get(f"{self.BASE_URL}/tariffs/")
                return {
                    "status": "ok" if response.status_code in (200, 401) else "degraded",
                    "provider": self.provider_id,
                    "http_status": response.status_code,
                }
        except Exception as e:
            return {"status": "error", "provider": self.provider_id, "error": str(e)}
