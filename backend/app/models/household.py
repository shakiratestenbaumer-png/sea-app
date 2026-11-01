import uuid
from datetime import datetime

from sqlalchemy import DateTime, Integer, Numeric, String, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.session import Base


class Household(Base):
    __tablename__ = "households"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    owner_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    label: Mapped[str] = mapped_column(String(100), default="Mein Zuhause")
    postal_code: Mapped[str | None] = mapped_column(String(10), nullable=True)
    municipality_id: Mapped[str | None] = mapped_column(String(50), nullable=True)
    municipality_name: Mapped[str | None] = mapped_column(String(200), nullable=True)
    distribution_operator_id: Mapped[str | None] = mapped_column(String(50), nullable=True)
    distribution_operator_name: Mapped[str | None] = mapped_column(String(200), nullable=True)
    provider_id: Mapped[str | None] = mapped_column(String(50), nullable=True)
    tariff_product_id: Mapped[str | None] = mapped_column(String(50), nullable=True)
    enrollment_status: Mapped[str] = mapped_column(String(20), default="unknown")
    annual_kwh_estimate: Mapped[int | None] = mapped_column(Integer, nullable=True)
    has_smart_meter: Mapped[bool | None] = mapped_column(nullable=True)
    has_solar: Mapped[bool | None] = mapped_column(nullable=True)
    has_battery: Mapped[bool | None] = mapped_column(nullable=True)
    has_ev: Mapped[bool | None] = mapped_column(nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    owner = relationship("User", back_populates="households")
    appliances = relationship("Appliance", back_populates="household", lazy="selectin")
