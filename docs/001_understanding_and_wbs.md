# 001 — Swiss Energy Assistant: Understanding Document & Work Breakdown Structure

**Version:** 1.0  
**Created:** 28 October 2026  
**Author:** Project AI Architect  
**Source:** `swiss_energy_assistant_master_spec.md`, `swiss_energy_assistant_lovable_spec.md`, Figma snapshots  
**Target Platform:** Flutter mobile app (iOS + Android) with FastAPI backend  
**Decision:** Next.js replaces Flutter/React-Capacitor as the frontend framework per stakeholder preference  

---

## TABLE OF CONTENTS

1. [Executive Understanding](#1-executive-understanding)
2. [Market Context & Regulatory Landscape](#2-market-context--regulatory-landscape)
3. [Customer Segments & Value Proposition](#3-customer-segments--value-proposition)
4. [Product Vision & Scope Boundaries](#4-product-vision--scope-boundaries)
5. [Technical Architecture Overview](#5-technical-architecture-overview)
6. [Figma Design Analysis](#6-figma-design-analysis)
7. [Swiss Energy Provider API Landscape](#7-swiss-energy-provider-api-landscape)
8. [Daily Price Update Regulation (Jan 2027)](#8-daily-price-update-regulation-jan-2027)
9. [Future: Solar Panels, Home Automation & IoT](#9-future-solar-panels-home-automation--iot)
10. [Complete Work Breakdown Structure (WBS)](#10-complete-work-breakdown-structure-wbs)
11. [Implementation Phases & Timeline](#11-implementation-phases--timeline)
12. [Risk Register Summary](#12-risk-register-summary)
13. [Decision Log](#13-decision-log)

---

## 1. Executive Understanding

### What are we building?

**Swiss Energy Assistant** is a mobile-first electricity tariff intelligence application for Swiss households. The app provides:

- **Real-time day-ahead tariff visibility** — showing tomorrow's electricity prices at the provider's native granularity (hourly or 15-minute intervals)
- **Appliance scheduling recommendations** — calculating the cheapest time window to run dishwashers, washing machines, dryers, and EV chargers based on actual tariff data
- **Tariff comparison** — both actionable local plan comparisons and informational Switzerland-wide benchmarks
- **Push notification digests** — daily summaries and appliance-specific reminders
- **Bill explainer** — breaking down electricity cost components (energy, network, metering, levies, VAT, fixed fees)

### What are we NOT building (in MVP)?

- No automated appliance control or smart-home switching
- No solar panel integration or battery dispatch
- No wholesale electricity trading
- No proprietary electrical hardware
- No real-time meter reading
- No supplier switching marketplace (Swiss households <100 MWh/year generally cannot freely switch)

### Core Principle

> "Software first, advice before automation, no proprietary electrical hardware in MVP."

The product is a **notification and intelligence layer** — it tells you *when* to run your appliances, it doesn't run them for you.

---

## 2. Market Context & Regulatory Landscape

### Swiss Electricity Market — Key Facts

| Fact | Detail |
|------|--------|
| **Supplier lock-in** | Residential customers (<100 MWh/year) generally cannot switch suppliers; they are served by their local basic-supply provider (ElCom) |
| **Tariff types** | Fixed, HT/NT (high/low time-of-use), and newer dynamic tariffs |
| **Dynamic tariffs** | Not universal — only offered by select providers to enrolled customers |
| **Smart meter requirement** | Some dynamic tariffs require a communicating smart meter and/or a compatible EMS |
| **Jan 2027 regulation** | New regulations around PV feed-in remuneration and tariff transparency; daily price updates for dynamic tariff providers |
| **Price components** | Energy, network/grid usage, metering, levies, communal tax, VAT, fixed base fees — each component may come from different sources |

### Supported Energy Providers (Initial)

| Provider | Tariff Type | Resolution | Publication | Key Constraint |
|----------|-------------|------------|-------------|----------------|
| **CKW** | Dynamic network | Hourly | ~12:00 day-ahead | Recommends EMS, warns costs may rise |
| **Groupe E VARIO** | Dynamic (15-min) | 15-minute | ~18:00 day-ahead | API via Azure API management |
| **EKZ** | Dynamic (15-min) | 15-minute | Day-ahead | **Requires** smart meter + compatible EMS |
| **Primeo Dynamisch** | Dynamic energy + network (hourly) | Hourly | ~18:00 day-ahead (from 2027) | **Requires** compatible EMS + smart meter |
| **ElCom** | Annual regulated | Annual | Annual dataset | Reference/comparison data, not live pricing |

### Critical Regulatory Nuance

Our app is a **notification/advice tool**, NOT an Energy Management System (EMS). Providers like EKZ and Primeo require a compatible EMS for enrollment in their dynamic tariffs. We must:
- Never market the app as an EMS
- Clearly show eligibility status for each tariff product
- Mark `INELIGIBLE` or `EMS REQUIRED` where applicable
- Target CKW and Groupe E first (more manual-friendly)

---

## 3. Customer Segments & Value Proposition

### Segment A — Dynamic Tariff Households (Primary, highest value)
- Already enrolled in CKW dynamic, Groupe E VARIO, or similar
- Can manually shift dishwasher/washer/dryer/EV charging
- **Value:** Real CHF savings by timing appliance use to cheapest price windows

### Segment B — HT/NT (High/Low) Tariff Households (Broad reach)
- On traditional time-of-use tariffs
- Lower savings potential but much larger addressable market
- **Value:** Clear guidance on when HT vs NT rates apply, simple scheduling

### Segment C — Bill Transparency Seekers
- Want to understand their electricity bill breakdown
- Interested in how their costs compare to other municipalities
- **Value:** Education, transparency, benchmark comparisons

### Future Segments
- PV + battery owners (solar surplus optimization)
- EV drivers (smart charging recommendations)
- Installers and energy software vendors (B2B API)

---

## 4. Product Vision & Scope Boundaries

### MVP Feature Map

```
┌─────────────────────────────────────────────────────────────────┐
│                    SWISS ENERGY ASSISTANT MVP                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────────────┐     │
│  │  Onboarding  │  │  Dashboard   │  │  Tariff Comparison  │     │
│  │             │  │              │  │                     │     │
│  │ • Language   │  │ • Hero card  │  │ • Local eligible    │     │
│  │ • Postcode   │  │ • Price chart│  │   tariff options    │     │
│  │ • Provider   │  │ • Appliance  │  │ • Swiss-wide        │     │
│  │ • Tariff     │  │   cards      │  │   benchmarks (info) │     │
│  │ • Appliances │  │ • Breakdown  │  │ • Annual ElCom data │     │
│  │ • Alerts     │  │ • Alerts     │  │                     │     │
│  └─────────────┘  └──────────────┘  └─────────────────────┘     │
│                                                                   │
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────────────┐     │
│  │ Appliance   │  │ Notification │  │  Settings &         │     │
│  │ Scheduler   │  │ Engine       │  │  Account            │     │
│  │             │  │              │  │                     │     │
│  │ • Add/edit  │  │ • Daily      │  │ • Profile           │     │
│  │ • Duration  │  │   digest     │  │ • Subscription      │     │
│  │ • Deadlines │  │ • Reminders  │  │ • Privacy/consent   │     │
│  │ • Best start│  │ • Quiet hrs  │  │ • Data export       │     │
│  │ • Cost est. │  │ • Push/local │  │ • Delete account    │     │
│  └─────────────┘  └──────────────┘  └─────────────────────┘     │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

### Explicitly OUT of MVP Scope

| Feature | Phase | Notes |
|---------|-------|-------|
| Solar panel integration | Stage 6 (month 5-8) | Read-only first, then manual recommendations |
| Battery dispatch/control | Stage 7 (month 8+) | Requires manufacturer-approved APIs |
| Smart home switching | Stage 7 (month 8+) | Safety-critical, requires approvals |
| EV smart charging control | Stage 6-7 | Read monitoring first |
| Own hardware (DIN-rail, ESP32) | After product-market fit | Regulatory compliance needed (NEV/ESTI) |
| Wholesale trading/EPEX | Stage 5+ | Licensing required |
| OCR bill scanning | Stage 5 | Manual entry first |
| AI/ML price prediction | Future | Deterministic optimization first |

---

## 5. Technical Architecture Overview

### Decision: Flutter Instead of React/Capacitor

The master spec proposed React + Vite + Capacitor. Per stakeholder preference, we will use **Flutter** for the mobile application. This provides:

- True native performance on both iOS and Android
- Single codebase with native compilation
- Rich widget library for charts and data visualization
- Better push notification handling via native plugins
- Easier offline-first patterns
- Can still serve web (Flutter Web) for PWA if needed

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         CLIENTS                                  │
│                                                                   │
│   ┌──────────┐    ┌──────────┐    ┌──────────┐                  │
│   │ Flutter   │    │ Flutter   │    │ Flutter   │                  │
│   │ Android   │    │ iOS       │    │ Web (PWA) │                  │
│   └────┬─────┘    └────┬─────┘    └────┬─────┘                  │
│        │               │               │                          │
│        └───────────────┼───────────────┘                          │
│                        │ HTTPS / REST                             │
├────────────────────────┼────────────────────────────────────────┤
│                   BACKEND (FastAPI)                               │
│                        │                                          │
│   ┌────────────────────┼────────────────────────────────┐        │
│   │              API Gateway (v1)                        │        │
│   │  /auth  /providers  /tariffs  /appliances            │        │
│   │  /recommendations  /comparisons  /notifications      │        │
│   │  /billing  /admin                                    │        │
│   └────────────────────┼────────────────────────────────┘        │
│                        │                                          │
│   ┌────────────┐ ┌────┴──────┐ ┌────────────┐ ┌──────────┐     │
│   │ Tariff     │ │ Optimizer │ │ Comparison │ │ Notif.   │     │
│   │ Normalizer │ │ Engine    │ │ Engine     │ │ Scheduler│     │
│   └──────┬─────┘ └───────────┘ └────────────┘ └──────────┘     │
│          │                                                        │
│   ┌──────┴──────────────────────────────────────────────┐        │
│   │            Provider Adapters                         │        │
│   │  ┌─────┐ ┌─────────┐ ┌─────┐ ┌───────┐ ┌───────┐  │        │
│   │  │ CKW │ │Groupe E │ │ EKZ │ │Primeo │ │ElCom  │  │        │
│   │  └─────┘ └─────────┘ └─────┘ └───────┘ └───────┘  │        │
│   └─────────────────────────────────────────────────────┘        │
│                                                                   │
├──────────────────────────────────────────────────────────────────┤
│                     DATA LAYER                                    │
│                                                                   │
│   ┌──────────────┐  ┌────────────┐  ┌─────────────────┐         │
│   │ PostgreSQL   │  │ Redis      │  │ Object Storage  │         │
│   │ (Primary DB) │  │ (Cache/Q)  │  │ (optional)      │         │
│   └──────────────┘  └────────────┘  └─────────────────┘         │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
```

### Technology Stack

| Layer | Technology | Notes |
|-------|-----------|-------|
| **Mobile** | Flutter 3.x + Dart | Single codebase for iOS, Android, Web |
| **State Management** | Riverpod / Bloc | TBD based on team preference |
| **Charts** | fl_chart / syncfusion_flutter_charts | Step-line charts for tariff visualization |
| **Push Notifications** | firebase_messaging + flutter_local_notifications | FCM for remote, local for device reminders |
| **HTTP Client** | dio + retrofit | Typed API client generation |
| **Localization** | flutter_localizations + intl | DE (default), FR, EN |
| **Backend** | Python 3.12+, FastAPI, Pydantic v2 | Modular monolith |
| **ORM** | SQLAlchemy 2 + Alembic | Migrations, async support |
| **Database** | PostgreSQL 16 | DECIMAL for currency, UUID PKs, timestamptz |
| **Task Queue** | APScheduler (dev) → Celery/Arq (prod) | Tariff ingestion, notifications |
| **Auth** | JWT/JWKS (Supabase Auth or equivalent) | No homegrown crypto |
| **Infra** | Docker Compose (local), Caddy/nginx (HTTPS) | CI/CD via GitHub Actions |
| **Monitoring** | Sentry + OpenTelemetry | Error tracking, performance |

### Monorepo Structure

```
swiss-energy-assistant/
├── docs/
│   ├── 001_understanding_and_wbs.md          ← THIS DOCUMENT
│   ├── PRODUCT_SPEC.md                       ← Master spec (copy)
│   ├── API_CONTRACT.md                       ← OpenAPI documentation
│   ├── API_PROVIDERS.md                      ← Provider integration details
│   ├── RISK_REGISTER.md                      ← Risk tracking
│   └── LOVABLE_PROMPT.md                     ← Frontend reference prompt
│
├── backend/
│   ├── app/
│   │   ├── main.py                           ← FastAPI app entry
│   │   ├── core/
│   │   │   ├── config.py                     ← Settings from env
│   │   │   ├── security.py                   ← JWT verification
│   │   │   ├── logging.py                    ← Structured logging
│   │   │   └── clock.py                      ← Timezone-aware utilities
│   │   ├── api/v1/
│   │   │   ├── auth.py
│   │   │   ├── providers.py
│   │   │   ├── tariffs.py
│   │   │   ├── appliances.py
│   │   │   ├── recommendations.py
│   │   │   ├── comparisons.py
│   │   │   ├── alerts.py
│   │   │   ├── billing.py
│   │   │   └── admin.py
│   │   ├── models/
│   │   │   ├── user.py
│   │   │   ├── household.py
│   │   │   ├── provider.py
│   │   │   ├── tariff.py
│   │   │   ├── appliance.py
│   │   │   ├── notification.py
│   │   │   └── subscription.py
│   │   ├── schemas/                          ← Pydantic request/response models
│   │   ├── services/
│   │   │   ├── tariff_normalizer.py
│   │   │   ├── optimizer.py
│   │   │   ├── cost_calculator.py
│   │   │   ├── comparison_engine.py
│   │   │   └── notification_scheduler.py
│   │   ├── integrations/providers/
│   │   │   ├── base.py                       ← Abstract ProviderAdapter
│   │   │   ├── ckw.py
│   │   │   ├── groupe_e.py
│   │   │   ├── ekz.py
│   │   │   ├── primeo.py
│   │   │   ├── elcom.py
│   │   │   └── fixtures.py                   ← Mock/demo data adapters
│   │   ├── jobs/
│   │   │   ├── ingest.py                     ← Tariff fetch scheduler
│   │   │   ├── reconcile.py                  ← Data validation
│   │   │   ├── digest.py                     ← Daily summary sender
│   │   │   └── cleanup.py                    ← Data retention
│   │   └── db/
│   │       ├── session.py
│   │       └── migrations/                   ← Alembic
│   ├── tests/
│   │   ├── unit/
│   │   ├── integration/
│   │   ├── fixtures/
│   │   └── contract/
│   ├── Dockerfile
│   └── pyproject.toml
│
├── mobile/                                   ← Flutter app
│   ├── lib/
│   │   ├── main.dart
│   │   ├── app.dart
│   │   ├── core/
│   │   │   ├── config/
│   │   │   │   ├── app_config.dart
│   │   │   │   ├── theme.dart
│   │   │   │   └── routes.dart
│   │   │   ├── constants/
│   │   │   │   ├── api_constants.dart
│   │   │   │   └── app_constants.dart
│   │   │   ├── localization/
│   │   │   │   ├── app_localizations.dart
│   │   │   │   ├── de_ch.dart
│   │   │   │   ├── en.dart
│   │   │   │   └── fr.dart
│   │   │   └── utils/
│   │   │       ├── formatters.dart           ← CHF, Rp./kWh, Swiss formatting
│   │   │       ├── time_utils.dart           ← Europe/Zurich, DST handling
│   │   │       └── validators.dart
│   │   ├── data/
│   │   │   ├── api/
│   │   │   │   ├── api_client.dart           ← Dio/Retrofit typed client
│   │   │   │   ├── api_service.dart          ← Abstract API interface
│   │   │   │   └── mock_api_service.dart     ← Demo mode implementation
│   │   │   ├── models/                       ← Data classes / freezed models
│   │   │   │   ├── provider.dart
│   │   │   │   ├── tariff.dart
│   │   │   │   ├── appliance.dart
│   │   │   │   ├── recommendation.dart
│   │   │   │   ├── household.dart
│   │   │   │   ├── notification_prefs.dart
│   │   │   │   └── comparison.dart
│   │   │   └── repositories/                 ← Data access layer
│   │   │       ├── tariff_repository.dart
│   │   │       ├── appliance_repository.dart
│   │   │       └── user_repository.dart
│   │   ├── domain/
│   │   │   ├── services/
│   │   │   │   └── demo_optimizer.dart       ← Client-side demo calculations
│   │   │   └── entities/                     ← Domain entities if needed
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── dashboard_screen.dart     ← Main single-page dashboard
│   │   │   │   └── onboarding_screen.dart    ← Setup wizard
│   │   │   ├── widgets/
│   │   │   │   ├── layout/
│   │   │   │   │   ├── app_header.dart
│   │   │   │   │   └── bottom_nav.dart       ← Overview|Appliances|Compare|Alerts
│   │   │   │   ├── overview/
│   │   │   │   │   └── best_time_hero.dart
│   │   │   │   ├── prices/
│   │   │   │   │   ├── price_chart.dart      ← Step-line 24-48h chart
│   │   │   │   │   └── tariff_breakdown.dart
│   │   │   │   ├── appliances/
│   │   │   │   │   ├── appliance_card.dart
│   │   │   │   │   └── appliance_editor.dart
│   │   │   │   ├── comparisons/
│   │   │   │   │   ├── local_tariffs.dart
│   │   │   │   │   └── swiss_explorer.dart
│   │   │   │   ├── alerts/
│   │   │   │   │   └── notification_settings.dart
│   │   │   │   └── shared/
│   │   │   │       ├── data_status.dart
│   │   │   │       ├── demo_badge.dart
│   │   │   │       └── source_attribution.dart
│   │   │   └── state/                        ← Riverpod/Bloc providers
│   │   │       ├── tariff_provider.dart
│   │   │       ├── appliance_provider.dart
│   │   │       ├── household_provider.dart
│   │   │       └── notification_provider.dart
│   │   └── l10n/                             ← ARB files for intl
│   │       ├── app_de.arb
│   │       ├── app_en.arb
│   │       └── app_fr.arb
│   ├── test/
│   │   ├── widget/
│   │   ├── unit/
│   │   └── integration/
│   ├── android/
│   ├── ios/
│   ├── web/
│   ├── pubspec.yaml
│   └── analysis_options.yaml
│
├── docker-compose.yml
├── .env.example
├── .github/workflows/ci.yml
└── README.md
```

---

## 6. Figma Design Analysis

The Figma screenshots reveal a clean, professional Swiss energy dashboard with the following design language:

### Color Palette (extracted from Figma)
| Element | Color | Usage |
|---------|-------|-------|
| **Primary text** | `#152A2A` (dark charcoal) | Headings, body text |
| **Primary accent** | Teal/emerald (~`#0D9488` to `#14B8A6`) | Brand, CTAs, chart lines, active states |
| **Background** | White / `#FAFAFA` soft gray | Cards, page background |
| **Card surfaces** | White with subtle border | Appliance cards, comparison cards |
| **Warning/status** | Amber/orange | "Tarif selbst angegeben" (user-claimed tariff badge) |
| **Success** | Teal with checkmark | Push enabled, verified features |
| **DEMO badge** | Red/coral pill | Marking all sample data |

### Typography
- **Font:** Manrope (16px base)
- **Headings:** Large, bold charcoal (e.g., "Strompreis im Tagesverlauf", "Deine Geräte")
- **Section labels:** Uppercase teal small caps ("STUNDENTARIF · EUROPE/ZURICH", "MANUELL PLANEN")
- **Data emphasis:** Large numeric values (e.g., "21.4 Rp.", "13:00 Uhr") in bold

### Layout Components (from screenshots)

**1. Header Bar**
- Logo (lightning bolt icon + "Swiss Energy ASSISTANT")
- Location: "Bern · 3007" with provider name "Alpenstrom Stadtwerk · Flex Demo"
- Tariff status badge: "Tarif selbst angegeben" (user-claimed)
- Language selector: "DE ∨"
- Settings gear icon

**2. Price Chart Section**
- Label: "STUNDENTARIF · EUROPE/ZURICH"
- Title: "Strompreis im Tagesverlauf"
- Subtitle: "Verifizierter variabler Gesamtpreis · inklusive MwSt."
- Summary stats: "Tiefstpreis 21.4 Rp. (14:00–15:00)" and "Tagesmittel 27.5 Rp."
- Chart legend: Gesamt (total) | Energie | Netz — toggleable
- Unit toggle: "Rp./kWh" | "CHF/kWh"
- Today/Tomorrow toggle: "Heute" | "Morgen"
- Step-line chart with shaded recommended window (light teal)
- Tooltip: "Heute, 07:00 Uhr — Verifizierter Gesamtpreis: 33.2 Rp./kWh"
- Footer: "Empfohlenes Fenster für Waschmaschine" | "24 Werte · native 60-Min.-Intervalle" | "Datentabelle anzeigen"

**3. Appliance Cards Section**
- Section label: "MANUELL PLANEN"
- Title: "Deine Geräte" with "Wir finden das günstigste Fenster für den gesamten, nicht unterbrechbaren Zyklus."
- "Gerät hinzufügen" button (+ Add appliance)
- Cards: Waschmaschine (120 Min, 1 kWh), Geschirrspüler (150 Min, 1.2 kWh), E-Auto (240 Min, 11 kWh)
- Each card: Icon, specs, "BESTER START · MORGEN", time, finish window, estimated cost (CHF), savings pill, DEMO badge
- CTA: "Erinnerung setzen" (Set reminder)

**4. Price Breakdown Section**
- "Was steckt im Preis?" (What's in the price?)
- Stacked bar: Energie (8.6–22.2 Rp.), Netznutzung (9.1 Rp.), Abgaben & Steuern (4.1 Rp.), MwSt. (enthalten)
- Fixed costs noted separately: "CHF 96.00 pro Jahr für Messung und Grundgebühr"

**5. Tariff Comparison Section**
- "TRANSPARENT VERGLEICHEN" label
- "Tarife im Kontext" heading
- Two tabs: "Meine verfügbaren Tarife" | "Schweizer Preisexplorer"
- Cards: "AKTUELL AUSGEWÄHLT — Alpenstrom Flex" vs "LOKALE OPTION — Alpenstrom Klassik"
- Annual cost: CHF 1'148/Jahr vs CHF 1'214/Jahr
- Feature checklist: Smart Meter erforderlich, Selbst angegebene Teilnahme, etc.
- Side note: "Nur bestätigte lokale Optionen — Die Auswahl zeigt Produkte deines Netzgebiets."
- CTAs: "Tarifdetails" | "Eignung prüfen"

**6. Notification Section**
- "Bleib informiert, nicht überfordert"
- "Du entscheidest, wann wir dich an günstige Zeitfenster erinnern."
- "Push erlaubt" (Push allowed) status with checkmark

---

## 7. Swiss Energy Provider API Landscape

### Active Provider APIs (Priority Order)

#### P0 — CKW Dynamic Grid Tariff
```
Endpoint: https://e-ckw-public-data.de-c1.eu1.cloudhub.io/api/v1/
          netzinformationen/energie/dynamische-preise
Resolution: Hourly
Publication: Day-ahead from ~12:00 CET/CEST
Coverage: Network/grid charge ONLY (not full retail)
Format: JSON
Auth: Public (verify commercial reuse rights)
Risk: Only grid component — NOT full electricity price
```

#### P0/P1 — Groupe E VARIO
```
Endpoint: https://api.tariffs.groupe-e.ch/v2/tariffs/
Resolution: 15-minute
Publication: Day-ahead by ~18:00 CET/CEST
Coverage: Full tariff (verify components)
Format: JSON via Azure API Management
Auth: May require token/subscription key
Risk: API access permissions, Azure gateway
```

#### P1 — EKZ Dynamic
```
Resolution: 15-minute
Publication: Day-ahead
Coverage: Full dynamic tariff
CRITICAL: Requires smart meter + compatible EMS
Risk: App cannot satisfy EMS requirement → comparison only
```

#### P1 — Primeo Dynamisch (2027)
```
Endpoint: https://tarife.primeo-energie.ch/api/v1/tariffs
Resolution: Hourly
Publication: Day-ahead by ~18:00
Coverage: Energy + network (new 2027 product)
CRITICAL: Requires compatible EMS + smart meter
Risk: New product, verify endpoint schema before production
```

#### P0/P1 — ElCom Annual Tariffs
```
Source: ElCom tariff datasets / LINDAS
Resolution: Annual
Coverage: All Swiss municipalities, regulated tariffs
Usage: Comparison, benchmarking, bill explainer
Format: CSV/dataset download
```

### Adapter Design Pattern

Each provider gets a dedicated adapter implementing a common interface:

```python
class ProviderAdapter:
    async def fetch(self, product_id, start_utc, end_utc) -> list[PriceInterval]
    async def health(self) -> dict
```

**Adapter acceptance checklist per provider:**
- [ ] Official documentation URL and retrieval date
- [ ] License status: approved_public / permission_required / no_republication / unknown
- [ ] Authentication method and rate limits
- [ ] Price granularity and publication cut-off time
- [ ] Payload shape, units (Rp/kWh, CHF/kWh, CHF/MWh), timezone handling
- [ ] What the values represent (energy only, network only, complete, VAT included?)
- [ ] Eligibility requirements (smart meter, EMS, enrollment)
- [ ] Automated regression test fixture

---

## 8. Daily Price Update Regulation (Jan 2027)

### Regulatory Context

Starting **1 January 2027**, Switzerland's energy regulations introduce changes affecting how electricity prices are communicated and updated:

1. **Dynamic tariff transparency**: Providers offering dynamic tariffs must publish next-day prices at documented intervals, making day-ahead data available for consumers and third-party applications

2. **PV feed-in remuneration reform**: This is a **separate** matter from import tariffs — the reform changes how solar panel owners are compensated for exported electricity. Official market prices for feed-in remuneration will be published quarterly by federal authorities, with daily EPEX data available under commercial license

3. **ElCom 2027 tariff dataset**: Annual regulated tariffs for all municipalities are published for the 2027 tariff year, enabling comprehensive comparison

### How We Handle Daily Price Updates

| Aspect | Implementation |
|--------|----------------|
| **CKW** | Fetch hourly prices daily after 12:00 CET/CEST |
| **Groupe E** | Fetch 15-min prices daily after 18:00 CET/CEST |
| **Primeo** | Fetch hourly prices daily after 18:00 CET/CEST (2027 product) |
| **EKZ** | Fetch for comparison; flag EMS requirement |
| **ElCom annual** | Import once per year; track mid-year corrections |
| **Retry policy** | Exponential backoff + jitter; honor HTTP 429/Retry-After |
| **Staleness** | Never serve stale data as fresh; show last-good with warning |
| **Validation** | Check continuity, monotonic intervals, DST coverage, unit bounds |
| **DST** | Store UTC; spring = 23h/92 slots, autumn = 25h/100 slots |

### Important Distinctions

- **Dynamic tariffs ≠ universal**: Only enrolled customers with eligible providers can see live dynamic prices; others see fixed/HT-NT rates
- **Network tariff ≠ full bill**: CKW's dynamic prices cover only the grid/network component, not the total electricity cost
- **Daily publication ≠ real-time**: Prices are day-ahead (published for tomorrow), not real-time spot prices
- **Our app ≠ EMS**: We are a notification/advice tool; we do not control loads or satisfy EMS enrollment criteria

---

## 9. Future: Solar Panels, Home Automation & IoT

### Stage 6 — Solar & Battery Read-Only (Months 5-8)

**Potential Integrations (read-only first):**

| Manufacturer | Product | API Type | Notes |
|-------------|---------|----------|-------|
| Huawei | SUN2000 / LUNA2000 | Modbus / Cloud | Model-dependent; firmware matters |
| Sungrow | iSolarCloud | Cloud API | Developer agreement needed |
| Fronius | Solar API | Local / Modbus | Well-documented |
| SMA | Developer Platform | Cloud | SMA Sunny Portal |
| SolarEdge | Monitoring API | Cloud | Per-site API key |

**Solar value proposition:**
- Compare solar surplus vs self-consumption
- Show net export value at actual feed-in rate
- Recommend when to use appliances (consume own solar vs grid)
- Solar + price forecast for manual timing decisions

### Stage 7 — Home Automation (Month 8+, Separate Product)

**Integration approach:**
1. Home Assistant connector (read-only first)
2. Manufacturer-approved remote-start APIs
3. Safety interlocks, owner approval, audit trail

**Existing market devices to potentially integrate:**
- Smart plugs (e.g., Shelly, Tapo) — read power monitoring only; NEVER use mains-cut to force-start wash appliances
- EV chargers with API (go-e, Easee, Zaptec, ABB) — read charging state, later scheduling
- Heat pump controllers — via manufacturer API only
- Home Assistant as middleware for diverse device control

**Hard safety rules (from spec):**
- No forced-start of washing appliances via power restoration
- No unattended operation of safety-critical devices
- All control must be reversible, with fail-safe override
- Requires professional installer involvement for mains equipment
- Swiss NEV/ESTI compliance for any commercial hardware
- No smart plugs to force-start dishwashers/dryers (returning mains may not start the cycle and can be unsafe)

### Swiss Provider API Opportunities

For future deeper integration, Swiss energy service providers offer:

| Provider | Potential API/Service | Notes |
|----------|----------------------|-------|
| Swisscom Energy | Smart home platform | IoT hub integration |
| Solar Manager | Comprehensive EMS | REST API, established Swiss EMS |
| evcc | Open-source EV charger | Go-based, supports many chargers |
| myStrom | Swiss smart plugs | Local + cloud API |
| Various Stadtwerke | Customer portals | Scraping NOT permitted; official APIs only |

---

## 10. Complete Work Breakdown Structure (WBS)

### WBS Overview

```
1.0  PROJECT SETUP & INFRASTRUCTURE
2.0  BACKEND — CORE FRAMEWORK
3.0  BACKEND — PROVIDER INTEGRATIONS
4.0  BACKEND — TARIFF ENGINE
5.0  BACKEND — APPLIANCE & OPTIMIZER
6.0  BACKEND — COMPARISON ENGINE
7.0  BACKEND — NOTIFICATIONS
8.0  BACKEND — BILLING & SUBSCRIPTION
9.0  FLUTTER — CORE APP FRAMEWORK
10.0 FLUTTER — DASHBOARD UI
11.0 FLUTTER — ONBOARDING FLOW
12.0 FLUTTER — APPLIANCE MANAGEMENT
13.0 FLUTTER — PRICE VISUALIZATION
14.0 FLUTTER — COMPARISON VIEWS
15.0 FLUTTER — NOTIFICATIONS UI
16.0 FLUTTER — SETTINGS & ACCOUNT
17.0 TESTING & QUALITY ASSURANCE
18.0 DEPLOYMENT & CI/CD
19.0 DOCUMENTATION & PILOT
20.0 FUTURE PHASES (Deferred)
```

---

### 1.0 PROJECT SETUP & INFRASTRUCTURE

| WBS ID | Task | Description | Priority | Est. Effort |
|--------|------|-------------|----------|-------------|
| 1.1 | Repository initialization | Create monorepo, Git init, .gitignore, README | P0 | 2h |
| 1.2 | Docker Compose setup | PostgreSQL 16, Redis, backend, reverse proxy (Caddy) | P0 | 4h |
| 1.3 | Environment configuration | `.env.example`, secrets management, config validation | P0 | 2h |
| 1.4 | CI/CD pipeline | GitHub Actions: lint, test, build, migration check | P0 | 4h |
| 1.5 | Backend project scaffold | FastAPI app structure, pyproject.toml, ruff, mypy config | P0 | 3h |
| 1.6 | Flutter project scaffold | `flutter create`, pubspec.yaml, analysis_options | P0 | 2h |
| 1.7 | Database schema design | Alembic init, initial migration with all MVP tables | P0 | 6h |
| 1.8 | Auth infrastructure | JWT/JWKS verification, Supabase Auth or equivalent setup | P0 | 6h |
| 1.9 | Logging & monitoring | Structured logging, Sentry integration, health endpoints | P1 | 4h |
| 1.10 | HTTPS & reverse proxy | Caddy config for local HTTPS, CORS policy | P1 | 2h |

**Subtotal: ~35 hours**

---

### 2.0 BACKEND — CORE FRAMEWORK

| WBS ID | Task | Description | Priority | Est. Effort |
|--------|------|-------------|----------|-------------|
| 2.1 | FastAPI app entry & middleware | main.py, CORS, error handling, request IDs | P0 | 3h |
| 2.2 | Database session management | Async SQLAlchemy session factory, dependency injection | P0 | 3h |
| 2.3 | SQLAlchemy models — users & households | User, Household, Consent models with UUID PKs | P0 | 4h |
| 2.4 | SQLAlchemy models — providers & tariffs | Provider, TariffProduct, TariffInterval, FixedComponent | P0 | 6h |
| 2.5 | SQLAlchemy models — appliances & recommendations | Appliance, Recommendation models | P0 | 4h |
| 2.6 | SQLAlchemy models — notifications & subscriptions | NotificationPreference, Outbox, Subscription | P0 | 3h |
| 2.7 | SQLAlchemy models — audit & admin | AuditEvent, regulated tariff annual, API health | P1 | 3h |
| 2.8 | Pydantic schemas — request/response | All API request/response models with validation | P0 | 6h |
| 2.9 | Auth endpoints | Bootstrap, token verification, role check middleware | P0 | 4h |
| 2.10 | Core utilities | Clock (Europe/Zurich), DST helpers, currency formatting | P0 | 4h |
| 2.11 | Error envelope & pagination | Standard `{code,message,request_id,details}`, cursor pagination | P0 | 2h |
| 2.12 | Rate limiting | Per-IP and per-user rate limits on API endpoints | P1 | 3h |

**Subtotal: ~45 hours**

---

### 3.0 BACKEND — PROVIDER INTEGRATIONS

| WBS ID | Task | Description | Priority | Est. Effort |
|--------|------|-------------|----------|-------------|
| 3.1 | Abstract ProviderAdapter base | Base class, PriceInterval dataclass, Component enum | P0 | 3h |
| 3.2 | Fixture/demo adapter | Deterministic mock data for all development and testing | P0 | 4h |
| 3.3 | CKW adapter | Parse hourly JSON from CKW public API; grid component only | P0 | 6h |
| 3.4 | CKW adapter tests & fixtures | Golden test fixtures, schema validation, error scenarios | P0 | 4h |
| 3.5 | Groupe E adapter | Parse 15-min data from Azure API; handle auth/subscription | P0 | 6h |
| 3.6 | Groupe E adapter tests & fixtures | Golden fixtures, auth flow, error handling | P0 | 4h |
| 3.7 | EKZ adapter (comparison mode) | Parse 15-min data; flag EMS requirement prominently | P1 | 5h |
| 3.8 | Primeo adapter (2027 readiness) | Stub + fixture; activate when 2027 product launches | P1 | 4h |
| 3.9 | ElCom annual tariff importer | Parse ElCom dataset, municipality/operator mapping | P0 | 8h |
| 3.10 | Provider catalog API endpoints | GET /providers, GET /providers/{id}/products | P0 | 3h |
| 3.11 | Location search endpoint | GET /locations/search — municipality/postcode lookup | P0 | 4h |
| 3.12 | API permission verification | Document license status per provider; track access rights | P0 | 4h |

**Subtotal: ~55 hours**

---

### 4.0 BACKEND — TARIFF ENGINE

| WBS ID | Task | Description | Priority | Est. Effort |
|--------|------|-------------|----------|-------------|
| 4.1 | Tariff normalizer service | Normalize all providers to common PriceInterval format | P0 | 6h |
| 4.2 | Unit conversion | Rp/kWh ↔ CHF/kWh ↔ CHF/MWh; VAT inclusion/exclusion | P0 | 3h |
| 4.3 | Ingestion scheduler | APScheduler jobs per provider; configurable publication windows | P0 | 6h |
| 4.4 | Retry & backoff logic | Exponential backoff + jitter; HTTP 429/Retry-After handling | P0 | 3h |
| 4.5 | Distributed lock (ingestion dedup) | Lock by (provider, product, delivery_date) | P0 | 3h |
| 4.6 | Tariff validation pipeline | Continuity, monotonic intervals, no overlaps, slot count | P0 | 4h |
| 4.7 | DST handling | UTC storage, 23/25-hour days, 92/100 quarter-hour slots | P0 | 6h |
| 4.8 | Batch audit & provenance | Checksum, source URL, schema version, tariff_available event | P0 | 3h |
| 4.9 | Tariff API endpoints | GET /tariffs/intervals, GET /tariffs/summary | P0 | 4h |
| 4.10 | Staleness detection | Mark stale data; show last-good with warning; no false fresh | P0 | 3h |
| 4.11 | Component price model | Track ENERGY, GRID_USAGE, LEVY, VAT, etc. per interval | P0 | 4h |
| 4.12 | Fixed component handling | Monthly/annual fixed fees separate from variable marginal cost | P0 | 3h |
| 4.13 | Tariff revision handling | Invalidate stale recommendations; recompute; limit notification spam | P1 | 4h |

**Subtotal: ~52 hours**

---

### 5.0 BACKEND — APPLIANCE & OPTIMIZER

| WBS ID | Task | Description | Priority | Est. Effort |
|--------|------|-------------|----------|-------------|
| 5.1 | Appliance CRUD endpoints | POST/GET/PATCH/DELETE /me/appliances | P0 | 4h |
| 5.2 | Appliance profile validation | Duration, energy, time constraints, weekday restrictions | P0 | 3h |
| 5.3 | Cost calculator service | Integrate per-interval energy × price with fractional overlaps | P0 | 6h |
| 5.4 | Optimizer algorithm | Find 3 cheapest non-overlapping contiguous start windows | P0 | 8h |
| 5.5 | Flat power profile default | `energy_kwh / (duration_minutes/60)` with "approximate" label | P0 | 2h |
| 5.6 | Constraint enforcement | Earliest start, latest finish, quiet hours, weekdays, must-be-home | P0 | 4h |
| 5.7 | Baseline cost calculation | Explicit baseline_start; "no savings" if absent | P0 | 3h |
| 5.8 | Recommendations endpoints | POST /recommendations/preview, GET /me/recommendations | P0 | 4h |
| 5.9 | Recommendation storage | Persist with tariff_batch_id, confidence, data_quality | P0 | 3h |
| 5.10 | Recompute on tariff update | Invalidate and recalculate when tariff revises | P1 | 4h |
| 5.11 | Golden optimizer tests | 45/90/135/180 min durations, DST transitions, edge cases | P0 | 6h |

**Subtotal: ~47 hours**

---

### 6.0 BACKEND — COMPARISON ENGINE

| WBS ID | Task | Description | Priority | Est. Effort |
|--------|------|-------------|----------|-------------|
| 6.1 | Local tariff comparison | Compare eligible products for user's provider/location | P0 | 6h |
| 6.2 | Annual cost projection | Model annual cost with usage profile; include fixed fees | P0 | 4h |
| 6.3 | Eligibility rules engine | Smart meter, EMS, contract duration, switching deadlines | P0 | 4h |
| 6.4 | Swiss-wide comparison | ElCom annual data by municipality/operator; H1/H2/H4/H5 profiles | P0 | 6h |
| 6.5 | Non-switchable disclaimer | Prominent caveat on all cross-provider comparisons | P0 | 1h |
| 6.6 | Comparison API endpoints | POST /comparisons/local, GET /comparisons/switzerland | P0 | 4h |
| 6.7 | Historical comparison | 2026 vs 2027 tariff year, component-level breakdown | P1 | 4h |
| 6.8 | Municipality/operator mapping | ElCom authoritative mapping; handle multi-operator postcodes | P0 | 4h |

**Subtotal: ~33 hours**

---

### 7.0 BACKEND — NOTIFICATIONS

| WBS ID | Task | Description | Priority | Est. Effort |
|--------|------|-------------|----------|-------------|
| 7.1 | Notification preference CRUD | GET/PUT /me/notifications/preferences | P0 | 3h |
| 7.2 | Push token management | POST/DELETE /me/push-tokens; device registration | P0 | 3h |
| 7.3 | Daily digest job | Generate and queue digest after tariff validation | P0 | 6h |
| 7.4 | Appliance reminder scheduler | Schedule reminder at lead_minutes before recommended start | P0 | 4h |
| 7.5 | Notification outbox pattern | Idempotent delivery, dedup_key, retry, status tracking | P0 | 4h |
| 7.6 | FCM push sender | Firebase Cloud Messaging integration for Android/iOS | P0 | 4h |
| 7.7 | Quiet hours enforcement | Suppress notifications during user-defined quiet hours | P0 | 2h |
| 7.8 | Notification templates (DE/FR/EN) | Localized message templates with tariff name, time window | P0 | 3h |
| 7.9 | Max notification cap | Default 2 unsolicited/day; configurable | P1 | 2h |
| 7.10 | Notification delivery tracking | Sent/delivered/failed status; last-delivery in UI | P1 | 3h |

**Subtotal: ~34 hours**

---

### 8.0 BACKEND — BILLING & SUBSCRIPTION

| WBS ID | Task | Description | Priority | Est. Effort |
|--------|------|-------------|----------|-------------|
| 8.1 | Subscription model & endpoints | GET /me/subscription, entitlement check | P1 | 4h |
| 8.2 | Billing webhook handler | POST /webhooks/billing/{vendor}, signature verification | P1 | 4h |
| 8.3 | Free tier entitlement | One household, limited appliances, sample recommendations | P1 | 3h |
| 8.4 | Paid tier feature gating | Multiple appliances, full recommendations, history | P1 | 3h |
| 8.5 | Account management | Data export, account deletion, privacy compliance | P0 | 4h |
| 8.6 | Consent management | Consent versions, accepted_at, withdrawn_at tracking | P0 | 3h |

**Subtotal: ~21 hours**

---

### 9.0 FLUTTER — CORE APP FRAMEWORK

| WBS ID | Task | Description | Priority | Est. Effort |
|--------|------|-------------|----------|-------------|
| 9.1 | Flutter project setup | Create project, configure platforms (Android, iOS, Web) | P0 | 2h |
| 9.2 | Theme configuration | Teal/emerald accent, Manrope font, dark charcoal, Swiss clean UI | P0 | 4h |
| 9.3 | Localization setup | intl + ARB files for DE (default), EN, FR; language toggle | P0 | 4h |
| 9.4 | API client layer | Dio-based typed API client matching backend contract | P0 | 6h |
| 9.5 | Mock API service | Deterministic demo data with DEMO badges everywhere | P0 | 6h |
| 9.6 | State management setup | Riverpod providers for tariff, appliance, household, notifications | P0 | 6h |
| 9.7 | Routing & navigation | Single-page with bottom nav anchors: Overview/Appliances/Compare/Alerts | P0 | 3h |
| 9.8 | Shared widgets | DemoBadge, DataStatus, SourceAttribution, loading skeletons | P0 | 4h |
| 9.9 | Swiss formatting utilities | CHF, Rp./kWh, Swiss number format, 24h clock, Europe/Zurich | P0 | 3h |
| 9.10 | Responsive layout system | 360px to desktop; card stacking, chart responsiveness | P0 | 4h |
| 9.11 | Dark mode (optional) | System-respecting dark theme | P2 | 4h |

**Subtotal: ~46 hours**

---

### 10.0 FLUTTER — DASHBOARD UI

| WBS ID | Task | Description | Priority | Est. Effort |
|--------|------|-------------|----------|-------------|
| 10.1 | App header widget | Logo, location, provider, tariff status badge, language, settings | P0 | 4h |
| 10.2 | Bottom navigation bar | Overview / Appliances / Compare / Alerts — anchor scroll | P0 | 3h |
| 10.3 | Dashboard screen scaffold | ScrollView with anchored sections, pull-to-refresh | P0 | 4h |
| 10.4 | Best Time Hero card | Recommended window, status pill, date, "Remind me" CTA | P0 | 6h |
| 10.5 | Trust footer | Last refresh, utility links, methodology, privacy, caveats | P0 | 3h |
| 10.6 | Error & empty states | No provider, no tariff, stale, offline, API error, partial data | P0 | 4h |

**Subtotal: ~24 hours**

---

### 11.0 FLUTTER — ONBOARDING FLOW

| WBS ID | Task | Description | Priority | Est. Effort |
|--------|------|-------------|----------|-------------|
| 11.1 | Onboarding wizard container | Stepper with progress, back/forward, validation, cancel | P0 | 4h |
| 11.2 | Step 1: Language selection | DE/FR/EN with brief explanation and consent link | P0 | 2h |
| 11.3 | Step 2: Location entry | Postcode/municipality search, network operator suggestion | P0 | 4h |
| 11.4 | Step 3: Tariff product selection | Provider products list, eligibility badges, "I'm not sure" | P0 | 6h |
| 11.5 | Step 4: Appliance setup | Add 1-3 appliances, duration, kWh, finish deadline | P0 | 4h |
| 11.6 | Step 5: Notification preferences | Push opt-in, quiet hours, daily digest time | P0 | 3h |
| 11.7 | Onboarding state persistence | Draft state saved locally; resume interrupted setup | P1 | 3h |

**Subtotal: ~26 hours**

---

### 12.0 FLUTTER — APPLIANCE MANAGEMENT

| WBS ID | Task | Description | Priority | Est. Effort |
|--------|------|-------------|----------|-------------|
| 12.1 | Appliance card widget | Icon, name, specs, best start, cost, savings, reminder toggle | P0 | 6h |
| 12.2 | Appliance editor drawer | Edit duration, energy, earliest/latest, weekdays, quiet hours | P0 | 6h |
| 12.3 | Add appliance modal | Type selector with icons, template defaults, custom option | P0 | 4h |
| 12.4 | Appliance icons | Dishwasher, washer, dryer, EV, water heater, custom | P0 | 2h |
| 12.5 | Alternative windows display | Show up to 3 alternatives with cost comparison | P0 | 3h |
| 12.6 | Reminder toggle UX | Toggle state, demo mode indication, permission handling | P0 | 3h |
| 12.7 | Demo optimizer (client-side) | Deterministic cheapest-window calculation for demo mode | P0 | 4h |

**Subtotal: ~28 hours**

---

### 13.0 FLUTTER — PRICE VISUALIZATION

| WBS ID | Task | Description | Priority | Est. Effort |
|--------|------|-------------|----------|-------------|
| 13.1 | Step-line price chart | 24-48h chart at native interval; energy/network/total series | P0 | 8h |
| 13.2 | Chart interaction | Tooltip with time, price, component, source, freshness | P0 | 4h |
| 13.3 | Today/Tomorrow toggle | Date selector updating chart and recommendations | P0 | 3h |
| 13.4 | Appliance window shading | Overlay recommended run period on chart | P0 | 4h |
| 13.5 | Component legend toggle | Toggle Gesamt/Energie/Netz series visibility | P0 | 2h |
| 13.6 | Unit toggle | Rp./kWh ↔ CHF/kWh display preference | P0 | 2h |
| 13.7 | Summary stats | Lowest price, average, time of lowest, interval count | P0 | 2h |
| 13.8 | Accessible data table | Alternative table view with all chart data ("Datentabelle anzeigen") | P1 | 3h |
| 13.9 | Tariff breakdown widget | Stacked bar: energy, network, levies, tax + fixed costs | P0 | 4h |
| 13.10 | Partial coverage label | "Network charge only" / "Not full electricity price" warnings | P0 | 2h |

**Subtotal: ~34 hours**

---

### 14.0 FLUTTER — COMPARISON VIEWS

| WBS ID | Task | Description | Priority | Est. Effort |
|--------|------|-------------|----------|-------------|
| 14.1 | Comparison tab container | Two tabs: "My available tariffs" / "Swiss price explorer" | P0 | 3h |
| 14.2 | Local tariff cards | Current vs alternative plans, annual cost, eligibility checklist | P0 | 6h |
| 14.3 | EMS/smart meter warnings | Clear badges for required prerequisites | P0 | 2h |
| 14.4 | Swiss explorer view | Municipality search, ElCom data table/chart, ranking | P0 | 6h |
| 14.5 | Non-switchable disclaimer | Prominent permanent caveat on cross-provider comparisons | P0 | 1h |
| 14.6 | Profile filter (H1/H2/H4/H5) | Consumption profile selector for comparison accuracy | P1 | 3h |
| 14.7 | Historical comparison toggle | 2026 vs 2027 year-over-year change | P1 | 3h |

**Subtotal: ~24 hours**

---

### 15.0 FLUTTER — NOTIFICATIONS UI

| WBS ID | Task | Description | Priority | Est. Effort |
|--------|------|-------------|----------|-------------|
| 15.1 | Notification settings panel | Daily digest toggle, time picker, reminder lead time | P0 | 4h |
| 15.2 | Quiet hours configuration | Start/end time pickers | P0 | 2h |
| 15.3 | Push permission handling | Request permission, denied state, re-prompt guidance | P0 | 3h |
| 15.4 | Push token registration | FCM token capture and backend registration | P0 | 3h |
| 15.5 | Recent alerts display | Show last delivered notifications with status | P1 | 3h |
| 15.6 | Sample notification preview | Show what a digest/reminder looks like (DE/FR/EN) | P1 | 2h |
| 15.7 | Local notification scheduling | flutter_local_notifications for on-device reminders | P0 | 4h |

**Subtotal: ~21 hours**

---

### 16.0 FLUTTER — SETTINGS & ACCOUNT

| WBS ID | Task | Description | Priority | Est. Effort |
|--------|------|-------------|----------|-------------|
| 16.1 | Settings drawer/screen | Language, notification prefs, household edit, subscription | P0 | 4h |
| 16.2 | Household edit | Change provider, tariff, location, consumption estimate | P0 | 3h |
| 16.3 | Subscription status display | Free/paid state, expiry, upgrade CTA | P1 | 3h |
| 16.4 | Privacy & consent | Privacy policy, terms, consent management | P0 | 3h |
| 16.5 | Data export request | Trigger backend data export | P1 | 2h |
| 16.6 | Account deletion | Delete account flow with confirmation | P0 | 3h |
| 16.7 | About & attribution | App version, provider attributions, methodology | P1 | 2h |

**Subtotal: ~20 hours**

---

### 17.0 TESTING & QUALITY ASSURANCE

| WBS ID | Task | Description | Priority | Est. Effort |
|--------|------|-------------|----------|-------------|
| 17.1 | Backend unit tests | Optimizer, cost calculator, normalizer, DST, formatters | P0 | 12h |
| 17.2 | Backend integration tests | API endpoints, DB operations, auth flows | P0 | 8h |
| 17.3 | Provider adapter contract tests | Schema validation, mock server responses | P0 | 6h |
| 17.4 | DST edge case tests | 92/100 slot days, midnight crossing, repeated hour | P0 | 4h |
| 17.5 | Flutter widget tests | Key widgets: chart, appliance card, onboarding steps | P0 | 6h |
| 17.6 | Flutter unit tests | Demo optimizer, formatters, time utilities | P0 | 4h |
| 17.7 | Integration test (Flutter) | Full user flow: onboarding → dashboard → edit appliance | P1 | 6h |
| 17.8 | API contract/fixture tests | OpenAPI schema validation, snapshot tests | P0 | 4h |
| 17.9 | Security lint | Secrets leakage check, SSRF protection, auth ownership | P0 | 3h |
| 17.10 | Accessibility audit | WCAG AA contrast, screen reader, keyboard navigation | P1 | 4h |

**Subtotal: ~57 hours**

---

### 18.0 DEPLOYMENT & CI/CD

| WBS ID | Task | Description | Priority | Est. Effort |
|--------|------|-------------|----------|-------------|
| 18.1 | Docker production config | Multi-stage Dockerfile for backend, optimized images | P0 | 3h |
| 18.2 | CI pipeline — backend | Lint (ruff), type check (mypy), test, migration check | P0 | 3h |
| 18.3 | CI pipeline — Flutter | Analyze, test, build APK/IPA | P0 | 4h |
| 18.4 | Android build & signing | APK/AAB generation, Play Store signing config | P0 | 4h |
| 18.5 | iOS build preparation | Xcode project config, provisioning profile setup | P1 | 6h |
| 18.6 | Flutter Web build | PWA configuration for web preview/testing | P1 | 2h |
| 18.7 | Database migration CI | Verify migrations apply cleanly in CI | P0 | 2h |
| 18.8 | Staging environment | Deploy backend + DB for beta testing | P1 | 6h |

**Subtotal: ~30 hours**

---

### 19.0 DOCUMENTATION & PILOT

| WBS ID | Task | Description | Priority | Est. Effort |
|--------|------|-------------|----------|-------------|
| 19.1 | API documentation | OpenAPI /docs auto-gen, example requests/responses | P0 | 3h |
| 19.2 | Developer setup guide | README: clone, env, docker compose up, run tests | P0 | 3h |
| 19.3 | Provider integration guide | Per-provider API status, credentials, refresh schedule | P0 | 3h |
| 19.4 | User-facing methodology | How savings are calculated, tariff component explanation | P0 | 3h |
| 19.5 | Privacy policy draft | Swiss FADP/nDSG compliance, data retention, deletion | P0 | 4h |
| 19.6 | Pilot recruitment | 20+ beta users, 10+ with dynamic tariffs | P0 | 8h |
| 19.7 | Pilot feedback collection | Surveys, savings tracking, willingness-to-pay testing | P0 | 6h |
| 19.8 | Analytics instrumentation | Privacy-safe events: onboarding, recommendations, alerts | P1 | 4h |

**Subtotal: ~34 hours**

---

### 20.0 FUTURE PHASES (Deferred — Not in MVP)

| WBS ID | Task | Description | Phase | Notes |
|--------|------|-------------|-------|-------|
| 20.1 | Solar panel read-only integration | Huawei, Sungrow, Fronius, SMA APIs | Stage 6 | Read generation/battery data only |
| 20.2 | Solar self-consumption advisor | Manual recommendations based on solar + tariff | Stage 6 | Requires solar forecast |
| 20.3 | EV charger monitoring | Read charging state from go-e, Easee, etc. | Stage 6 | Read-only first |
| 20.4 | Home Assistant connector | Read-only device states | Stage 6 | User-permissioned, local network |
| 20.5 | Appliance auto-start | Manufacturer-approved remote start | Stage 7 | Safety interlocks required |
| 20.6 | Battery dispatch optimization | Price-driven charge/discharge scheduling | Stage 7 | Manufacturer APIs, safety |
| 20.7 | OCR bill scanning | Photograph bill → extract kWh and components | Stage 5 | After manual entry validated |
| 20.8 | B2B API / white-label | Normalized tariff API for installers/partners | Future | Validate demand first |
| 20.9 | Own hardware (ESP32 gateway) | Low-voltage communication gateway | Future | NEV/ESTI compliance required |
| 20.10 | EPEX wholesale integration | Day-ahead spot prices for PV export | Stage 5+ | Commercial licensing required |

---

## 11. Implementation Phases & Timeline

### Phase 1: Foundation (Weeks 1-2) — WBS 1.0, 2.0

**Goal:** Bootable project with Docker Compose, database schema, auth, and health checks.

| Milestone | Deliverable | Acceptance |
|-----------|------------|------------|
| M1 | Repo, Docker Compose, migrations, health | `docker compose up` works |
| M2 | Auth, core models, base endpoints | `/docs` OpenAPI loads |

### Phase 2: Data Infrastructure (Weeks 2-3) — WBS 3.0, 4.0

**Goal:** Provider adapters, tariff ingestion, normalization, and DST-safe storage.

| Milestone | Deliverable | Acceptance |
|-----------|------------|------------|
| M3 | CKW + Groupe E adapters + fixtures | Tariff data fetchable |
| M4 | Tariff normalizer, DST tests, ingestion scheduler | 92/100 slot tests pass |

### Phase 3: Intelligence Engine (Weeks 3-4) — WBS 5.0, 6.0

**Goal:** Appliance optimizer, cost calculator, comparison engine.

| Milestone | Deliverable | Acceptance |
|-----------|------------|------------|
| M5 | Appliance CRUD + optimizer with golden tests | Deterministic best-start |
| M6 | Comparison engine (local + Swiss-wide) | Annual cost projections |

### Phase 4: Flutter App (Weeks 4-7) — WBS 9.0–16.0

**Goal:** Complete Flutter mobile app matching Figma design.

| Milestone | Deliverable | Acceptance |
|-----------|------------|------------|
| M7 | App scaffold, theme, localization, API client | App runs with mock data |
| M8 | Dashboard, onboarding, price chart | Full UI flow works |
| M9 | Appliance cards, comparison views, settings | Feature complete |
| M10 | Push notifications, Android build | Installable APK |

### Phase 5: Integration & Testing (Weeks 7-8) — WBS 7.0, 8.0, 17.0

**Goal:** Connect frontend to backend, notifications, subscription scaffold.

| Milestone | Deliverable | Acceptance |
|-----------|------------|------------|
| M11 | Notification backend + FCM integration | Daily digest sends |
| M12 | Full integration tests, security review | CI green, no leaks |

### Phase 6: Pilot (Weeks 8-10) — WBS 18.0, 19.0

**Goal:** Deploy staging, recruit pilot users, collect feedback.

| Milestone | Deliverable | Acceptance |
|-----------|------------|------------|
| M13 | Staging deployment, Android beta on Play Store | 20+ beta installs |
| M14 | Pilot feedback, savings measurement | Go/no-go decision data |

### Total Estimated Effort

| Phase | WBS Sections | Hours |
|-------|-------------|-------|
| Foundation | 1.0 + 2.0 | 80h |
| Data Infrastructure | 3.0 + 4.0 | 107h |
| Intelligence Engine | 5.0 + 6.0 | 80h |
| Flutter App | 9.0–16.0 | 223h |
| Integration & Testing | 7.0 + 8.0 + 17.0 | 112h |
| Deployment & Pilot | 18.0 + 19.0 | 64h |
| **TOTAL MVP** | **1.0–19.0** | **~666h** |

*Estimate assumes a single experienced developer. With a 2-person team working in parallel (backend + Flutter), the calendar timeline can be compressed to ~10 weeks.*

---

## 12. Risk Register Summary

| ID | Risk | Severity | Mitigation |
|----|------|----------|------------|
| R01 | Households can't switch supplier | Critical | Separate local options vs national benchmarks; clear disclaimers |
| R02 | Dynamic tariffs require enrollment | Critical | Always ask for exact tariff product; never infer from postcode |
| R03 | EKZ/Primeo require EMS | Critical | Mark eligibility; target CKW/Groupe E first |
| R04 | API redistribution license unclear | Critical | Get written permission per provider before production |
| R05 | API only has partial price components | High | Component-level price model; label "network only" |
| R06 | Day-ahead publication outages | High | Retry, cache last-good, mark staleness |
| R07 | DST 23/25-hour days | High | UTC storage, Europe/Zurich UI, interval math tests |
| R09 | Very small per-cycle savings | Critical | Measure actual savings; pivot to EV/heat pump later |
| R11 | App store payment compliance | High | Review Apple/Google policies for digital services |
| R12 | Privacy and Swiss nDSG compliance | High | Encryption, deletion/export, consent tracking |

---

## 13. Decision Log

| # | Decision | Date | Rationale |
|---|----------|------|-----------|
| D01 | Flutter instead of React/Capacitor | 2026-10-28 | Stakeholder preference; true native performance; single codebase |
| D02 | Software-only MVP, no hardware | 2026-10-28 | Validate value before hardware investment |
| D03 | CKW + Groupe E as initial providers | 2026-10-28 | Most manual-friendly; don't require EMS |
| D04 | Modular monolith, not microservices | 2026-10-28 | Simpler for small team; split later if needed |
| D05 | CHF 10/year pricing hypothesis | 2026-10-28 | Test in pilot; no lifetime pricing |
| D06 | German as default language | 2026-10-28 | Swiss market; largest language group |
| D07 | Single-page dashboard | 2026-10-28 | Mobile-first; avoid sidebar SaaS pattern |
| D08 | Advice only, no appliance automation | 2026-10-28 | Safety, regulatory, and market validation first |

---

## APPENDIX A — Glossary

| Term | Definition |
|------|-----------|
| **EMS** | Energy Management System — a certified system that can monitor and potentially control energy loads |
| **HT/NT** | Hochtarif/Niedertarif — High tariff (daytime) / Low tariff (nighttime) time-of-use pricing |
| **ElCom** | Swiss Federal Electricity Commission — regulates electricity market and publishes tariff data |
| **FADP/nDSG** | Swiss Federal Act on Data Protection (new version) |
| **Rp./kWh** | Rappen per kilowatt-hour — Swiss centime unit for electricity pricing |
| **DST** | Daylight Saving Time — Europe/Zurich transitions affect slot counts |
| **H1/H2/H4/H5** | Standard consumption profiles used by ElCom for tariff comparison |
| **Day-ahead** | Prices published for the following day, typically by noon or 6pm |
| **EPEX** | European Power Exchange — wholesale electricity market |

## APPENDIX B — Reference Sources

- [S1] ElCom, basic supply and free market
- [S2] ElCom, FAQ tariffs  
- [S3] ElCom, tariff data and visualizations (2027 dataset)
- [S4] CKW dynamic technical API
- [S5] EKZ dynamic optional tariff
- [S6] Groupe E VARIO
- [S7] Primeo Dynamisch
- [S8] VSE feed-in pricing data access 2027
- [S9] SmartGridready OpenAPI v2 specification
- [S10] 2027 federal official tariff figures

*Full URLs available in the master specification document.*

---

**Next Step:** Begin implementation with WBS 1.0 (Project Setup & Infrastructure) — create the monorepo, Docker Compose, Flutter project, and FastAPI backend scaffold.
