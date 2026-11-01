import uuid
from datetime import datetime

from sqlalchemy import DateTime, String, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.session import Base


class User(Base):
    __tablename__ = "users"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email: Mapped[str] = mapped_column(String(255), unique=True, nullable=False, index=True)
    auth_subject: Mapped[str | None] = mapped_column(String(255), unique=True, nullable=True)
    locale: Mapped[str] = mapped_column(String(10), default="de-CH")
    timezone: Mapped[str] = mapped_column(String(50), default="Europe/Zurich")
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    deleted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)

    households = relationship("Household", back_populates="owner", lazy="selectin")
    consents = relationship("Consent", back_populates="user", lazy="selectin")
    notification_preferences = relationship("NotificationPreference", back_populates="user", lazy="selectin")


class Consent(Base):
    __tablename__ = "consents"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    consent_version: Mapped[str] = mapped_column(String(20), nullable=False)
    consent_type: Mapped[str] = mapped_column(String(50), nullable=False)
    accepted_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    withdrawn_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)

    user = relationship("User", back_populates="consents")
