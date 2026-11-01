from pydantic import BaseModel


class ProviderResponse(BaseModel):
    id: str
    slug: str
    name: str
    territory: str | None = None
    docs_url: str | None = None
    license_status: str
    publication_time_local: str | None = None
    native_granularity_minutes: int | None = None
    active: bool

    model_config = {"from_attributes": True}


class TariffProductResponse(BaseModel):
    id: str
    provider_id: str
    name: str
    tariff_type: str
    eligible_from: str | None = None
    eligible_to: str | None = None
    requires_ems: bool
    requires_smart_meter: bool
    eligibility_text: str | None = None
    official_url: str | None = None
    is_selectable: bool
    interval_minutes: int | None = None
    scope: str

    model_config = {"from_attributes": True}
