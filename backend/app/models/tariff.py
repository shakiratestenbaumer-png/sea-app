import uuid
from datetime import datetime
from decimal import Decimal

from sqlalchemy import Boolean, DateTime, Integer, Numeric, String, Text, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db.session import Base


class TariffImportBatch(Base):
    __tablename__ = "tariff_import_batches"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    provider_id: Mapped[str] = mapped_column(String(50), nullable=False, index=True)
    product_id: Mapped[str] = mapped_column(String(50), nullable=False, index=True)
    requested_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    published_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    fetched_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    checksum: Mapped[str | None] = mapped_column(String(64), nullable=True)
    source_url: Mapped[str | None] = mapped_column(Text, nullable=True)
    schema_version: Mapped[str | None] = mapped_column(String(20), nullable=True)
    status: Mapped[str] = mapped_column(String(20), default="pending")
    error: Mapped[str | None] = mapped_column(Text, nullable=True)


class TariffInterval(Base):
    __tablename__ = "tariff_intervals"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    batch_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    product_id: Mapped[str] = mapped_column(String(50), nullable=False, index=True)
    component: Mapped[str] = mapped_column(String(30), nullable=False)
    start_utc: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    end_utc: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    price_chf_per_kwh: Mapped[Decimal] = mapped_column(Numeric(14, 6), nullable=False)
    tax_included: Mapped[bool] = mapped_column(Boolean, default=False)
    quality: Mapped[str] = mapped_column(String(20), default="ACTUAL")
    source_timezone: Mapped[str] = mapped_column(String(50), default="Europe/Zurich")


class TariffFixedComponent(Base):
    __tablename__ = "tariff_fixed_components"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    product_id: Mapped[str] = mapped_column(String(50), nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    amount_chf: Mapped[Decimal] = mapped_column(Numeric(10, 2), nullable=False)
    period: Mapped[str] = mapped_column(String(10), default="YEAR")
    tax_included: Mapped[bool] = mapped_column(Boolean, default=False)
    valid_from: Mapped[str | None] = mapped_column(String(10), nullable=True)
    valid_to: Mapped[str | None] = mapped_column(String(10), nullable=True)
    source_url: Mapped[str | None] = mapped_column(Text, nullable=True)


class RegulatedTariffAnnual(Base):
    __tablename__ = "regulated_tariff_annual"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    year: Mapped[int] = mapped_column(Integer, nullable=False, index=True)
    municipality_id: Mapped[str] = mapped_column(String(50), nullable=False, index=True)
    municipality_name: Mapped[str | None] = mapped_column(String(200), nullable=True)
    operator_id: Mapped[str | None] = mapped_column(String(50), nullable=True)
    operator_name: Mapped[str | None] = mapped_column(String(200), nullable=True)
    tariff_product: Mapped[str | None] = mapped_column(String(100), nullable=True)
    consumption_category: Mapped[str] = mapped_column(String(10), default="H4")
    energy_rp_kwh: Mapped[Decimal | None] = mapped_column(Numeric(10, 2), nullable=True)
    grid_rp_kwh: Mapped[Decimal | None] = mapped_column(Numeric(10, 2), nullable=True)
    metering_chf_year: Mapped[Decimal | None] = mapped_column(Numeric(10, 2), nullable=True)
    levies_rp_kwh: Mapped[Decimal | None] = mapped_column(Numeric(10, 2), nullable=True)
    base_chf_year: Mapped[Decimal | None] = mapped_column(Numeric(10, 2), nullable=True)
    total_rp_kwh: Mapped[Decimal | None] = mapped_column(Numeric(10, 2), nullable=True)
    provider_source: Mapped[str | None] = mapped_column(String(200), nullable=True)
    raw_record_hash: Mapped[str | None] = mapped_column(String(64), nullable=True)
