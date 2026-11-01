import uuid
from datetime import datetime

from sqlalchemy import Boolean, DateTime, Integer, String, Text, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.session import Base


class Provider(Base):
    __tablename__ = "providers"

    id: Mapped[str] = mapped_column(String(50), primary_key=True)
    slug: Mapped[str] = mapped_column(String(50), unique=True, nullable=False)
    name: Mapped[str] = mapped_column(String(200), nullable=False)
    territory: Mapped[str | None] = mapped_column(String(200), nullable=True)
    docs_url: Mapped[str | None] = mapped_column(Text, nullable=True)
    license_status: Mapped[str] = mapped_column(String(30), default="unknown")
    publication_time_local: Mapped[str | None] = mapped_column(String(10), nullable=True)
    native_granularity_minutes: Mapped[int | None] = mapped_column(Integer, nullable=True)
    active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    products = relationship("ProviderTariffProduct", back_populates="provider", lazy="selectin")


class ProviderTariffProduct(Base):
    __tablename__ = "provider_tariff_products"

    id: Mapped[str] = mapped_column(String(50), primary_key=True)
    provider_id: Mapped[str] = mapped_column(String(50), nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(200), nullable=False)
    tariff_type: Mapped[str] = mapped_column(String(30), nullable=False)
    eligible_from: Mapped[str | None] = mapped_column(String(10), nullable=True)
    eligible_to: Mapped[str | None] = mapped_column(String(10), nullable=True)
    requires_ems: Mapped[bool] = mapped_column(Boolean, default=False)
    requires_smart_meter: Mapped[bool] = mapped_column(Boolean, default=False)
    eligibility_text: Mapped[str | None] = mapped_column(Text, nullable=True)
    official_url: Mapped[str | None] = mapped_column(Text, nullable=True)
    is_selectable: Mapped[bool] = mapped_column(Boolean, default=True)
    interval_minutes: Mapped[int | None] = mapped_column(Integer, nullable=True)
    scope: Mapped[str] = mapped_column(String(30), default="FULL")
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    provider = relationship("Provider", back_populates="products")
