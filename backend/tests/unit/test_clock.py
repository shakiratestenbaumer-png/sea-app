"""Tests for timezone and DST utilities."""

from datetime import date

from app.core.clock import (
    expected_hourly_slots,
    expected_quarter_hour_slots,
    local_day_end_utc,
    local_day_start_utc,
)


class TestDSTHandling:
    def test_normal_day_has_24_hours(self):
        d = date(2027, 1, 15)
        assert expected_hourly_slots(d) == 24
        assert expected_quarter_hour_slots(d) == 96

    def test_spring_forward_has_23_hours(self):
        """Last Sunday of March 2027: clocks spring forward, 23-hour day."""
        d = date(2027, 3, 28)
        assert expected_hourly_slots(d) == 23
        assert expected_quarter_hour_slots(d) == 92

    def test_autumn_back_has_25_hours(self):
        """Last Sunday of October 2027: clocks fall back, 25-hour day."""
        d = date(2027, 10, 31)
        assert expected_hourly_slots(d) == 25
        assert expected_quarter_hour_slots(d) == 100

    def test_day_boundaries_are_consistent(self):
        d = date(2027, 6, 15)
        start = local_day_start_utc(d)
        end = local_day_end_utc(d)
        assert end > start
        hours = (end - start).total_seconds() / 3600
        assert hours == 24
