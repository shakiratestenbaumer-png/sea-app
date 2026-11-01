from pydantic import BaseModel


class HouseholdCreate(BaseModel):
    label: str = "Mein Zuhause"
    postal_code: str | None = None
    municipality_id: str | None = None
    municipality_name: str | None = None
    distribution_operator_id: str | None = None
    distribution_operator_name: str | None = None
    provider_id: str | None = None
    tariff_product_id: str | None = None
    enrollment_status: str = "unknown"
    annual_kwh_estimate: int | None = None
    has_smart_meter: bool | None = None
    has_solar: bool | None = None
    has_ev: bool | None = None


class HouseholdUpdate(BaseModel):
    label: str | None = None
    postal_code: str | None = None
    municipality_id: str | None = None
    municipality_name: str | None = None
    distribution_operator_id: str | None = None
    distribution_operator_name: str | None = None
    provider_id: str | None = None
    tariff_product_id: str | None = None
    enrollment_status: str | None = None
    annual_kwh_estimate: int | None = None
    has_smart_meter: bool | None = None


class HouseholdResponse(BaseModel):
    id: str
    label: str
    postal_code: str | None = None
    municipality_id: str | None = None
    municipality_name: str | None = None
    distribution_operator_name: str | None = None
    provider_id: str | None = None
    tariff_product_id: str | None = None
    enrollment_status: str
    annual_kwh_estimate: int | None = None

    model_config = {"from_attributes": True}
