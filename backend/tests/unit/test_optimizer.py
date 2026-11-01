"""Golden tests for the appliance scheduling optimizer."""

from datetime import datetime, timedelta, timezone
from decimal import Decimal

import pytest

from app.services.optimizer import (
    ApplianceProfile,
    OptimalWindow,
    PriceSlot,
    calculate_baseline_cost,
    find_best_starts,
)


def _make_hourly_slots(base: datetime, prices: list[str]) -> list[PriceSlot]:
    """Create hourly PriceSlots from a list of CHF/kWh strings."""
    slots = []
    for i, price in enumerate(prices):
        slots.append(
            PriceSlot(
                start_utc=base + timedelta(hours=i),
                end_utc=base + timedelta(hours=i + 1),
                chf_per_kwh=Decimal(price),
                component="TOTAL",
            )
        )
    return slots


BASE = datetime(2027, 1, 15, 0, 0, 0, tzinfo=timezone.utc)


class TestFindBestStarts:
    def test_simple_2h_appliance_finds_cheapest(self):
        """A 2-hour appliance should find the cheapest contiguous 2-hour window."""
        prices = ["0.30", "0.25", "0.15", "0.10", "0.20", "0.35"]
        slots = _make_hourly_slots(BASE, prices)
        profile = ApplianceProfile(
            duration_minutes=120,
            energy_kwh=Decimal("1.0"),
            earliest_start_utc=BASE,
            latest_finish_utc=BASE + timedelta(hours=6),
        )
        results = find_best_starts(profile, slots, step_minutes=60)

        assert len(results) >= 1
        best = results[0]
        assert best.start_utc == BASE + timedelta(hours=2)
        assert best.end_utc == BASE + timedelta(hours=4)

    def test_returns_up_to_3_non_overlapping(self):
        prices = ["0.30", "0.25", "0.15", "0.10", "0.20", "0.35", "0.12", "0.14"]
        slots = _make_hourly_slots(BASE, prices)
        profile = ApplianceProfile(
            duration_minutes=60,
            energy_kwh=Decimal("1.0"),
            earliest_start_utc=BASE,
            latest_finish_utc=BASE + timedelta(hours=8),
        )
        results = find_best_starts(profile, slots, step_minutes=60, max_results=3)

        assert len(results) == 3
        for i in range(len(results)):
            for j in range(i + 1, len(results)):
                assert results[i].end_utc <= results[j].start_utc or results[j].end_utc <= results[i].start_utc

    def test_empty_slots_returns_empty(self):
        profile = ApplianceProfile(
            duration_minutes=60,
            energy_kwh=Decimal("1.0"),
        )
        assert find_best_starts(profile, [], step_minutes=60) == []

    def test_respects_earliest_start(self):
        prices = ["0.05", "0.30", "0.30", "0.30"]
        slots = _make_hourly_slots(BASE, prices)
        profile = ApplianceProfile(
            duration_minutes=60,
            energy_kwh=Decimal("1.0"),
            earliest_start_utc=BASE + timedelta(hours=1),
            latest_finish_utc=BASE + timedelta(hours=4),
        )
        results = find_best_starts(profile, slots, step_minutes=60)

        assert results[0].start_utc >= BASE + timedelta(hours=1)

    def test_respects_latest_finish(self):
        prices = ["0.30", "0.30", "0.05", "0.05"]
        slots = _make_hourly_slots(BASE, prices)
        profile = ApplianceProfile(
            duration_minutes=120,
            energy_kwh=Decimal("1.0"),
            earliest_start_utc=BASE,
            latest_finish_utc=BASE + timedelta(hours=3),
        )
        results = find_best_starts(profile, slots, step_minutes=60)

        for r in results:
            assert r.end_utc <= BASE + timedelta(hours=3)

    def test_cost_calculation_accuracy(self):
        """Verify cost = sum(energy_in_slot × price_per_kwh) for flat profile."""
        prices = ["0.20", "0.30"]
        slots = _make_hourly_slots(BASE, prices)
        profile = ApplianceProfile(
            duration_minutes=120,
            energy_kwh=Decimal("2.0"),
            earliest_start_utc=BASE,
            latest_finish_utc=BASE + timedelta(hours=2),
        )
        results = find_best_starts(profile, slots, step_minutes=60, max_results=1)

        assert len(results) == 1
        # Power = 2.0 kWh / 2h = 1.0 kW
        # Cost = 1.0 kW × 1h × 0.20 + 1.0 kW × 1h × 0.30 = 0.50
        assert results[0].modeled_cost_chf == Decimal("0.50")

    def test_45_minute_appliance(self):
        """45-minute appliance should handle fractional overlaps."""
        prices = ["0.20", "0.10", "0.30"]
        slots = _make_hourly_slots(BASE, prices)
        profile = ApplianceProfile(
            duration_minutes=45,
            energy_kwh=Decimal("1.5"),
            earliest_start_utc=BASE,
            latest_finish_utc=BASE + timedelta(hours=3),
        )
        results = find_best_starts(profile, slots, step_minutes=15)
        assert len(results) >= 1

    def test_90_minute_appliance(self):
        prices = ["0.30", "0.10", "0.15", "0.25"]
        slots = _make_hourly_slots(BASE, prices)
        profile = ApplianceProfile(
            duration_minutes=90,
            energy_kwh=Decimal("2.0"),
            earliest_start_utc=BASE,
            latest_finish_utc=BASE + timedelta(hours=4),
        )
        results = find_best_starts(profile, slots, step_minutes=15)
        assert len(results) >= 1
        assert results[0].start_utc >= BASE + timedelta(hours=1)


class TestBaselineCost:
    def test_baseline_cost_calculation(self):
        prices = ["0.20", "0.30", "0.10", "0.15"]
        slots = _make_hourly_slots(BASE, prices)
        profile = ApplianceProfile(
            duration_minutes=60,
            energy_kwh=Decimal("1.0"),
            preferred_baseline_start_utc=BASE + timedelta(hours=1),
        )
        cost = calculate_baseline_cost(profile, slots)
        assert cost == Decimal("0.30")

    def test_baseline_none_when_no_preference(self):
        slots = _make_hourly_slots(BASE, ["0.20"])
        profile = ApplianceProfile(duration_minutes=60, energy_kwh=Decimal("1.0"))
        assert calculate_baseline_cost(profile, slots) is None
