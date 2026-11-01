"""Abstract base class for all provider adapters."""

from abc import ABC, abstractmethod
from dataclasses import dataclass
from datetime import datetime
from decimal import Decimal
from enum import Enum


class Component(str, Enum):
    ENERGY = "ENERGY"
    GRID_USAGE = "GRID_USAGE"
    LEVY = "LEVY"
    VAT = "VAT"
    EXPORT_REWARD = "EXPORT_REWARD"
    METERING = "METERING"
    COMMUNAL_TAX = "COMMUNAL_TAX"
    OTHER = "OTHER"


class LicenseStatus(str, Enum):
    APPROVED_PUBLIC = "approved_public"
    PERMISSION_REQUIRED = "permission_required"
    NO_REPUBLICATION = "no_republication"
    UNKNOWN = "unknown"
    NEEDS_ACCESS = "needs_access"


@dataclass(frozen=True)
class PriceInterval:
    start_utc: datetime
    end_utc: datetime
    component: Component
    chf_per_kwh: Decimal
    tax_included: bool
    quality: str
    source_id: str


class ProviderAdapter(ABC):
    provider_id: str
    provider_name: str
    license_status: LicenseStatus

    @abstractmethod
    async def fetch(
        self, product_id: str, start_utc: datetime, end_utc: datetime
    ) -> list[PriceInterval]:
        raise NotImplementedError

    @abstractmethod
    async def health(self) -> dict:
        raise NotImplementedError
