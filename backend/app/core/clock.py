"""Timezone-aware clock utilities for Europe/Zurich and DST handling."""

from datetime import date, datetime, timedelta, timezone
from zoneinfo import ZoneInfo

ZURICH_TZ = ZoneInfo("Europe/Zurich")
UTC = timezone.utc


def now_utc() -> datetime:
    return datetime.now(UTC)


def now_zurich() -> datetime:
    return datetime.now(ZURICH_TZ)


def to_zurich(dt: datetime) -> datetime:
    return dt.astimezone(ZURICH_TZ)


def to_utc(dt: datetime) -> datetime:
    return dt.astimezone(UTC)


def zurich_date_today() -> date:
    return now_zurich().date()


def local_day_start_utc(local_date: date) -> datetime:
    """Return UTC instant for 00:00:00 in Europe/Zurich for the given local date."""
    local_midnight = datetime(local_date.year, local_date.month, local_date.day, tzinfo=ZURICH_TZ)
    return local_midnight.astimezone(UTC)


def local_day_end_utc(local_date: date) -> datetime:
    """Return UTC instant for 00:00:00 of the *next* day in Europe/Zurich."""
    next_day = local_date + timedelta(days=1)
    return local_day_start_utc(next_day)


def expected_quarter_hour_slots(local_date: date) -> int:
    """Return number of 15-min slots for a given date in Europe/Zurich (92, 96, or 100 for DST)."""
    start = local_day_start_utc(local_date)
    end = local_day_end_utc(local_date)
    total_seconds = (end - start).total_seconds()
    return int(total_seconds / 900)


def expected_hourly_slots(local_date: date) -> int:
    """Return number of hourly slots for a given date in Europe/Zurich (23, 24, or 25 for DST)."""
    start = local_day_start_utc(local_date)
    end = local_day_end_utc(local_date)
    total_seconds = (end - start).total_seconds()
    return int(total_seconds / 3600)


def utc_timeline(start: datetime, end: datetime, step_minutes: int = 15):
    """Yield UTC datetimes from start up to (not including) end at step_minutes intervals."""
    step = timedelta(minutes=step_minutes)
    current = start
    while current < end:
        yield current
        current += step
