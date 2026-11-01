from datetime import date as date_type, datetime, timedelta, timezone
from decimal import Decimal

from fastapi import APIRouter, Depends, Query

from app.core.clock import local_day_start_utc, local_day_end_utc, ZURICH_TZ
from app.core.security import get_current_user
from app.integrations.providers.fixtures import FixtureAdapter
from app.schemas.appliance import RecommendationPreviewRequest, RecommendationResponse, AlternativeWindow
from app.services.optimizer import ApplianceProfile, PriceSlot, find_best_starts, calculate_baseline_cost

router = APIRouter()


@router.post("/recommendations/preview", response_model=RecommendationResponse)
async def preview_recommendation(body: RecommendationPreviewRequest):
    """Preview optimal scheduling without saving. Uses demo data in MVP."""
    local_date = date_type.fromisoformat(body.date)
    start_utc = local_day_start_utc(local_date)
    end_utc = local_day_end_utc(local_date)

    adapter = FixtureAdapter()
    raw_intervals = await adapter.fetch(body.product_id, start_utc, end_utc)

    from collections import defaultdict

    time_prices: dict[tuple, Decimal] = defaultdict(Decimal)
    for iv in raw_intervals:
        time_prices[(iv.start_utc, iv.end_utc)] += iv.chf_per_kwh

    slots = [
        PriceSlot(start_utc=k[0], end_utc=k[1], chf_per_kwh=v, component="TOTAL")
        for k, v in sorted(time_prices.items())
    ]

    profile = ApplianceProfile(
        duration_minutes=120,
        energy_kwh=Decimal("1.0"),
        earliest_start_utc=start_utc,
        latest_finish_utc=end_utc,
    )

    windows = find_best_starts(profile, slots, step_minutes=60, max_results=3)

    if not windows:
        return RecommendationResponse(
            appliance_id=body.appliance_id,
            run_date=body.date,
            best_start=start_utc.isoformat(),
            best_end=(start_utc + timedelta(hours=2)).isoformat(),
            confidence="partial",
            caveats=["No complete price coverage found for this date."],
        )

    best = windows[0]
    alternatives = [
        AlternativeWindow(
            start=w.start_utc.isoformat(),
            end=w.end_utc.isoformat(),
            modeled_cost_chf=str(w.modeled_cost_chf.quantize(Decimal("0.01"))),
        )
        for w in windows[1:]
    ]

    return RecommendationResponse(
        appliance_id=body.appliance_id,
        run_date=body.date,
        best_start=best.start_utc.isoformat(),
        best_end=best.end_utc.isoformat(),
        modeled_cost_chf=str(best.modeled_cost_chf.quantize(Decimal("0.01"))),
        confidence="modeled",
        priced_components="ENERGY+GRID_USAGE",
        alternatives=alternatives,
        caveats=["DEMO — modeled costs based on synthetic prices and flat consumption profile."],
    )


@router.get("/me/recommendations", response_model=list[RecommendationResponse])
async def get_recommendations(
    date: str = Query(...),
    user: dict = Depends(get_current_user),
):
    """Get saved recommendations for a date. Returns empty in MVP until persistence is connected."""
    return []
