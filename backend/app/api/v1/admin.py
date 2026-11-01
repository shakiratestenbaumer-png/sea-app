from fastapi import APIRouter

from app.integrations.providers.swiss_tariff import SwissTariffAdapter, PROVIDER_ENDPOINTS

router = APIRouter()


@router.get("/admin/providers/health")
async def providers_health():
    """Live health status of all provider adapters."""
    results = []
    for pid in PROVIDER_ENDPOINTS:
        adapter = SwissTariffAdapter(pid)
        health = await adapter.health()
        results.append(health)
    return {"providers": results}
