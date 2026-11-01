# Swiss Energy Assistant — Product Roadmap, Business Plan & Implementation Specification

**Version:** 1.0  
**Prepared:** 28 October 2026  
**Target delivery:** Cursor AI (backend/mobile implementation) + Lovable.dev (one-page dashboard)  
**Proposed product:** working name *Swiss Energy Assistant* (rename before launch)  
**Initial geography:** Switzerland, starting with supported utility territories; multilingual DE/FR/EN  
**Operating principle:** software first, advice before automation, no proprietary electrical hardware in MVP.

> **Status convention**: **Verified** = confirmed in source documents linked in Appendix; **Design proposal** = planned product behavior; **Needs verification** = eligibility, permissions, license, pricing or data details to be established before shipping. Never transform a proposal into a claimed official utility feature.

---

## 0. Executive decision

Build an independent **tariff intelligence and appliance scheduling backend** with a lightweight **mobile-first dashboard**, then expose recommendations as notifications. Start with live day-ahead tariffs, a regulated-price comparison/explainer, and no physical appliance control. Validate real savings and whether users will pay before investing in solar integrations, smart-home control or switching hardware.

**Positioning:** "Understand your Swiss electricity tariff. Know the best time to run your appliances. No hardware required."

**Not** a wholesale electricity trading app; **not** a general energy management system on day one; **not** an app that promises all users 15-minute retail prices in January 2027.

### Hard constraints affecting the business

1. Swiss residential electricity customers consuming less than 100 MWh annually generally **cannot freely switch electricity suppliers**; they are served by their local basic-supply provider. Comparisons between municipalities/providers are informative, not necessarily actionable switch offers. Source: ElCom [S1, S2].
2. Most regulated household retail tariffs remain fixed or time-of-use. **Dynamic network tariffs** are becoming available from certain suppliers, but **15-minute prices are not universal**. Source: ElCom [S2], provider documents [S4–S7].
3. **EKZ** publishes 15-minute dynamic tariffs, but its current product conditions include a communicating smart meter **and compatible EMS**. Notification-only software must not be marketed as an EMS satisfying EKZ's enrollment criteria. Source [S5].
4. **CKW** offers a dynamic **network** tariff; next-day prices via a published API from around 12:00, in hourly intervals; CKW **recommends** an EMS and warns costs may rise. Source [S4].
5. **Groupe E VARIO** has 15-minute next-day tariff data via API, typically by 18:00. Source [S6].
6. **Primeo Dynamisch** (2027) includes dynamic energy **and** network charges on an hourly basis with next-day publication by 18:00 and requires a compatible EMS and smart meter. Source [S7].
7. The January 2027 **PV feed-in remuneration** reform is a **separate** matter from the retail import tariff. Official retrospective market prices are not a guaranteed free real-time commercial API; EPEX licensing may be required. Source [S8].
8. The provider feed may represent only **one bill component**. Do not describe dynamic grid prices as the customer's full all-in kWh charge unless every component is actually included and verified.

### Primary customer segments

- **A**: Swiss households with eligible dynamic tariffs that can manually shift use of dishwasher/washer/dryer/EV, where provider conditions permit it.
- **B**: Households on high/low (HT/NT) tariffs that want understandable, time-aware guidance (lower savings, broader reach).
- **C**: Households who simply want a breakdown of their bill and comparison with their local available tariff products; comparison is educational across providers.
- **Later**: PV + battery owners, EV drivers, installers and energy software vendors.

### MVP success criterion

At least 20 valid pilot homes, at least 10 with eligible time-varying tariffs, accurate daily tariff publishing, >95% accurate scheduled digest delivery (with retry), substantive follow-through on recommendations, and a realistic estimate of incremental monthly savings. Require a positive willingness-to-pay signal before building automation.

---

# PART I — Sequence of actions / stage gates

## Stage 0 — Market, legal, API and tariff validation (week 1)

- [ ] Choose an initial geographic footprint: e.g. CKW first, then Groupe E; EKZ and Primeo for visibility and condition-aware onboarding.
- [ ] For each supplier, download current terms, tariff product rules, public technical docs, access requirements, and data usage/reuse license.
- [ ] Verify exactly which household population can enroll in each dynamic tariff; whether manual-only guidance is permitted; whether smart meter/EMS are required.
- [ ] Verify the availability, supported date span, resolution, timezone, publication cadence, units and tariff components of each public API.
- [ ] Confirm the provider's public API allows a commercial consumer app and cache/republication; request permission if unclear.
- [ ] Obtain 2026 and 2027 annual tariffs and network-operator/municipality mapping from ElCom.
- [ ] Research 10 current alternatives including existing supplier apps, Solar Manager, evcc, Home Assistant integrations and tariff comparison websites.
- [ ] Recruit at least 5 pilot users able to supply their **tariff product name**, not merely provider name.
- [ ] Record data-protection requirements (Swiss FADP/nDSG), Swiss/EU hosting preference and push notification consent.

**Exit gate:** at least **two viable provider datasets** plus demonstrable lawful use; at least one usable manually-shiftable customer segment. If not, begin with annual tariff explorer and educational HT/NT scheduling rather than inventing dynamic recommendations.

## Stage 1 — Data infrastructure and deterministic optimizer (weeks 1–2)

- [ ] Build FastAPI backend, Postgres, provider adapters, normalization and tariff validation.
- [ ] Provide mock tariff fixture covering 96 x 15-minute intervals, 23/25-hour DST days and hourly prices.
- [ ] Fetch tomorrow's schedule provider-by-provider only *after* each published release window; maintain retries/backoff.
- [ ] Never fill missing data with invented observed prices; explicitly mark stale and estimated results.
- [ ] Build rolling-cost window algorithm using appliance consumption profiles and user deadlines.
- [ ] Build comparison of a customer's *available* fixed/HT-NT/dynamic tariff products where the terms are known; identify unknowns.
- [ ] Write automated unit tests; generate OpenAPI and fixtures consumed by Lovable.

**Exit gate:** reproducible calculations and exact tariff provenance, no false all-in charges, DST tests pass.

## Stage 2 — Minimal user experience and mobile notifications (weeks 2–4)

- [ ] Use Lovable.dev to produce **one responsive dashboard page** from the prompt in Part V, then export into the project.
- [ ] Package React/Vite app with Capacitor for Android; PWA/website remains available for early testing. Add iOS when provisioning is ready.
- [ ] Implement postcode/municipality + utility selection, tariff selection, appliance list, time constraints and notification preferences.
- [ ] Display today/tomorrow tariff chart, cheapest safe windows, tariff component breakdown, current annual fixed tariff overview, and notifications.
- [ ] Add explicit **Not eligible / Unknown / Confirmed** tariff status with clear warnings.
- [ ] Implement daily push digest and reminder scheduling with opt-in, quiet hours and timezone.
- [ ] If peerDesk supports compliant outgoing notifications, add it as an optional channel; **do not make peerDesk mandatory** for service use.

**Exit gate:** users can sign up, choose an accurate tariff, get a useful recommendation and understand its limitations.

## Stage 3 — Pilot and economics (weeks 4–7)

- [ ] Recruit 20–30 beta users across at least two different tariff types.
- [ ] Conduct before/after behavior survey; optionally let users confirm they actually ran an appliance at the suggested time.
- [ ] Calculate **potential savings** vs defined comparison start times; label savings **realized** only when supported by measurements or explicit verified assumptions.
- [ ] Collect notification open/action rates and feedback. Run small A/B test: daily summary vs user-requested reminder only.
- [ ] Interview users to test CHF 10/year, CHF 1/month and CHF 10 lifetime; avoid lifetime promise for ongoing service.
- [ ] Verify each provider integration monthly and record API operational cost.

**Exit gate:** clear user retention, trust, evidence of savings and willingness to pay. If laundry-only savings are tiny, pivot target toward EV/heat pump/solar insights without building automated control yet.

## Stage 4 — Paid MVP (weeks 7–10)

- [ ] Decide billing route: website subscription and/or in-app purchase, depending on store rules for digital services. Do **not** assume Stripe web billing can be used for all in-app digital purchases.
- [ ] Suggested experiment: free tariff explorer, paid appliance schedules/alerts at **CHF 10/year**; keep CHF 1/month only if payment economics justify it.
- [ ] Build consent/privacy pages, unsubscribe/export/delete account, receipt handling, webhook idempotency and app store compliance.
- [ ] Add analytics, monitoring, error budget and a support knowledge base explaining tariffs and eligibility.
- [ ] Publish Android and PWA first; expand language coverage and iOS.

**Exit gate:** paying customers at acquisition/support cost below realistic revenue; renewal intention demonstrated.

## Stage 5 — Comparison intelligence and bill explainers (months 3–5)

- [ ] Map all municipalities to regulated distribution operators using ElCom data.
- [ ] Import 2026/2027 tariffs, H1/H2/H4/H5-style usage profiles and fixed fees; build comparison per geography and eligibility.
- [ ] Add simple bill entry (manual data first; optional OCR later): total annual kWh, energy, network, metering, levies, base fees and VAT.
- [ ] Compare customer's local *eligible tariff products*: standard vs HT/NT vs dynamic (only if explicitly eligible).
- [ ] Provide inter-provider comparisons for education/benchmarking with **"usually not switchable"** label.
- [ ] Historical price charts, tariff increases and household-specific "what if" simulations.

## Stage 6 — Solar, batteries, EV and smart-home read-only (months 5–8; gated)

- [ ] Read-only data adapters for manufacturer-authorized Huawei SUN2000/LUNA2000, Sungrow, Fronius, SMA, SolarEdge where supported.
- [ ] Read-only integrations through Home Assistant and compatible EV chargers/monitoring APIs.
- [ ] Compare solar surplus, self-consumption, net export, forecast and price-driven manual suggestions.
- [ ] Design permissions for device control but keep the capability disabled by default.
- [ ] Determine API authentication, licensing, local gateway requirements, firmware and installer rights per device model.

**Exit gate:** real hardware access, authenticated customer consent, a measurable improvement over existing EMS, and no warranty/grid-conflict concerns.

## Stage 7 — Optional automation (months 8+; separate product)

- [ ] Manufacturer-approved appliance remote-start integration first, respecting machine safety and user activation.
- [ ] Device control via authorized Home Assistant / supported vendor APIs, only for certified suitable loads.
- [ ] Enforce safety interlocks, owner approval, reversible schedules, grid/export constraints, audit trail and override.
- [ ] Only if there is a proven gap, investigate OEM hardware or a compliant DIN-rail gateway with professional installer involvement.
- [ ] Do not use mains-cut smart plugs to force-start wash/dry cycles; returning mains power may not start the appliance, and unattended operation can be unsafe.

---

# PART II — Detailed product requirements

## 1. Roles

- **Visitor**: sees limited educational tariff explorer and public providers/municipality comparison.
- **Free account**: saves one household and tariff, sees next-day prices and one sample recommendation.
- **Subscriber**: multiple appliances, daily summaries, personalized reminders, history, comparison details.
- **Admin/operator**: manages sources, product eligibility, provider mappings, licenses, alerts, user support and audit logs.
- **Future installer/partner**: multi-site read-only insights with explicit household consent.

## 2. Main onboarding flow

1. Select language (DE/FR/EN), consent and account creation (email magic link or secure OAuth).
2. Enter municipality or postcode; distinguish municipalities with multiple distribution zones and warn if ambiguous.
3. Show likely network operator based on verified ElCom mapping and allow manual correction.
4. Select exact retail **tariff product** from provider-specific catalog. Offer "I don't know" with guidance to read the bill; never infer dynamic enrollment just from postal code.
5. Collect approximate annual consumption, smart-meter status (optional), solar/battery/EV (optional), normal activity hours and quiet hours.
6. Ask user to add a dishwasher/washer/dryer/EV with estimated cycle duration, total energy and must-finish time. Provide editable templates.
7. Explain dynamic eligibility and which parts of price are known; get explicit notification opt-in.
8. Show first real recommendation or "Next-day prices not yet published" state.

## 3. Dashboard functional scope (single page)

1. Header: home/municipality, provider and tariff, subscription state, tomorrow's publication status.
2. **Primary insight**: cheapest eligible appliance start period for the selected day; one CTA to create reminder.
3. 24–48h responsive price chart at native interval; overlay appliance-run window; tooltip shows energy, network, charges, all-in status and source date.
4. **Appliance cards**: name, duration, energy/kWh, earliest start, finish deadline, best start, modelled CHF cost, baseline CHF cost, potential savings; edit and reminder toggle.
5. **Tariff breakdown**: retail energy, network, metering, taxes/levies, fixed fees, VAT (explicit whether included); data completeness.
6. **Local tariff comparison**: current product vs other **eligible** tariff options with projected annual cost and assumptions.
7. **Swiss price explorer**: compare annual regulated published tariffs of other communes/operators; always include disclaimer that household supplier change is generally unavailable.
8. Alerts center: daily summary, reminder timing, delivery channels, quiet hours, last-delivery status.
9. Trust: provider attribution, last fetched time, freshness, tariff version, disclaimer, source links.
10. Empty/error/loading states: no provider supported, tariff not enrolled, EMS required, awaiting next-day publication, stale feed, offline device, notification permission denied.

## 4. Appliance profile specification

Per appliance:

- `type`: dishwasher, washing_machine, tumble_dryer, ev_charger, water_heater, other.
- `name`, `duration_minutes`, `energy_kwh`, optional `power_profile` as proportional segment weights.
- `earliest_start_local`, `latest_finish_local`, `allowed_weekdays`, `notification_lead_minutes`.
- `must_be_home`: optional, `quiet_hours_policy`, `needs_manual_start`: true in MVP.
- `preferred_baseline_start`: user-selected or observed pattern; never use an arbitrary expensive baseline without labeling.
- `load_shiftable`: boolean, optional `minimum_run_minutes`, `can_pause`: false for washing appliances.
- Limit fields to realistic ranges; warn when energy estimates are generic.

Profiles default to a *flat energy curve* with an obvious "approximate" label; later calibrate measured appliance profiles. Compute contiguous run costs for non-pausable cycles.

## 5. Savings calculation

For tariff slots `i` with interval `[start_i, end_i)` and component price `p_i` in **CHF/kWh**, and appliance consumption `e_i` in kWh within interval, modeled variable cost is:

`run_cost_chf = Σ(e_i × p_i)`.

- Compute over a valid contiguous start and fixed duration, with fractional overlaps at time boundaries.
- Use piecewise hourly/15-minute rates as actually published; never create fake intermediate 15-minute price movements.
- `effective_price = known_energy + known_network + known_variable_levies`; add only verified applicable values; fixed fees are shown separately, not treated as marginal shift savings.
- If some components are constant or unknown, label comparisons as `known-variable-components-only` and avoid presenting as all-in bill estimates.
- For dynamic grid tariff alone, savings can be evaluated for grid portion if other import components are constant; label it **network-charge savings**.
- For EV charging account for charger efficiency, power limit, battery needs and user required finish time in later release.
- For PV households, marginal self-consumption vs export should use actual export remuneration and solar forecast, never assume generated electricity is free.
- Potential savings = modeled baseline cost − modeled recommended cost. Display negative values transparently if applicable.
- Do not assert realized savings without actual measurement/confirmation and declared method.

## 6. Tariff comparison methodology

**Two distinct experiences**:

### (A) Actionable local tariff options

For user's provider and location, compare only tariff products the customer is genuinely permitted to choose, after identifying smart meter/EMS requirements, switching deadlines and contract duration. Calculate annual estimated cost using selected consumption profile; dynamic scenarios require sample load curve, not annual total only. Include uncertainty range if no hourly load profile.

### (B) Educational nationwide comparison

Show how regulated prices vary between communes/networks using ElCom 2027 annual tariff data. Explain **not a shopping marketplace**: most Swiss households cannot freely switch providers. Benchmark energy/network/metering/taxes and distinguish H1/H2/H4/H5 load profiles. Permit historical 2026–2027 comparison and label change in component accounting.

### Price component model

`ENERGY`, `GRID_USAGE`, `METERING`, `LEVY`, `COMMUNAL_TAX`, `VAT`, `FIXED_BASE_FEE`, `EXPORT_REWARD`, `OTHER`. Each component has `price_chf_per_kwh` or `fixed_chf_per_period`, `is_variable`, `tax_included`, `billing_basis`, `valid_from`, `valid_to`, `source`, `confidence`.

Do not sum incompatible components or pre-tax/post-tax values. Surface partial coverage rather than misleading totals.

---

# PART III — API providers, dependencies and roadmap

## 1. Integration priority matrix

| Integration | Phase | Frequency/resolution | Source/endpoint | Permission and risk |
|---|---|---|---|---|
| CKW dynamic grid tariff | P0 | Next day ~12:00; hourly | `https://e-ckw-public-data.de-c1.eu1.cloudhub.io/api/v1/netzinformationen/energie/dynamische-preise` [S4] | Confirm commercial reuse, `timestamp`, tariff_type, units, billing coverage; not necessarily full retail cost |
| Groupe E VARIO | P0/P1 | Next day by 18:00; 15-min | `https://api.tariffs.groupe-e.ch/v2/tariffs/` [S6] | Confirm Azure API management access, token/subscription if needed, contract eligibility |
| EKZ dynamic tariff | P1 | 15-min; next-day | EKZ tariff documentation [S5] | Smart meter + compatible EMS prerequisite; app can provide comparison but must not imply eligibility |
| Primeo Dynamisch | P1 | Next day by 18:00; hourly | `https://tarife.primeo-energie.ch/api/v1/tariffs` (existing grid tariff API; future product details to verify) [S7] | New 2027 energy + grid product; verify endpoint and field semantics before production |
| ElCom 2027 published tariffs | P0/P1 | Annual | ElCom tariff datasets/LINDAS [S3] | Annual regulated comparison, not live daily price source |
| SmartGridready dynamic tariff V2 | P0 schema | 2027 interface specification | [S9] | Standard/schema, **not** an operational price endpoint |
| EPEX Swiss day-ahead | P3 | wholesale | Authorized market-data supplier [S8] | Commercial licensing; not equivalent to retail import pricing |
| Huawei/Sungrow/Fronius/SMA | P3 | device measurements | vendor-approved integrations | Account, firmware, permissions, cybersecurity and site access |
| Home Assistant/EV charger apps | P3/P4 | telemetry/control | user-permissioned API | External control only in separately gated automation phase |

### Adapter acceptance checklist

For each provider record:

- Official documentation URL and retrieval date.
- License status: `approved_public`, `permission_required`, `no_republication`, `unknown`.
- Authentication method, token management, endpoint and rate limits.
- Price granularity and publication cut-off time.
- Payload shape; units (`Rp/kWh`, `CHF/kWh`, `CHF/MWh`); local/UTC timestamps.
- Whether values represent energy, network, complete electricity price, VAT, levy, capacity charge or all-in.
- Eligibility for that product; smart-meter and EMS requirements; fallback tariff.
- Unavailable-data behavior, source timestamp, expected number of intervals, delivery delays.
- Maintainer, support contact, incident log and automated regression test fixture.

**Critical:** verify all provider endpoint details in live official documentation before coding. Never hardcode assumed JSON response schema on the strength of marketing pages.

## 2. External roadblocks / risk register

| ID | Blocker | Severity | Mitigation/owner |
|---|---|---|---|
| R01 | Households generally cannot change local supplier | Critical | Design local tariff choices vs national information as separate modules; product/legal |
| R02 | Dynamic tariffs only apply to enrolled eligible customers | Critical | Ask for exact tariff, never infer; product |
| R03 | EKZ/Primeo may require compatible EMS (not advice app) | Critical | Mark eligibility; target CKW/other manual-friendly segments first; product |
| R04 | Access/redistribution license unclear | Critical | Written commercial API permission, legal review; founder |
| R05 | API only includes network component | High | Componentized price model, explicit partial estimates; backend |
| R06 | Day-ahead publication or service outage | High | Retry, cached last-good, no false fresh price, notify degraded status; backend |
| R07 | Daylight saving 23-/25-hour days | High | UTC storage, Europe/Zurich UI, interval overlap math; backend |
| R08 | Appliance real energy profile varies by program | Medium | Editable profiles and confidence label; app |
| R09 | Very small per-cycle savings | Critical | Measure actual economics, avoid overpricing, broaden to EV later; founder |
| R10 | Notification delivery not exact/reliable | Medium | Server retry + local reminders + quiet hours + opt-in; mobile |
| R11 | Store payment compliance and fees | High | Review Apple/Google policies and eligible payment routes; founder |
| R12 | Privacy/security and user consent | High | Swiss nDSG, encryption, deletion/export, least privilege; backend |
| R13 | Competition from utility apps and Solar Manager | High | Focus clear personalized advice, accessible/no hardware, billing explainer; product |
| R14 | Smart meter data inaccessible | Medium | No meter access required in MVP; use estimates; product |
| R15 | Cloud inverter control rights | High (later) | Read-only research, developer agreements, model matrix; integrations |
| R16 | Smart-home safety/device warranties | Critical (later) | Approved control paths, no forced-start via mains, fail-safe local override; engineering |
| R17 | Solar export remuneration complexity | High (later) | Separate import/export rules, guaranteed minimums, contract specificity; domain |
| R18 | Provider mapping not unique to postal code | Medium | Municipality + authoritative operator verification and manual override; data |
| R19 | Historical tariffs may be amended/incorrect | Medium | Versioned snapshots, provenance and reconciliation; data |
| R20 | Pricing incl. VAT/base fee confusion | High | Per-component flags and visible assumptions; backend/UX |

## 3. Data usage and safety policy

- System must not scrape protected provider portals or bypass authentication.
- All data ingestion via documented interfaces or expressly licensed data.
- Clear attribution and terms link to each source.
- Do not save energy usage patterns or household addresses beyond user need; prefer municipality and postcode.
- No inference of occupancy or sharing of household behavior with third parties.
- Disable suggestions when prices are stale/missing or tariff eligibility unknown; offer historical education only.
- Never automate potentially hazardous device operation in MVP.

---

# PART IV — Cursor implementation specification

## 1. Target stack

**Frontend/mobile:** React 19 + TypeScript + Vite + Tailwind + shadcn/ui + Recharts, React Router only if required, TanStack Query, Zustand (minimal), `@capacitor/core`, `@capacitor/android`, `@capacitor/push-notifications`, `@capacitor/local-notifications` subject to platform rules. PWA as alternative entry point.

**Backend:** Python 3.12+, FastAPI, Pydantic v2, SQLAlchemy 2, Alembic, PostgreSQL 16, httpx, Redis optional, APScheduler for simple single-worker development; use queue/scheduler with distributed locking in production (Celery/RQ/Arq or equivalent). pytest, respx/httpx mocking, ruff, mypy. Authentication via self-hosted verified JWT/JWKS service (e.g. Supabase Auth) or standards-compliant OAuth; no homegrown password crypto.

**Infrastructure:** Docker Compose local, HTTPS reverse proxy (Caddy/nginx), CI for tests and migration checks, secrets via environment manager, monitoring via Sentry/OpenTelemetry, object storage only when necessary.

**Architecture:** modular monolith; **do not** create 12 microservices. Separate Python packages for `catalog`, `providers`, `tariffs`, `optimizer`, `comparisons`, `notifications`, `billing`, `auth`, `admin`.

## 2. Suggested monorepo structure

```text
swiss-energy-assistant/
  README.md
  docs/
    PRODUCT_SPEC.md
    API_PROVIDERS.md
    API_CONTRACT.md
    LOVABLE_PROMPT.md
    RISK_REGISTER.md
  backend/
    app/
      main.py
      core/{config.py,security.py,logging.py,clock.py}
      api/v1/{auth.py,providers.py,tariffs.py,appliances.py,recommendations.py,comparisons.py,alerts.py,billing.py,admin.py}
      models/{user.py,household.py,provider.py,tariff.py,appliance.py,notification.py,subscription.py}
      schemas/
      services/{tariff_normalizer.py,optimizer.py,cost_calculator.py,comparison_engine.py,notification_scheduler.py}
      integrations/providers/{base.py,ckw.py,groupe_e.py,ekz.py,primeo.py,elcom.py,fixtures.py}
      jobs/{ingest.py,reconcile.py,digest.py,cleanup.py}
      db/{session.py,migrations/}
    tests/{unit/,integration/,fixtures/,contract/}
    Dockerfile
    pyproject.toml
  frontend/
    src/{components/,features/,hooks/,lib/,types/,pages/Dashboard.tsx}
    capacitor.config.ts
    package.json
  docker-compose.yml
  .env.example
  .github/workflows/ci.yml
```

## 3. Database model (Postgres)

Use UUID IDs, timestamps in UTC (`timestamptz`), indexes on provider/tariff/time and subscription state. Store price in **DECIMAL/NUMERIC** to avoid floating currency drift. For timeseries, unique `(tariff_id,start_utc,end_utc,component,version)`.

### Tables

- `users`: id, auth_subject, locale, timezone, created_at, deleted_at.
- `households`: id, owner_user_id, label, postal_code, municipality_id, distribution_operator_id, address_optional_encrypted, annual_kwh_estimate, created_at.
- `providers`: id, slug, name, territory, docs_url, license_status, publication_time_local, native_granularity_minutes, active.
- `provider_tariff_products`: id, provider_id, name, tariff_type (`FIXED|HT_NT|DYNAMIC_GRID|DYNAMIC_ENERGY|DYNAMIC_COMBINED`), eligible_from/to, requires_ems, requires_smart_meter, eligibility_text, official_url, is_selectable.
- `household_tariff_enrollments`: id, household_id, product_id, status (`USER_CLAIMED|VERIFIED|UNKNOWN|INELIGIBLE`), verified_at, notes.
- `tariff_import_batches`: id, provider_id, product_id, requested_at, published_at, fetched_at, checksum, source_url, schema_version, status, error, usage_license_snapshot.
- `tariff_intervals`: id, batch_id, product_id, component, start_utc, end_utc, price_chf_per_kwh NUMERIC(14,6), tax_included, quality (`ACTUAL|FORECAST|ESTIMATED|STALE|UNAVAILABLE`), source_timezone.
- `tariff_fixed_components`: id, product_id, name, amount_chf NUMERIC, period (`MONTH|YEAR|DAY`), tax_included, valid_from/to, source_url.
- `regulated_tariff_annual`: id, year, municipality_id, operator_id, tariff_product, consumption_category, energy_rp_kwh, grid_rp_kwh, metering_chf_year, levies_rp_kwh, base_chf_year, total_chf_year, provider_source, raw_record_hash.
- `appliances`: id, household_id, type, display_name, duration_minutes, energy_kwh NUMERIC, profile_json, earliest_start, latest_finish, weekdays, quiet_hours_policy, active.
- `recommendations`: id, household_id, appliance_id, tariff_batch_id, run_date, best_start_utc, best_end_utc, modeled_cost_chf, baseline_cost_chf_nullable, potential_savings_chf_nullable, priced_components, confidence, data_quality, state, calculated_at.
- `notification_preferences`: id, user_id, channel, enabled, daily_digest_local_time, reminder_lead_minutes, quiet_hours_start/end, push_token_ref.
- `notification_outbox`: id, user_id, channel, dedupe_key, payload_json, scheduled_utc, sent_utc, status, attempts, last_error.
- `subscriptions`: id, user_id, billing_provider, provider_customer_id, entitlement, plan, current_period_end, state, updated_at.
- `audit_events`: id, actor_id, action, entity_kind, entity_id, metadata_redacted_json, created_at.
- `consents`: id, user_id, consent_version, type, accepted_at, withdrawn_at.

Optional: `provider_api_health`, `tariff_eligibility_rules`, `data_license_records`, `comparison_runs`, `telemetry_events` (privacy-safe).

## 4. Provider connector abstraction

```python
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

@dataclass(frozen=True)
class PriceInterval:
    start_utc: datetime
    end_utc: datetime
    component: Component
    chf_per_kwh: Decimal
    tax_included: bool
    quality: str
    source_id: str

class ProviderAdapter:
    async def fetch(self, product_id: str, start_utc: datetime, end_utc: datetime) -> list[PriceInterval]:
        raise NotImplementedError

    async def health(self) -> dict:
        raise NotImplementedError
```

Each adapter must parse only its official documented schema. Use fixture adapters to support frontend development independently from live API access. Never introduce a fallback that passes fake price data as genuine live data.

## 5. Ingestion and scheduling

- Define per-provider publication cut-off in Europe/Zurich; schedule retrieval **after** publication time with a configurable grace period.
- For CKW, check after ~12:00; Groupe E and Primeo after ~18:00; EKZ after its documented publication time. Verify each schedule in live docs.
- Retry with capped exponential backoff + jitter on transient failures; honor HTTP 429 and `Retry-After`.
- Use distributed lock by `(provider,product,delivery_date)` to prevent duplicate ingestion across worker replicas.
- Validate continuity, monotonic intervals, no overlaps, expected Swiss local-day coverage and correct schema/unit bounds.
- Store source payload checksum/batch audit. Publish a `tariff_available` event only when validated.
- Recompute impacted household recommendations and enqueue digests/reminders idempotently.
- If tariff later changes, invalidate stale recommendations, recompute and send a correction only when material; prevent notification spam.
- On outage, show last successful publication but do not recommend future appliance windows from stale values without clear warning.

### DST tests

- Europe/Zurich spring forward = 23-hour day, 92 quarter-hour slots; autumn back = 25-hour day, 100 quarter-hour slots. Hourly analogs 23 and 25.
- Always store UTC instants + offset-aware timestamps; never assume each civil date contains exactly 96 slots.
- Ambiguous 02:00 repeated in October must be disambiguated by UTC offset in storage and chart tooltips.

## 6. Optimization pseudocode

```python
def find_best_starts(appliance, tariff_intervals, earliest, latest_finish, step_minutes=15):
    candidates = []
    for start in utc_timeline(earliest, latest_finish - appliance.duration, step_minutes):
        end = start + appliance.duration
        if violates_user_constraints(appliance, start, end):
            continue
        # Integrate per-interval energy against known tariff components.
        # Default flat profile may be used ONLY with 'approximate' confidence label.
        cost, coverage = integrate_consumption(appliance.power_profile, start, end, tariff_intervals)
        if coverage.is_complete_for_claimed_price_components:
            candidates.append((start, end, cost, coverage))
    return sorted(candidates, key=lambda x: (x[2], x[0]))
```

Additional algorithm requirements:

- Calculate 3 cheapest non-overlapping *suggestions* per appliance, subject to deadlines.
- Support variable price interval width independent of optimizer candidate step.
- Use exact overlapping duration, not rounded slot counts; flat default power = `energy_kwh/(duration_minutes/60)`.
- Reject schedules that violate allowed-hours constraints; offer user-adjustable finish deadline.
- Do not optimize against wholesale spot prices for retail households unless their actual tariff contract follows those prices.
- Keep `baseline_start` explicit; if absent, display "Estimated cheapest cost" but not claimed "You saved".

## 7. REST API contract (v1, proposal)

All endpoints prefixed `/api/v1`. Use auth bearer token on private routes, standard error envelope `{code,message,request_id,details}`. Paginate collections. Return ISO8601 offset-aware timestamps and separate `timezone` value.

| Method | Path | Purpose |
|---|---|---|
| GET | `/healthz` | Health check |
| GET | `/providers` | Supported providers and capability/quality metadata |
| GET | `/providers/{id}/products` | Product catalog, rules and eligibility |
| GET | `/locations/search?query=` | Municipality/postcode search |
| GET | `/tariffs/intervals?product_id=&date=` | Normalized timeline + components + freshness |
| GET | `/tariffs/summary?product_id=&date=` | Min/mean/max known components, chart aggregates |
| GET | `/annual-tariffs?year=&municipality_id=&profile=` | ElCom regulated annual comparison |
| POST | `/auth/bootstrap` | Safe app user initialization |
| GET/PUT | `/me/household` | User's selected home and tariff enrollment |
| GET/POST | `/me/appliances` | Add/list appliances |
| PATCH/DELETE | `/me/appliances/{id}` | Modify/remove appliance |
| POST | `/recommendations/preview` | Optimization without saving |
| GET | `/me/recommendations?date=` | Saved recommendations |
| POST | `/me/recommendations/{id}/remind` | Schedule reminder idempotently |
| GET/PUT | `/me/notifications/preferences` | Subscription and quiet hours |
| POST | `/me/push-tokens` | Register per-device push token |
| DELETE | `/me/push-tokens/{id}` | Unregister |
| POST | `/comparisons/local` | Compare local eligible products with assumptions |
| GET | `/comparisons/switzerland?year=&profile=` | Educational geographic comparison |
| GET | `/me/subscription` | Effective entitlement |
| POST | `/webhooks/billing/{vendor}` | Verified signatures, deduped events |
| GET | `/admin/providers/health` | Authenticated ops monitoring |

### Example normalized tariff response

```json
{
  "product_id": "ckw-dynamic-grid-example",
  "display_name": "CKW Dynamic Network — illustrative contract identifier",
  "date_local": "2027-01-15",
  "timezone": "Europe/Zurich",
  "published_at": "2027-01-14T12:00:00+01:00",
  "fetched_at": "2027-01-14T12:10:00+01:00",
  "data_state": "LIVE_VERIFIED",
  "resolution_minutes": 60,
  "currency": "CHF",
  "scope": "GRID_ONLY",
  "all_in_price_available": false,
  "intervals": [
    {
      "start": "2027-01-15T00:00:00+01:00",
      "end": "2027-01-15T01:00:00+01:00",
      "component": "GRID_USAGE",
      "price_chf_per_kwh": "0.075000",
      "tax_included": false
    }
  ],
  "source_url": "https://www.ckw.ch/energie/strom/dynamischer-tarif-fuer-privatkunden-und-unternehmen/dynamischer-tarif-technische-voraussetzungen",
  "disclaimer": "EXAMPLE DATA ONLY. This payload is a fixture, not an actual CKW price quotation."
}
```

## 8. Notifications

**Trigger types:** `DAY_AHEAD_DIGEST`, `START_REMINDER`, `TARIFF_REVISED`, `API_UNAVAILABLE` (last type admin-only by default).

**MVP default:** one notification per day after published tariff, not automatic daily alerts if nothing useful changes; optional reminder 15 minutes before best selected window.

**Rules:** user opt-in; max 2 unsolicited notifications/day by default; quiet hours; locale; push token refresh; notification deep link to dashboard; dedupe; schedule only after tariff validation; preserve pending/delivered state. For local device reminders use Capacitor local notifications where supported, with OS permission handling; backend push fallback should avoid duplicates.

**Template (DE):** `Morgen ist dein Geschirrspüler zwischen 13:15 und 15:30 voraussichtlich am günstigsten. Grundlage: dein gewählter [Tarifname].`  
**Template (EN):** `Tomorrow, the lowest estimated-cost dishwasher window is 13:15–15:30. Based on your selected [tariff].`

Savings claims only if assumptions are explicitly stated. Avoid "guaranteed" language.

## 9. Security and compliance

- TLS everywhere; JWT verification with issuer/audience validation; role-based admin authorization.
- Provider tokens in server secrets, never shipped in frontend/mobile bundle.
- Rate limiting on APIs; protection from brute-force, spam, path traversal, SSRF; strict outbound host allowlist.
- Household ownership checks on every data access (never trust `user_id` in request body).
- Encrypted credential/token storage and backups; minimal PII; only consented notifications.
- FADP/nDSG privacy notice and retention schedule; account deletion/export; audit sensitive actions.
- Avoid intrusive assumptions about household presence from appliance schedules.
- Subscription webhooks verify signatures and are idempotent. Never grant access solely on client-supplied payment status.
- Inverter/control credentials absent from MVP entirely.

## 10. Analytics and key metrics

Capture privacy-respecting, consent-appropriate product events:

- onboarding started/completed, provider selected, tariff eligibility status
- appliance created, recommendation viewed, reminder created/opened
- notification delivered/failed, tariff API success/staleness
- `estimated_savings_chf` with baseline method and confidence
- user-reported "I followed recommendation"
- conversion to annual subscription, renewal/cancellation, support requests

KPIs: successful daily ingestion per provider >99% after publication grace; recommendation correctness 100% against golden fixtures; digest send success >95% under platform/network conditions; 30-day retention; conversion; churn; estimated net savings/customer; support hours/100 users.

## 11. Tests (minimum required)

1. Quarterly-hour vs hourly prices; mixed fixed/dynamic components.
2. DST transition days (92/100 quarter-hour intervals), midnight crossing, repeated local hour.
3. Timezone conversions across UTC and Europe/Zurich.
4. Various appliance durations (45, 90, 135, 180 minutes), earliest start/latest finish.
5. Unavailable tariff intervals, partial component coverage, zero/negative prices.
6. Correct VAT inclusion and fixed fee exclusion from marginal savings.
7. Provider payload schema change, HTTP 429/500, timeout, duplicate ingestion, revised publication.
8. Auth ownership, request validation, secrets leakage, notification opt-out/deduping.
9. Annual comparison across operator/year and local eligibility; non-switchable disclaimer.
10. API snapshots/UI contract fixtures and accessibility tests.

## 12. Definition of done for Cursor's first implementation

- Project boots with `docker compose up --build` and a single documented `.env.example`.
- Backend exposes valid `/docs` OpenAPI and health checks; migrations auto-run **only in dev**.
- Two adapters integrated (CKW + Groupe E) **if live access and permitted terms confirmed**; otherwise fixtures plus adapters in `NEEDS_ACCESS` state, without fabrication.
- ElCom annual dataset importer/fixture working.
- Working household/appliance CRUD and deterministic optimization endpoint.
- Responsive frontend loads live or clearly labeled demo state.
- Android Capacitor shell runs (where build environment supports Android SDK); iOS source prepared, not falsely claimed built on Linux.
- Daily notification scheduling uses mocks in dev and documented production provider credentials.
- CI passes unit/integration tests, security lint and a reproducible sample dataset.
- No automatic electrical switching implemented in this stage.

---

# PART V — Lovable.dev front-end implementation prompt

> **Copy the entire block below into Lovable.dev.** Generate ONLY the front-end, using mock data initially. Connect generated TypeScript API client to FastAPI endpoints in Part IV after export. Avoid creating a separate backend or introducing Supabase if the backend already owns auth and data.

```text
Build a polished, production-quality, mobile-first SINGLE-PAGE dashboard for a Swiss electricity-price intelligence app called "Swiss Energy Assistant".

Product purpose: show a Swiss household its actual electricity tariff, tomorrow's known time-based prices, personalized cheapest starting times for dishwasher/washer/dryer/EV charging, tariff component explanations, and a legally accurate comparison of available local tariff products versus informative nationwide electricity-price benchmarks. No automation or appliance switching in v1.

Tech: React + Vite + TypeScript + Tailwind + shadcn/ui + Recharts + TanStack Query; responsive down to 360px. This screen will be packaged in Capacitor for mobile. Build reusable components, centralized types/API client, and a mock API service with deterministic Swiss example data. DO NOT create the backend. DO NOT make this a multi-page SaaS dashboard with a sidebar. One page and user-friendly bottom navigation/anchor tabs on mobile.

Visual direction: premium Swiss utilities aesthetic, white/soft gray surfaces, dark charcoal text, restrained teal or emerald accent, excellent spacing, strong numeric typography, friendly clear appliance icons, subtle charts, no gradients covering content, no excessive decoration, no cramped enterprise admin layout. Provide polished dark mode optionally. Localize visible strings with English, German and French dictionaries (German as default for Swiss rollout, easy toggle).

SCREEN LAYOUT:
1. Slim header: logo/brand left, municipality & energy provider selector, tariff plan name, settings/user menu, language.
2. Hero insight: "Best time to run your appliances" with tomorrow date; status pill "Tomorrow's prices available" or "Awaiting utility data". Large recommended window and price insight; short explanation and optional "Remind me" CTA.
3. Tariff line/area chart: next 24–48h at real provider granularity; distinct energy/network series if available, all-in only if complete. Let users toggle Today/Tomorrow and display shaded appliance run windows. Accessible tooltip with Swiss time (Europe/Zurich), price CHF/kWh or Rp/kWh, tariff component, data source, freshness. Never interpolate fabricated high-frequency prices; plot hourly rates as steps when appropriate.
4. Appliance section: cards for dishwasher, washer, tumble dryer and EV. Each card shows icon, program duration, estimated kWh, latest finish time, best start, cost and hypothetical savings vs explicitly named baseline. Inline edit drawer to edit durations, power use, allowed hours/deadline; reminder toggles. "Add appliance" modal.
5. Tariff breakdown component: energy, network usage, metering, grid levies, communal charges, VAT, fixed fees; data-completeness label. Where API supplies only grid price, say "Network charge only — not full electricity price".
6. Comparison area with TWO separate tabs:
   A) "My local tariff options" — current plan vs other provider products for which user is eligible, projected annual bill with assumptions and enrollment rules (including EMS/smart-meter prerequisites).
   B) "Swiss price explorer" — compare regulated annual tariffs by municipality/network operator (ElCom data) with prominent note: "Most Swiss households cannot freely switch suppliers; these are benchmarks, not switching offers."
7. Recent notifications & preferences: daily summary time, reminder lead time, quiet hours, phone push opt-in, optional peerDesk channel; show sample alerts.
8. Footer trust row: last refresh time, utility docs link, methodology tooltip, pricing caveat, privacy/contact.

ONBOARDING OVERLAY:
- Step A: choose language
- Step B: postcode/municipality and likely network operator (with manual correction)
- Step C: select exact household tariff product, or "I am not sure". Display eligibility badge:
  CONFIRMED, USER-CLAIMED, UNKNOWN, or INELIGIBLE. If EMS required, display plain warning that manual notification app does not satisfy that requirement.
- Step D: choose 1–3 appliances, their duration and latest acceptable completion
- Step E: opt into notifications
Do not force users into a paid checkout to view example tariff data.

UI STATES:
- Loading skeletons, no data, stale data, API outage, missing next-day publication, partial tariff components, unknown customer tariff, notification permission denied, and trial/subscription expired.
- A DEMO label must appear on all mock prices, cost and saving figures. Never present fixtures as actual prices.
- CHF currency, Swiss formatting, Rp./kWh notation, 24-hour clock, Europe/Zurich timezone, DST edge behavior.
- Accessibility WCAG AA contrast, keyboard focus, alt/aria labels and chart data table fallback.

USER INTERACTIONS:
- Change provider and tariff and update chart/cards based on mock data service.
- Change appliance cycle duration and finish deadline; recalculate mock recommendations deterministically (demo only) and show clear explanation.
- Toggle reminders; show state; do not pretend to send production push notifications in preview.
- Compare local tariffs in a sortable table; nationwide explorer clearly informational.
- Date Today/Tomorrow; settings drawer; language toggle.

DATA / API INTEGRATION:
Create `src/lib/api.ts` with typed API client interface for:
GET /api/v1/providers
GET /api/v1/providers/{id}/products
GET /api/v1/tariffs/intervals?product_id=&date=
GET /api/v1/annual-tariffs?year=&municipality_id=&profile=
GET /api/v1/me/household
GET /api/v1/me/appliances
POST /api/v1/recommendations/preview
GET /api/v1/me/recommendations?date=
GET/PUT /api/v1/me/notifications/preferences
GET /api/v1/me/subscription

Create `src/lib/mockApi.ts` implementing the same interface, switchable using env `VITE_USE_MOCK_API=true`. All sample datasets must be clearly synthetic. Provide a README listing API assumptions and steps to connect the FastAPI backend. No hardcoded provider secrets. All responsive UI routes on one dashboard page.

DELIVERABLES: complete runnable responsive React front end, reusable components, sample data, API adapter contract, onboarding overlay, and implementation README. Optimize for clarity and speed rather than visual extravagance.
```

---

# PART VI — Ready-to-paste Cursor AI master instruction

> **Copy this brief into Cursor** along with this full Markdown file as `docs/PRODUCT_SPEC.md`.

```text
Read docs/PRODUCT_SPEC.md in its entirety. Implement Swiss Energy Assistant as a modular-monolith FastAPI backend plus mobile-first React/Vite/Capacitor frontend. Follow Part IV as the source of truth for architecture, schemas, APIs, calculation semantics, and tests. Build in small reviewable milestones, each ending with passing automated tests and a working Docker Compose environment.

First inspect the existing repository. If code exists, produce a gap analysis and preserve working architecture wherever appropriate; do not overwrite existing peerDesk or other applications. If no code exists, scaffold the proposed monorepo. Use environment variables and .env.example for config. Do not assume vendor credentials exist. Any vendor with undocumented schemas or unclear commercial access must use a clearly labeled fixture and status NEEDS_ACCESS; never fabricate live tariffs.

Implementation order:
M1 scaffold, auth, migrations, health, CI, Docker;
M2 provider catalog + CKW/Groupe E adapter interfaces and fixtures + validation and ingestion jobs;
M3 tariff interval normalization, DST coverage, component pricing rules, fixed/HT-NT support;
M4 appliance CRUD and time-window optimization with golden tests;
M5 comparison engine using ElCom annual tariff data and local eligibility rules;
M6 REST endpoints with OpenAPI contracts, sample fixtures and SDK types;
M7 connect Lovable-generated single-page dashboard and user onboarding;
M8 push preference and scheduling backend; Capacitor Android shell;
M9 subscription scaffolding (no unverified store payment shortcuts), admin health and security;
M10 production hardening, documentation and pilot analytics.

At the start of each milestone, produce file-level plan and acceptance tests. At its end, list the files changed, exact commands to run, passed tests, open questions and risks. Prioritize a complete runnable MVP. Do not implement smart-home switching, PV control, wholesale trading, solar export arbitrage or own electrical hardware in MVP. Enforce the distinction between dynamic network tariff and total customer electricity bill. All claims of savings must have traceable baseline and source.
```

---

# PART VII — Commercial model and business case

## Monetization experiments

- Free public annual regulated tariff explorer and limited time windows (acquisition).
- Paid notifications, custom appliance profiles, reminders and tariff cost breakdown at **CHF 10–12 per year**, subject to pilot validation.
- CHF 1/month optional only where store billing and transaction fees permit sustainable unit economics.
- **No "CHF 10 lifetime"** until economics of indefinite data maintenance and support are understood; one-time fee could instead be 12-month access without automatic renewal, clearly disclosed.
- Later premium tariff optimizer for solar/EV or B2B API/installer partnerships.

## Unit economics example (explicitly illustrative)

Annual revenue at 1,000 paid accounts × CHF 10 = CHF 10,000 gross/year before VAT, payment/store fees, infrastructure, customer support and marketing. If an average customer saves CHF 20/year from real actionable tariff shifts, CHF 10 pricing may feel marginal. If a household can shift substantial EV/hot-water demand, the value proposition improves. Do not use theoretical maximum savings as marketing proof.

## Distribution

- Regional solar/EV installer newsletters (later), local energy-saving communities, utility-neutral explanatory content and SEO landing pages per commune.
- peerDesk as an optional notification and acquisition channel without vendor lock-in.
- Free annual tariff explorer for organic search; make comparisons transparent, source-backed and non-switching by default.
- Start marketing only to customers whose selected tariff is verified and whose profile offers meaningful flexibility.

## Growth hypotheses to test

1. Customers value a **simple daily reminder**, even without automation.
2. Transparent bill comparison drives signups, even if national supplier switching isn't possible.
3. Manual scheduling saves enough for at least 20–30% of engaged dynamic-tariff customers to pay CHF 10/year.
4. Appliance time constraints and local habits can be modeled adequately with editable profiles.
5. The service's provider API and support costs can be spread across many customers.
6. A no-gateway approach is useful later for PV and EV monitoring, but device control remains gated.

## Go/no-go decision after pilot

Proceed to paid launch if: provider data rights are clear; a high percentage of targeted enrolled customers get correct, timely recommendations; users follow them; enough report value or commit to paying; unit economics remain favorable. If not, keep educational comparison free and shift toward high-consumption flexible loads or B2B analytics.

---

# PART VIII — Future solar and home automation extensions (explicitly out of scope for MVP)

## Solar intelligence (read-only first)

- Collect solar generation, battery charge state, grid export/import and manufacturer metadata via authorized API.
- Potential vendors: Huawei SUN2000/LUNA2000 (model-dependent Modbus or approved channel), Sungrow iSolarCloud, Fronius Solar API/Modbus, SMA developer platform. Do not assume every device supports writable commands.
- Compute self-consumption opportunity and tariff-aware **manual** recommendations before automated battery scheduling.
- PV remuneration is separate from household import tariffs. Include 2027 feed-in market rules, contract overrides, guarantees of origin, minimum remuneration mechanisms and data licensing.

## Smart home integration

- Read-only Home Assistant connector first; user permissions, local network discovery only by consent.
- Appliance auto-start only via explicitly authorized manufacturer API and appliance safety features (remote start enabled).
- Suitable smart plug switching is for allowed devices only; never rely on power restoration to start a dishwasher/washer/dryer.
- Industrial loads/boilers/heat pumps via qualified installer and approved hardware/controller.

## Own hardware — only after product-market fit

- Consider ESP32-C3 low-voltage communication gateway as R&D; do not ship exposed mains relay board.
- For Swiss commercial sale, budget for NEV/ESTI electrical product compliance, EMC, radio requirements, testing, product liability, manufacturing QC and support.
- Prefer integrating certified third-party plugs/controllers instead of manufacturing initially.

## Potential B2B platform

Normalized Swiss tariff API (provider abstraction, licensing controls, update guarantees), white-label appliance recommendations, comparison analytics and installer energy reports. Validate paid demand; incumbents already operate in this space.

---

# PART IX — Open questions and decision log

**Decisions already proposed:**
- Software/mobile app before PV or home automation.
- FastAPI backend, React/Vite lightweight one-page dashboard generated with Lovable, Capacitor mobile shell.
- Tariff component-aware comparison and recommendation engine.
- peerDesk optional notification channel, not mandatory user onboarding.
- CHF 10/year as initial *hypothesis*, no unconditional lifetime service promise.

**Outstanding validations:**
- Provider-level commercial permission to access/cache/show tariff data, including API credentials.
- Confirm precise API schemas and how energy/network/levies/VAT are represented.
- Verify CKW notification-only users' contractual eligibility; EKZ/Primeo EMS requirements may exclude notification-only enrollment.
- Distribution-area mapping for users in mixed-provider postcodes.
- Suitable Android/iOS store billing implementation based on current rules.
- Subscription willingness to pay and actual incremental avoided cost.
- Language order and launch marketing brand.
- Swiss data hosting and privacy counsel review.

**Explicitly deferred:** inverter writes, battery export commands, home switching hardware, AI agent control, wholesale licensing unless needed for PV export economics.

---

# APPENDIX — Verified sources and references

All references accessed or cross-checked in October 2026; check version and eligibility when implementing. Source pages may change.

- **[S1] ElCom, basic supply and free market:** https://www.elcom.admin.ch/en/basic-supply-and-free-market — households <100 MWh/year generally cannot freely choose energy supplier.
- **[S2] ElCom, FAQ tariffs:** https://www.elcom.admin.ch/de/faq-stromtarife — dynamic tariff frameworks, tariff components and regulatory context.
- **[S3] ElCom, tariff data and visualizations:** https://www.elcom.admin.ch/de/tarifdaten-und-visualisierungen — 2027 annual regulated tariffs, municipality/operator mapping, LINDAS data; and https://www.elcom.admin.ch/en/tariff-data-and-visualisations.
- **[S4] CKW dynamic technical API:** https://www.ckw.ch/energie/strom/dynamischer-tarif-fuer-privatkunden-und-unternehmen/dynamischer-tarif-technische-voraussetzungen — hourly dynamic network price; public JSON API; next day from noon; parameters may be required. Product overview: https://www.ckw.ch/energie/strom/dynamischer-tarif-fuer-privatkunden-und-unternehmen.
- **[S5] EKZ dynamic optional tariff:** https://www.ekz.ch/de/angebote/strom/tarife/dynamischer-wahltarif.html — 15-minute tariff, communicating smart meter and EMS requirements.
- **[S6] Groupe E VARIO:** https://www.groupe-e.ch/fr/electricite/vario and technical PDF https://www.groupe-e.ch/fr/sites/default/files/download-items/tarif-dynamique-option-vario.pdf — quarter-hour price data and official API endpoint.
- **[S7] Primeo Dynamisch:** https://www.primeo-energie.ch/privatkunden/strom-beziehen/dynamisch.html — 2027 hourly dynamic energy+network; EMS/smart meter prerequisites; current API information in https://tarife.primeo-energie.ch/api/v1/tariffs (verify updated interface and rights).
- **[S8] VSE feed-in pricing data access 2027:** https://www.strom.ch/de/news-und-medien/abnahmeverguetung-2027-mehr-klarheit-ueber-die-bereitstellung-der-massgebenden-marktpreise — federal quarterly publication and separately licensed daily EPEX data.
- **[S9] SmartGridready OpenAPI:** https://smartgridready.github.io/docs/content/openapi-specifications.html and https://smartgridready.github.io/docs/_static/swagger/dynamic-tariff-v2.html — v2 interface spec for 2027, not an operational data source.
- **[S10] 2027 federal official tariff figures:** https://www.uvek.admin.ch/de/newnsb/1miE201yRzoA — ElCom/SFOE 2027 aggregate benchmark, not a tariff applicable to any individual home.

---

## Immediate next actions (the 10 tasks to execute first)

1. Select brand and reserve project repo/domain.
2. Read CKW + Groupe E official tariff/API docs and check commercial permissions.
3. Ask two relevant utility representatives whether manual notification subscribers are eligible for dynamic tariffs.
4. Obtain ElCom 2027 annual tariff dataset and operator mapping.
5. Create repo, Docker Compose, backend schema, migrations.
6. Build two adapter fixtures and actual adapters only after checking API schema/access.
7. Implement DST-safe tariff cost optimizer + tests.
8. Paste Part V into Lovable.dev and export one-page mobile dashboard.
9. Paste Part VI into Cursor and integrate frontend/backend and Capacitor notifications.
10. Recruit 20 pilot homes, measure follow-through/savings and test CHF 10/year subscription.

**Implementation discipline:** every savings number should be labeled by source, tariff scope, confidence, user eligibility and baseline. Treat trust as the product's core asset.
