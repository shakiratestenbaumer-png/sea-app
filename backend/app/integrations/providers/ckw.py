"""CKW dynamic grid tariff adapter.

Endpoint: https://e-ckw-public-data.de-c1.eu1.cloudhub.io/api/v1/
          netzinformationen/energie/dynamische-preise

IMPORTANT: This adapter fetches only the GRID/NETWORK component. CKW's dynamic
price is NOT the full retail electricity cost. The app must clearly label this
as "Network charge only — not full electricity price."

Status: NEEDS_ACCESS — commercial reuse permission must be verified before production.
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


class CKWAdapter(ProviderAdapter):
    provider_id = "ckw"
    provider_name = "CKW (Centralschweizerische Kraftwerke)"
    license_status = LicenseStatus.NEEDS_ACCESS

    BASE_URL = settings.ckw_api_base_url

    async def fetch(
        self, product_id: str, start_utc: datetime, end_utc: datetime
    ) -> list[PriceInterval]:
        url = f"{self.BASE_URL}/netzinformationen/energie/dynamische-preise"
        params = {
            "date": start_utc.strftime("%Y-%m-%d"),
        }

        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.get(url, params=params)
            response.raise_for_status()
            data = response.json()

        intervals = []
        for entry in data if isinstance(data, list) else data.get("prices", []):
            intervals.append(
                PriceInterval(
                    start_utc=datetime.fromisoformat(entry["timestamp"]),
                    end_utc=datetime.fromisoformat(entry["timestamp_end"]) if "timestamp_end" in entry
                    else datetime.fromisoformat(entry["timestamp"]).replace(minute=0) + __import__("datetime").timedelta(hours=1),
                    component=Component.GRID_USAGE,
                    chf_per_kwh=Decimal(str(entry.get("price", entry.get("value", 0)))) / Decimal("100"),
                    tax_included=False,
                    quality="ACTUAL",
                    source_id=f"ckw-{start_utc.date()}",
                )
            )

        return sorted(intervals, key=lambda i: i.start_utc)

    async def health(self) -> dict:
        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                response = await client.get(f"{self.BASE_URL}/netzinformationen/energie/dynamische-preise")
                return {
                    "status": "ok" if response.status_code == 200 else "degraded",
                    "provider": self.provider_id,
                    "http_status": response.status_code,
                }
        except Exception as e:
            return {"status": "error", "provider": self.provider_id, "error": str(e)}
