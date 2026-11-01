from fastapi import APIRouter, Depends

from app.core.security import get_current_user
from app.schemas.notification import (
    NotificationPreferencesResponse,
    NotificationPreferencesUpdate,
    PushTokenCreate,
)

router = APIRouter()


@router.get("/me/notifications/preferences", response_model=NotificationPreferencesResponse)
async def get_notification_preferences(user: dict = Depends(get_current_user)):
    """Get notification preferences. Returns defaults in MVP."""
    return NotificationPreferencesResponse(
        daily_digest=True,
        daily_digest_local_time="19:00",
        reminder_lead_minutes=15,
        quiet_hours_start="22:00",
        quiet_hours_end="07:00",
        enabled=True,
        push_registered=False,
    )


@router.put("/me/notifications/preferences", response_model=NotificationPreferencesResponse)
async def update_notification_preferences(
    body: NotificationPreferencesUpdate,
    user: dict = Depends(get_current_user),
):
    """Update notification preferences. Demo-only in MVP."""
    return NotificationPreferencesResponse(
        daily_digest=body.daily_digest if body.daily_digest is not None else True,
        daily_digest_local_time=body.daily_digest_local_time or "19:00",
        reminder_lead_minutes=body.reminder_lead_minutes or 15,
        quiet_hours_start=body.quiet_hours_start or "22:00",
        quiet_hours_end=body.quiet_hours_end or "07:00",
        enabled=body.enabled if body.enabled is not None else True,
        push_registered=False,
    )


@router.post("/me/push-tokens", status_code=201)
async def register_push_token(
    body: PushTokenCreate,
    user: dict = Depends(get_current_user),
):
    """Register a push notification token. Stub in MVP."""
    return {"status": "registered", "platform": body.platform, "note": "DEMO — no actual push service connected"}


@router.delete("/me/push-tokens/{token_id}", status_code=204)
async def unregister_push_token(token_id: str, user: dict = Depends(get_current_user)):
    """Unregister a push token."""
    pass
