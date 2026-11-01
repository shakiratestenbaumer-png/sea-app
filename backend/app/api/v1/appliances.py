import uuid

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import get_current_user
from app.db.session import get_db
from app.models.appliance import Appliance
from app.models.household import Household
from app.schemas.appliance import ApplianceCreate, ApplianceUpdate, ApplianceResponse

router = APIRouter()


async def _get_household(user: dict, db: AsyncSession) -> Household:
    user_id = uuid.UUID(user["sub"])
    result = await db.execute(select(Household).where(Household.owner_user_id == user_id))
    household = result.scalar_one_or_none()
    if not household:
        raise HTTPException(status_code=404, detail="Household not found. Complete onboarding first.")
    return household


@router.get("/me/appliances", response_model=list[ApplianceResponse])
async def list_appliances(
    user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    household = await _get_household(user, db)
    result = await db.execute(
        select(Appliance)
        .where(Appliance.household_id == household.id, Appliance.active == True)
        .order_by(Appliance.created_at)
    )
    appliances = result.scalars().all()
    return [ApplianceResponse(id=str(a.id), **{k: v for k, v in ApplianceResponse.model_validate(a).model_dump().items() if k != "id"}) for a in appliances]


@router.post("/me/appliances", response_model=ApplianceResponse, status_code=201)
async def create_appliance(
    body: ApplianceCreate,
    user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    household = await _get_household(user, db)
    appliance = Appliance(
        household_id=household.id,
        type=body.type,
        display_name=body.display_name,
        duration_minutes=body.duration_minutes,
        energy_kwh=body.energy_kwh,
        earliest_start_local=body.earliest_start_local,
        latest_finish_local=body.latest_finish_local,
        allowed_weekdays=body.allowed_weekdays,
        notification_lead_minutes=body.notification_lead_minutes,
        preferred_baseline_start=body.preferred_baseline_start,
        must_be_home=body.must_be_home,
        quiet_hours_policy=body.quiet_hours_policy,
    )
    db.add(appliance)
    await db.flush()
    return ApplianceResponse(id=str(appliance.id), **ApplianceResponse.model_validate(appliance).model_dump(exclude={"id"}))


@router.patch("/me/appliances/{appliance_id}", response_model=ApplianceResponse)
async def update_appliance(
    appliance_id: str,
    body: ApplianceUpdate,
    user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    household = await _get_household(user, db)
    result = await db.execute(
        select(Appliance).where(
            Appliance.id == uuid.UUID(appliance_id),
            Appliance.household_id == household.id,
        )
    )
    appliance = result.scalar_one_or_none()
    if not appliance:
        raise HTTPException(status_code=404, detail="Appliance not found")

    update_data = body.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(appliance, field, value)

    await db.flush()
    return ApplianceResponse(id=str(appliance.id), **ApplianceResponse.model_validate(appliance).model_dump(exclude={"id"}))


@router.delete("/me/appliances/{appliance_id}", status_code=204)
async def delete_appliance(
    appliance_id: str,
    user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    household = await _get_household(user, db)
    result = await db.execute(
        select(Appliance).where(
            Appliance.id == uuid.UUID(appliance_id),
            Appliance.household_id == household.id,
        )
    )
    appliance = result.scalar_one_or_none()
    if not appliance:
        raise HTTPException(status_code=404, detail="Appliance not found")
    appliance.active = False
    await db.flush()
