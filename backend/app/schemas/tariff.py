from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel


class TariffIntervalResponse(BaseModel):
    start: str
    end: str
    component: str
    price_chf_per_kwh: str
    tax_included: bool
    quality: str = "ACTUAL"

    model_config = {"from_attributes": True}


class TariffScheduleResponse(BaseModel):
    product_id: str
    display_name: str
    date_local: str
    timezone: str = "Europe/Zurich"
    published_at: str | None = None
    fetched_at: str | None = None
    data_state: str
    resolution_minutes: int
    currency: str = "CHF"
    scope: str
    all_in_price_available: bool
    intervals: list[TariffIntervalResponse]
    source_url: str | None = None
    disclaimer: str | None = None


class TariffSummaryResponse(BaseModel):
    product_id: str
    date_local: str
    min_price_chf_per_kwh: str | None = None
    max_price_chf_per_kwh: str | None = None
    avg_price_chf_per_kwh: str | None = None
    min_price_time: str | None = None
    interval_count: int
    scope: str
    components_complete: bool


class RegulatedTariffResponse(BaseModel):
    year: int
    municipality_id: str
    municipality_name: str | None = None
    operator_name: str | None = None
    consumption_category: str
    energy_rp_kwh: str | None = None
    grid_rp_kwh: str | None = None
    levies_rp_kwh: str | None = None
    total_rp_kwh: str | None = None
    metering_chf_year: str | None = None
    base_chf_year: str | None = None

    model_config = {"from_attributes": True}
