"""Deterministic fixture/demo adapter for development and testing.

All prices are synthetic and clearly labeled DEMO. Never present these as real provider data.
"""

from datetime import datetime, timedelta, timezone
from decimal import Decimal

from app.integrations.providers.base import (
    Component,
    LicenseStatus,
    PriceInterval,
    ProviderAdapter,
)


def _generate_hourly_fixture(
    base_date_utc: datetime,
    hours: int = 24,
    base_energy: Decimal = Decimal("0.12"),
    base_grid: Decimal = Decimal("0.091"),
) -> list[PriceInterval]:
    """Generate deterministic hourly price intervals for a day.

    Prices follow a realistic Swiss intraday pattern:
    - Low overnight (00-06)
    - Rising morning (06-09)
    - Peak midday (10-13)
    - Afternoon dip (13-16) — solar surplus effect
    - Evening peak (17-21)
    - Declining night (21-24)
    """
    hourly_energy_multipliers = [
        0.70, 0.65, 0.60, 0.58, 0.60, 0.65,  # 00-05
        0.80, 0.95, 1.10, 1.20, 1.25, 1.30,  # 06-11
        1.20, 1.00, 0.85, 0.80, 0.90, 1.15,  # 12-17
        1.30, 1.25, 1.15, 1.00, 0.85, 0.75,  # 18-23
    ]

    intervals = []
    for h in range(hours):
        start = base_date_utc + timedelta(hours=h)
        end = start + timedelta(hours=1)
        mult = Decimal(str(hourly_energy_multipliers[h % 24]))

        intervals.append(
            PriceInterval(
                start_utc=start,
                end_utc=end,
                component=Component.ENERGY,
                chf_per_kwh=(base_energy * mult).quantize(Decimal("0.000001")),
                tax_included=True,
                quality="DEMO",
                source_id="fixture-demo",
            )
        )
        intervals.append(
            PriceInterval(
                start_utc=start,
                end_utc=end,
                component=Component.GRID_USAGE,
                chf_per_kwh=base_grid,
                tax_included=False,
                quality="DEMO",
                source_id="fixture-demo",
            )
        )

    return intervals


class FixtureAdapter(ProviderAdapter):
    provider_id = "fixture-demo"
    provider_name = "Demo Provider (Alpenstrom Stadtwerk)"
    license_status = LicenseStatus.APPROVED_PUBLIC

    async def fetch(
        self, product_id: str, start_utc: datetime, end_utc: datetime
    ) -> list[PriceInterval]:
        base = start_utc.replace(hour=0, minute=0, second=0, microsecond=0)
        total_hours = int((end_utc - base).total_seconds() / 3600)
        return _generate_hourly_fixture(base, hours=max(24, total_hours))

    async def health(self) -> dict:
        return {"status": "ok", "provider": self.provider_id, "mode": "fixture"}
