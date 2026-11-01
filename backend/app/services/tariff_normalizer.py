"""Normalize provider-specific tariff responses into the common PriceSlot format."""

from datetime import datetime
from decimal import Decimal

from app.services.optimizer import PriceSlot


def normalize_ckw_intervals(raw_data: list[dict]) -> list[PriceSlot]:
    """Normalize CKW hourly network price data into PriceSlots."""
    slots = []
    for entry in raw_data:
        slots.append(
            PriceSlot(
                start_utc=datetime.fromisoformat(entry["start"]),
                end_utc=datetime.fromisoformat(entry["end"]),
                chf_per_kwh=Decimal(str(entry["price_chf_per_kwh"])),
                component="GRID_USAGE",
            )
        )
    return sorted(slots, key=lambda s: s.start_utc)


def normalize_groupe_e_intervals(raw_data: list[dict]) -> list[PriceSlot]:
    """Normalize Groupe E 15-minute tariff data into PriceSlots."""
    slots = []
    for entry in raw_data:
        slots.append(
            PriceSlot(
                start_utc=datetime.fromisoformat(entry["start"]),
                end_utc=datetime.fromisoformat(entry["end"]),
                chf_per_kwh=Decimal(str(entry["price_chf_per_kwh"])),
                component=entry.get("component", "ENERGY"),
            )
        )
    return sorted(slots, key=lambda s: s.start_utc)


def aggregate_components(slots: list[PriceSlot]) -> list[PriceSlot]:
    """Merge slots with the same time window but different components into a TOTAL component."""
    from collections import defaultdict

    time_groups: dict[tuple[datetime, datetime], Decimal] = defaultdict(Decimal)
    for slot in slots:
        time_groups[(slot.start_utc, slot.end_utc)] += slot.chf_per_kwh

    result = []
    for (start, end), total_price in sorted(time_groups.items()):
        result.append(
            PriceSlot(start_utc=start, end_utc=end, chf_per_kwh=total_price, component="TOTAL")
        )
    return result
