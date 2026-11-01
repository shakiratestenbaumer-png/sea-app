import uuid
from datetime import datetime

from sqlalchemy import Boolean, DateTime, Integer, String, Text, func
from sqlalchemy.dialects.postgresql import JSON, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.session import Base


class NotificationPreference(Base):
    __tablename__ = "notification_preferences"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    channel: Mapped[str] = mapped_column(String(20), default="push")
    enabled: Mapped[bool] = mapped_column(Boolean, default=True)
    daily_digest: Mapped[bool] = mapped_column(Boolean, default=True)
    daily_digest_local_time: Mapped[str | None] = mapped_column(String(5), nullable=True, default="19:00")
    reminder_lead_minutes: Mapped[int] = mapped_column(Integer, default=15)
    quiet_hours_start: Mapped[str | None] = mapped_column(String(5), nullable=True, default="22:00")
    quiet_hours_end: Mapped[str | None] = mapped_column(String(5), nullable=True, default="07:00")
    push_token_ref: Mapped[str | None] = mapped_column(Text, nullable=True)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    user = relationship("User", back_populates="notification_preferences")


class NotificationOutbox(Base):
    __tablename__ = "notification_outbox"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    channel: Mapped[str] = mapped_column(String(20), default="push")
    dedupe_key: Mapped[str] = mapped_column(String(200), unique=True, nullable=False)
    payload_json: Mapped[dict] = mapped_column(JSON, nullable=False)
    scheduled_utc: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    sent_utc: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    status: Mapped[str] = mapped_column(String(20), default="pending")
    attempts: Mapped[int] = mapped_column(Integer, default=0)
    last_error: Mapped[str | None] = mapped_column(Text, nullable=True)
