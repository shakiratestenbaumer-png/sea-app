from fastapi import APIRouter

from app.api.v1 import auth, providers, tariffs, appliances, recommendations, comparisons, alerts, admin

api_router = APIRouter(prefix="/api/v1")

api_router.include_router(auth.router, tags=["Auth"])
api_router.include_router(providers.router, tags=["Providers"])
api_router.include_router(tariffs.router, tags=["Tariffs"])
api_router.include_router(appliances.router, tags=["Appliances"])
api_router.include_router(recommendations.router, tags=["Recommendations"])
api_router.include_router(comparisons.router, tags=["Comparisons"])
api_router.include_router(alerts.router, tags=["Notifications"])
api_router.include_router(admin.router, tags=["Admin"])
