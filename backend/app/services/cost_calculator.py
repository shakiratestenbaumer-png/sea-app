"""Cost calculation utilities for tariff comparison and bill estimation."""

from decimal import Decimal


def annual_cost_estimate(
    energy_rp_kwh: Decimal | None,
    grid_rp_kwh: Decimal | None,
    levies_rp_kwh: Decimal | None,
    metering_chf_year: Decimal | None,
    base_chf_year: Decimal | None,
    annual_kwh: int,
) -> Decimal:
    """Estimate annual electricity cost from regulated tariff components.

    Prices in Rp./kWh are converted to CHF. Fixed costs added on top.
    """
    variable_total_rp = Decimal("0")
    if energy_rp_kwh:
        variable_total_rp += energy_rp_kwh
    if grid_rp_kwh:
        variable_total_rp += grid_rp_kwh
    if levies_rp_kwh:
        variable_total_rp += levies_rp_kwh

    variable_chf = (variable_total_rp * Decimal(str(annual_kwh))) / Decimal("100")

    fixed_chf = Decimal("0")
    if metering_chf_year:
        fixed_chf += metering_chf_year
    if base_chf_year:
        fixed_chf += base_chf_year

    return variable_chf + fixed_chf


def rp_to_chf(rp_per_kwh: Decimal) -> Decimal:
    """Convert Rappen/kWh to CHF/kWh."""
    return rp_per_kwh / Decimal("100")


def chf_to_rp(chf_per_kwh: Decimal) -> Decimal:
    """Convert CHF/kWh to Rappen/kWh."""
    return chf_per_kwh * Decimal("100")
