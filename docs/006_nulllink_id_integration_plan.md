# 006 — NullLink ID Integration Plan

**Version:** 1.0
**Date:** 1 November 2026
**Project:** Swiss Energy Assistant (SEA)

---

## Table of Contents

1. [Why User Identity?](#1-why-user-identity)
2. [Why NullLink ID?](#2-why-nulllink-id)
3. [Integration Architecture](#3-integration-architecture)
4. [Implementation Plan](#4-implementation-plan)
5. [Privacy Benefits](#5-privacy-benefits)
6. [Future Hardware Use Cases](#6-future-hardware-use-cases)

---

## 1. Why User Identity?

Currently SEA stores all data locally on the user's device. This works for the MVP, but limits us for:

| Feature | Requires Identity? | Why |
|---------|-------------------|-----|
| Price viewing | ❌ No | Public API data |
| Appliance management | ❌ No | Local storage is fine |
| Push notifications (FCM) | ✅ Yes | Need to map token to user |
| Subscription/paywall | ✅ Yes | Need to verify payment |
| Cross-device sync | ✅ Yes | Need server-side data |
| Smart plug control | ✅ Yes | Need authenticated commands |
| Solar panel integration | ✅ Yes | Need persistent config |
| Energy savings history | ✅ Yes | Need time-series storage |
| Multi-user household | ✅ Yes | Need shared household |

**Conclusion:** Identity becomes necessary for the Premium tier and hardware integrations. But we don't want to force Google/Facebook login on privacy-conscious Swiss users.

## 2. Why NullLink ID?

NullLink ID (from Myrax Core's NullLink product) provides zero-knowledge authentication:

### Advantages for SEA

| Feature | Traditional OAuth | NullLink ID |
|---------|------------------|-------------|
| Privacy | Google sees your energy data | **Zero-knowledge** — server never sees credentials |
| Swiss trust | US company | **Swiss company (Myrax Core GmbH)** |
| No email required | Needs Google/Apple account | **Just NL-ID + passphrase** |
| Cross-product | Siloed per provider | **Same NL-ID across all Myrax products** |
| Hardware ready | Needs OAuth refresh flow | **Ed25519 signing works offline** |
| GDPR/DSG | Complex consent flows | **User owns keys, minimal data** |

### How It Works

1. User creates or already has a NullLink ID (`nl_XBBW8f2R...`)
2. User opens SEA → taps "Sign in with LinkID"
3. SEA backend sends challenge to NullLink vault (`nulllink.ch`)
4. User signs challenge with their private key (client-side)
5. SEA backend verifies signature → issues session token
6. No personal data exchanged — just cryptographic proof

### NullLink Infrastructure

- **Vault URL:** `https://nulllink.ch`
- **Challenge endpoint:** `POST /api/auth/challenge`
- **Verify endpoint:** `POST /api/auth/verify`
- **Discovery:** `GET /.well-known/nlid-configuration`
- **Both products on same VPS** — low latency

## 3. Integration Architecture

```
┌─────────────┐     ┌─────────────┐     ┌────────────────┐
│  SEA Mobile  │────▶│  SEA Backend │────▶│  NullLink Vault │
│  (Flutter)   │     │  (FastAPI)   │     │  (nulllink.ch) │
│              │     │              │     │                │
│ NL-ID input  │     │ /auth/login  │     │ /auth/challenge│
│ Passphrase   │     │ /auth/verify │     │ /auth/verify   │
│ Sign locally │     │ JWT session  │     │ Ed25519 verify │
└─────────────┘     └─────────────┘     └────────────────┘
```

### SEA Backend Changes Needed

New endpoints in `backend/app/api/v1/auth.py`:

```python
POST /api/v1/auth/challenge
  Body: {"nlid": "nl_XBBW8f2R..."}
  → Backend calls NullLink vault /api/auth/challenge
  → Returns: {"challenge_id": "...", "nonce": "..."}

POST /api/v1/auth/verify
  Body: {"challenge_id": "...", "nlid": "...", "signature": "..."}
  → Backend calls NullLink vault /api/auth/verify
  → If verified, create/lookup SEA user, issue JWT
  → Returns: {"token": "eyJ...", "user": {"nlid": "nl_...", "created_at": "..."}}

GET /api/v1/me
  Headers: Authorization: Bearer eyJ...
  → Returns user profile, appliances, household, prefs

PUT /api/v1/me/household
PUT /api/v1/me/appliances
PUT /api/v1/me/prefs
  → Sync local data to server
```

### Database Schema

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nlid VARCHAR(64) UNIQUE NOT NULL,
  public_key VARCHAR(128),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  last_seen_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE user_households (
  user_id UUID REFERENCES users(id),
  postal_code VARCHAR(10),
  municipality VARCHAR(100),
  provider_id VARCHAR(20),
  PRIMARY KEY (user_id)
);

CREATE TABLE user_appliances (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  type VARCHAR(30) NOT NULL,
  display_name VARCHAR(100),
  duration_minutes INT,
  energy_kwh DECIMAL(6,2),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE user_push_tokens (
  user_id UUID REFERENCES users(id),
  platform VARCHAR(10), -- 'android', 'ios', 'web'
  token TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

## 4. Implementation Plan

### Phase 1 — Optional Sign-in (Week 1)
- Add "Sign in with LinkID" button to Settings screen
- Backend: challenge/verify endpoints
- If signed in: sync appliances + household to server
- If not signed in: everything works as before (local only)

### Phase 2 — Premium Gating (Week 2)
- Add subscription status to user record
- Gate push notifications behind sign-in
- Implement Google Play billing verification

### Phase 3 — Hardware Integration (Week 3+)
- Signed users can add smart plug credentials
- Solar panel API tokens stored server-side (encrypted)
- Scheduled optimization jobs per user

## 5. Privacy Benefits

NullLink ID aligns perfectly with SEA's privacy stance:

- **No email required** — user stays anonymous
- **No password on our server** — zero-knowledge vault
- **User owns identity** — can't be locked out
- **Swiss jurisdiction** — both services in Switzerland
- **Minimal data** — we only store NL-ID + appliance/household config
- **DSG compliant** — no personal data beyond what user provides

This is a **selling point**: "Sign in anonymously with NullLink ID — no email, no password, no tracking."

## 6. Future Hardware Use Cases

With authenticated users, we enable:

| Feature | Requires | NullLink Advantage |
|---------|----------|-------------------|
| Smart plug commands | Authenticated WebSocket | Ed25519-signed commands |
| Solar panel scheduling | Server-side cron jobs | User-owned encryption |
| Multi-home management | User-scoped data | Single identity, multiple homes |
| Energy trading (future) | Legal identity | NullLink verified credentials |
| Household sharing | Invite by NL-ID | No email exchange needed |

---

## Decision

**Recommendation:** Implement NullLink ID as the sole authentication method for SEA. No traditional OAuth. This differentiates us and aligns with Swiss privacy expectations.

**Timeline:** After Play Store launch. The current local-only mode is sufficient for v1.0.

**Priority:** P1 — implement before hardware integrations (solar/smart plugs).
