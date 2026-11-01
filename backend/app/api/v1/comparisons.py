from fastapi import APIRouter, Query
from pydantic import BaseModel

router = APIRouter()


class LocalComparisonRequest(BaseModel):
    provider_id: str
    municipality_id: str
    annual_kwh: int = 4500
    current_product_id: str | None = None


class LocalComparisonResult(BaseModel):
    product_id: str
    product_name: str
    tariff_type: str
    annual_cost_chf: str
    is_current: bool
    requires_ems: bool
    requires_smart_meter: bool
    eligibility_text: str | None = None
    assumptions: str


@router.post("/comparisons/local", response_model=list[LocalComparisonResult])
async def compare_local_tariffs(body: LocalComparisonRequest):
    """Compare eligible local tariff products. Demo data in MVP."""
    return [
        LocalComparisonResult(
            product_id="demo-flex",
            product_name="Alpenstrom Flex",
            tariff_type="DYNAMIC_ENERGY",
            annual_cost_chf="1148.00",
            is_current=True,
            requires_ems=False,
            requires_smart_meter=True,
            eligibility_text="Selbst angegebene Teilnahme",
            assumptions=f"Annahme: {body.annual_kwh} kWh/Jahr, stündlich variabler Energietarif",
        ),
        LocalComparisonResult(
            product_id="demo-klassik",
            product_name="Alpenstrom Klassik",
            tariff_type="HT_NT",
            annual_cost_chf="1214.00",
            is_current=False,
            requires_ems=False,
            requires_smart_meter=False,
            eligibility_text="Kein EMS erforderlich, Ab 01.01.2027 beantragbar",
            assumptions=f"Annahme: {body.annual_kwh} kWh/Jahr, Einfacher Hoch-/Niedertarif",
        ),
        LocalComparisonResult(
            product_id="demo-dynamic-grid",
            product_name="Dynamischer Netztarif",
            tariff_type="DYNAMIC_GRID",
            annual_cost_chf="1095.00",
            is_current=False,
            requires_ems=True,
            requires_smart_meter=True,
            eligibility_text="Kompatibles EMS und Smart Meter erforderlich",
            assumptions=f"Annahme: {body.annual_kwh} kWh/Jahr, dynamischer Netz- und Energietarif",
        ),
    ]


@router.get("/comparisons/switzerland")
async def compare_switzerland(
    year: int = Query(default=2027),
    profile: str = Query(default="H4"),
):
    """Educational Switzerland-wide tariff comparison using ElCom data. Demo in MVP."""
    return {
        "year": year,
        "profile": profile,
        "disclaimer": "Die meisten Schweizer Haushalte können ihren Stromanbieter nicht frei wählen. Diese Vergleiche sind Richtwerte, keine Wechselangebote.",
        "disclaimer_en": "Most Swiss households cannot freely switch suppliers. These are benchmarks, not switching offers.",
        "municipalities": [
            {"name": "Bern", "operator": "BKW", "total_rp_kwh": "27.05", "energy_rp_kwh": "13.85", "grid_rp_kwh": "9.10", "levies_rp_kwh": "4.10"},
            {"name": "Zürich", "operator": "EKZ", "total_rp_kwh": "29.40", "energy_rp_kwh": "15.20", "grid_rp_kwh": "10.30", "levies_rp_kwh": "3.90"},
            {"name": "Luzern", "operator": "CKW", "total_rp_kwh": "25.50", "energy_rp_kwh": "12.50", "grid_rp_kwh": "8.80", "levies_rp_kwh": "4.20"},
            {"name": "Fribourg", "operator": "Groupe E", "total_rp_kwh": "25.20", "energy_rp_kwh": "11.90", "grid_rp_kwh": "9.50", "levies_rp_kwh": "3.80"},
            {"name": "Basel", "operator": "Primeo", "total_rp_kwh": "27.00", "energy_rp_kwh": "14.60", "grid_rp_kwh": "7.90", "levies_rp_kwh": "4.50"},
            {"name": "St. Gallen", "operator": "SAK", "total_rp_kwh": "26.30", "energy_rp_kwh": "13.10", "grid_rp_kwh": "9.40", "levies_rp_kwh": "3.80"},
            {"name": "Winterthur", "operator": "Stadtwerk", "total_rp_kwh": "24.80", "energy_rp_kwh": "12.00", "grid_rp_kwh": "8.70", "levies_rp_kwh": "4.10"},
            {"name": "Genève", "operator": "SIG", "total_rp_kwh": "28.90", "energy_rp_kwh": "14.50", "grid_rp_kwh": "10.10", "levies_rp_kwh": "4.30"},
        ],
    }
