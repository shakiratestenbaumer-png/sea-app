from pydantic import BaseModel, Field


class ApplianceCreate(BaseModel):
    type: str
    display_name: str
    duration_minutes: int = Field(ge=15, le=720)
    energy_kwh: float = Field(gt=0, le=100)
    earliest_start_local: str | None = None
    latest_finish_local: str | None = None
    allowed_weekdays: str | None = None
    notification_lead_minutes: int = 15
    preferred_baseline_start: str | None = None
    must_be_home: bool = False
    quiet_hours_policy: str | None = None


class ApplianceUpdate(BaseModel):
    display_name: str | None = None
    duration_minutes: int | None = Field(default=None, ge=15, le=720)
    energy_kwh: float | None = Field(default=None, gt=0, le=100)
    earliest_start_local: str | None = None
    latest_finish_local: str | None = None
    allowed_weekdays: str | None = None
    notification_lead_minutes: int | None = None
    preferred_baseline_start: str | None = None


class ApplianceResponse(BaseModel):
    id: str
    type: str
    display_name: str
    duration_minutes: int
    energy_kwh: float
    earliest_start_local: str | None = None
    latest_finish_local: str | None = None
    allowed_weekdays: str | None = None
    notification_lead_minutes: int
    preferred_baseline_start: str | None = None
    must_be_home: bool
    active: bool

    model_config = {"from_attributes": True}


class RecommendationPreviewRequest(BaseModel):
    appliance_id: str
    date: str
    product_id: str


class AlternativeWindow(BaseModel):
    start: str
    end: str
    modeled_cost_chf: str | None = None


class RecommendationResponse(BaseModel):
    id: str | None = None
    appliance_id: str
    run_date: str
    best_start: str
    best_end: str
    modeled_cost_chf: str | None = None
    baseline_cost_chf: str | None = None
    potential_savings_chf: str | None = None
    confidence: str
    priced_components: str | None = None
    alternatives: list[AlternativeWindow] = []
    caveats: list[str] = []

    model_config = {"from_attributes": True}
