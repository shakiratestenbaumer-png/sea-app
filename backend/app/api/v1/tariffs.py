from fastapi import APIRouter, Query

from app.integrations.providers.swiss_tariff import (
    get_all_providers_response,
    PROVIDER_ENDPOINTS,
)

router = APIRouter()


@router.get("/tariffs/providers")
async def get_all_providers():
    """Get cached prices from all Swiss providers.
    
    This is the main endpoint the frontend calls. 
    All provider fetches happen server-side (no CORS issues, rate-limit safe).
    Cached for 15 minutes.
    """
    return await get_all_providers_response()


@router.get("/tariffs/intervals")
async def get_tariff_intervals(
    provider: str = Query(default="ckw"),
):
    """Get tariff intervals for a single provider."""
    data = await get_all_providers_response()
    for p in data["providers"]:
        if p["id"] == provider:
            return p
    return {"error": f"Unknown provider. Available: {list(PROVIDER_ENDPOINTS.keys())}"}


@router.get("/tariffs/summary")
async def get_tariff_summary():
    """Summary stats for all providers."""
    data = await get_all_providers_response()
    return {
        "providers": [
            {
                "id": p["id"],
                "name": p["name"],
                "territory": p["territory"],
                "status": p["status"],
                "summary": p.get("summary"),
            }
            for p in data["providers"]
        ]
    }


@router.get("/annual-tariffs")
async def get_annual_tariffs(
    year: int = Query(default=2027),
    municipality_id: str = Query(default=None),
    profile: str = Query(default="H4"),
):
    """ElCom regulated annual tariff benchmarks."""
    demo_tariffs = [
        {"year": 2027, "municipality_id": "351", "municipality_name": "Bern", "operator_name": "BKW", "consumption_category": "H4", "energy_rp_kwh": "13.85", "grid_rp_kwh": "9.10", "levies_rp_kwh": "4.10", "total_rp_kwh": "27.05"},
        {"year": 2027, "municipality_id": "261", "municipality_name": "Zürich", "operator_name": "EKZ", "consumption_category": "H4", "energy_rp_kwh": "15.20", "grid_rp_kwh": "10.30", "levies_rp_kwh": "3.90", "total_rp_kwh": "29.40"},
        {"year": 2027, "municipality_id": "2196", "municipality_name": "Luzern", "operator_name": "CKW", "consumption_category": "H4", "energy_rp_kwh": "12.50", "grid_rp_kwh": "8.80", "levies_rp_kwh": "4.20", "total_rp_kwh": "25.50"},
        {"year": 2027, "municipality_id": "2311", "municipality_name": "Fribourg", "operator_name": "Groupe E", "consumption_category": "H4", "energy_rp_kwh": "11.90", "grid_rp_kwh": "9.50", "levies_rp_kwh": "3.80", "total_rp_kwh": "25.20"},
        {"year": 2027, "municipality_id": "2762", "municipality_name": "Basel", "operator_name": "Primeo", "consumption_category": "H4", "energy_rp_kwh": "14.60", "grid_rp_kwh": "7.90", "levies_rp_kwh": "4.50", "total_rp_kwh": "27.00"},
    ]
    results = [t for t in demo_tariffs if t["year"] == year]
    if municipality_id:
        results = [t for t in results if t["municipality_id"] == municipality_id]
    return results
