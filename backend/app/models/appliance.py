import uuid
from datetime import datetime
from decimal import Decimal

from sqlalchemy import Boolean, DateTime, Integer, Numeric, String, Text, func
from sqlalchemy.dialects.postgresql import JSON, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.session import Base


class Appliance(Base):
    __tablename__ = "appliances"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    household_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    type: Mapped[str] = mapped_column(String(30), nullable=False)
    display_name: Mapped[str] = mapped_column(String(100), nullable=False)
    duration_minutes: Mapped[int] = mapped_column(Integer, nullable=False)
    energy_kwh: Mapped[Decimal] = mapped_column(Numeric(8, 3), nullable=False)
    profile_json: Mapped[dict | None] = mapped_column(JSON, nullable=True)
    earliest_start_local: Mapped[str | None] = mapped_column(String(5), nullable=True)
    latest_finish_local: Mapped[str | None] = mapped_column(String(5), nullable=True)
    allowed_weekdays: Mapped[str | None] = mapped_column(String(20), nullable=True)
    notification_lead_minutes: Mapped[int] = mapped_column(Integer, default=15)
    must_be_home: Mapped[bool] = mapped_column(Boolean, default=False)
    quiet_hours_policy: Mapped[str | None] = mapped_column(String(20), nullable=True)
    needs_manual_start: Mapped[bool] = mapped_column(Boolean, default=True)
    preferred_baseline_start: Mapped[str | None] = mapped_column(String(5), nullable=True)
    load_shiftable: Mapped[bool] = mapped_column(Boolean, default=True)
    can_pause: Mapped[bool] = mapped_column(Boolean, default=False)
    active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    household = relationship("Household", back_populates="appliances")


class Recommendation(Base):
    __tablename__ = "recommendations"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    household_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    appliance_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    tariff_batch_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    run_date: Mapped[str] = mapped_column(String(10), nullable=False)
    best_start_utc: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    best_end_utc: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    modeled_cost_chf: Mapped[Decimal | None] = mapped_column(Numeric(10, 4), nullable=True)
    baseline_cost_chf: Mapped[Decimal | None] = mapped_column(Numeric(10, 4), nullable=True)
    potential_savings_chf: Mapped[Decimal | None] = mapped_column(Numeric(10, 4), nullable=True)
    priced_components: Mapped[str | None] = mapped_column(String(100), nullable=True)
    confidence: Mapped[str] = mapped_column(String(20), default="modeled")
    data_quality: Mapped[str | None] = mapped_column(String(20), nullable=True)
    alternatives_json: Mapped[dict | None] = mapped_column(JSON, nullable=True)
    state: Mapped[str] = mapped_column(String(20), default="active")
    calculated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
