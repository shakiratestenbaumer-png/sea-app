from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_db
from app.models.provider import Provider, ProviderTariffProduct
from app.schemas.provider import ProviderResponse, TariffProductResponse

router = APIRouter()


@router.get("/providers", response_model=list[ProviderResponse])
async def list_providers(db: AsyncSession = Depends(get_db)):
    """List all supported energy providers."""
    result = await db.execute(select(Provider).where(Provider.active == True).order_by(Provider.name))
    return [ProviderResponse.model_validate(p) for p in result.scalars().all()]


@router.get("/providers/{provider_id}/products", response_model=list[TariffProductResponse])
async def list_products(provider_id: str, db: AsyncSession = Depends(get_db)):
    """List tariff products for a given provider."""
    result = await db.execute(
        select(ProviderTariffProduct)
        .where(ProviderTariffProduct.provider_id == provider_id)
        .order_by(ProviderTariffProduct.name)
    )
    return [TariffProductResponse.model_validate(p) for p in result.scalars().all()]


@router.get("/locations/search")
async def search_locations(query: str = ""):
    """Search municipalities/postcodes. Returns demo data in MVP."""
    demo_locations = [
        {"id": "351", "name": "Bern", "postcode": "3007", "canton": "BE", "operator": "BKW", "operator_id": "bkw"},
        {"id": "261", "name": "Zürich", "postcode": "8001", "canton": "ZH", "operator": "EKZ", "operator_id": "ekz"},
        {"id": "2196", "name": "Luzern", "postcode": "6003", "canton": "LU", "operator": "CKW", "operator_id": "ckw"},
        {"id": "2311", "name": "Fribourg", "postcode": "1700", "canton": "FR", "operator": "Groupe E", "operator_id": "groupe-e"},
        {"id": "2762", "name": "Basel", "postcode": "4001", "canton": "BS", "operator": "Primeo", "operator_id": "primeo"},
    ]
    if query:
        q = query.lower()
        demo_locations = [loc for loc in demo_locations if q in loc["name"].lower() or q in loc["postcode"]]
    return demo_locations
