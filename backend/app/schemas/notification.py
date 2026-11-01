from pydantic import BaseModel


class NotificationPreferencesUpdate(BaseModel):
    daily_digest: bool | None = None
    daily_digest_local_time: str | None = None
    reminder_lead_minutes: int | None = None
    quiet_hours_start: str | None = None
    quiet_hours_end: str | None = None
    enabled: bool | None = None


class NotificationPreferencesResponse(BaseModel):
    daily_digest: bool
    daily_digest_local_time: str | None = None
    reminder_lead_minutes: int
    quiet_hours_start: str | None = None
    quiet_hours_end: str | None = None
    enabled: bool
    push_registered: bool = False

    model_config = {"from_attributes": True}


class PushTokenCreate(BaseModel):
    token: str
    platform: str = "android"
