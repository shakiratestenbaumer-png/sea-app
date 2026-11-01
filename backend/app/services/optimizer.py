"""Appliance scheduling optimizer.

Finds the cheapest contiguous time window to run a non-interruptible appliance
based on tariff intervals and user constraints.
"""

from dataclasses import dataclass
from datetime import datetime, timedelta
from decimal import Decimal


@dataclass(frozen=True)
class PriceSlot:
    start_utc: datetime
    end_utc: datetime
    chf_per_kwh: Decimal
    component: str = "TOTAL"


@dataclass(frozen=True)
class ApplianceProfile:
    duration_minutes: int
    energy_kwh: Decimal
    earliest_start_utc: datetime | None = None
    latest_finish_utc: datetime | None = None
    preferred_baseline_start_utc: datetime | None = None


@dataclass(frozen=True)
class OptimalWindow:
    start_utc: datetime
    end_utc: datetime
    modeled_cost_chf: Decimal
    coverage_complete: bool


def _integrate_cost(
    profile: ApplianceProfile,
    start: datetime,
    slots: list[PriceSlot],
) -> tuple[Decimal, bool]:
    """Calculate the total variable cost for running an appliance starting at `start`.

    Uses a flat power profile: power_kw = energy_kwh / (duration_minutes / 60).
    Integrates cost per interval with fractional overlaps at time boundaries.
    Returns (cost_chf, is_complete) where is_complete indicates full coverage.
    """
    duration = timedelta(minutes=profile.duration_minutes)
    end = start + duration
    power_kw = profile.energy_kwh / Decimal(str(profile.duration_minutes / 60))
    total_cost = Decimal("0")
    covered_minutes = Decimal("0")

    for slot in slots:
        overlap_start = max(start, slot.start_utc)
        overlap_end = min(end, slot.end_utc)
        if overlap_start >= overlap_end:
            continue
        overlap_minutes = Decimal(str((overlap_end - overlap_start).total_seconds() / 60))
        overlap_hours = overlap_minutes / Decimal("60")
        energy_in_slot = power_kw * overlap_hours
        total_cost += energy_in_slot * slot.chf_per_kwh
        covered_minutes += overlap_minutes

    expected_minutes = Decimal(str(profile.duration_minutes))
    is_complete = abs(covered_minutes - expected_minutes) < Decimal("1")

    return total_cost, is_complete


def find_best_starts(
    profile: ApplianceProfile,
    slots: list[PriceSlot],
    step_minutes: int = 15,
    max_results: int = 3,
) -> list[OptimalWindow]:
    """Find up to `max_results` cheapest non-overlapping start windows."""
    if not slots:
        return []

    duration = timedelta(minutes=profile.duration_minutes)
    step = timedelta(minutes=step_minutes)
    earliest = profile.earliest_start_utc or slots[0].start_utc
    latest_possible_start = (profile.latest_finish_utc or slots[-1].end_utc) - duration

    candidates: list[OptimalWindow] = []
    current = earliest

    while current <= latest_possible_start:
        cost, complete = _integrate_cost(profile, current, slots)
        if complete:
            candidates.append(
                OptimalWindow(
                    start_utc=current,
                    end_utc=current + duration,
                    modeled_cost_chf=cost,
                    coverage_complete=complete,
                )
            )
        current += step

    candidates.sort(key=lambda w: (w.modeled_cost_chf, w.start_utc))

    results: list[OptimalWindow] = []
    for candidate in candidates:
        overlaps = any(
            not (candidate.end_utc <= r.start_utc or candidate.start_utc >= r.end_utc) for r in results
        )
        if not overlaps:
            results.append(candidate)
        if len(results) >= max_results:
            break

    return results


def calculate_baseline_cost(
    profile: ApplianceProfile,
    slots: list[PriceSlot],
) -> Decimal | None:
    """Calculate cost at the user's preferred baseline start time."""
    if profile.preferred_baseline_start_utc is None:
        return None
    cost, complete = _integrate_cost(profile, profile.preferred_baseline_start_utc, slots)
    if not complete:
        return None
    return cost
