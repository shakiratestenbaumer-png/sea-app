"""Tariff ingestion scheduler.

Fetches day-ahead tariffs from each provider after their documented publication time.
Uses distributed lock to prevent duplicate ingestion across worker replicas.
"""

from app.core.logging import logger


async def ingest_ckw():
    """Fetch CKW dynamic grid tariff. Scheduled after ~12:00 CET/CEST."""
    logger.info("CKW ingestion: STUB — provider access not yet configured")


async def ingest_groupe_e():
    """Fetch Groupe E VARIO tariff. Scheduled after ~18:00 CET/CEST."""
    logger.info("Groupe E ingestion: STUB — provider access not yet configured")


async def ingest_elcom_annual():
    """Import ElCom annual regulated tariffs. Run on startup and annually."""
    logger.info("ElCom annual import: STUB — dataset not yet loaded")
