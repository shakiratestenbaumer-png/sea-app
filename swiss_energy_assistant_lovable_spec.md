# Swiss Energy Assistant — Lovable.dev Frontend Specification

**Version:** 1.0  
**Date:** 28 October 2026  
**Target:** Lovable.dev → export React/Vite frontend → Cursor AI integration with FastAPI  
**Product:** Switzerland-focused electricity tariff intelligence and manual appliance scheduling  
**Release:** Software-only MVP. No connected appliance switching or solar-control commands.

---

## 0. Instructions to Lovable.dev — paste this project brief

> **Build a polished, production-ready, MOBILE-FIRST, SINGLE-PAGE React dashboard for a Swiss electricity tariff assistant called “Swiss Energy Assistant.”** It helps residents understand their actual utility tariff, view next-day time-varying prices where offered, choose low-cost windows for manually operating dishwasher, washing machine, tumble dryer and EV charger, and compare eligible local plans versus informational Switzerland-wide benchmarks. It does **not** switch equipment on/off.
>
> **Frontend only.** Do not create Supabase tables, a backend, Edge Functions, external AI agents, mock external web calls, or new billing infrastructure. Existing FastAPI backend will own authentication, provider integrations, calculations, subscriptions, notifications and data persistence. Build a typed API-client boundary and deterministic DEMO fixtures so the dashboard works standalone today and can later be connected to FastAPI with minimal changes.
>
> **Technology:** React + Vite + TypeScript (strict) + Tailwind CSS + shadcn/ui + Recharts + TanStack Query. Lucide icons. Use React Router only if needed for browser history; all customer functionality lives on ONE dashboard route `/`. Frontend must be suitable for packaging as an Android/iOS app using Capacitor, but no native plugin implementation is required in Lovable. Responsive down to 360px width.
>
> **Visual language:** modern trustworthy Swiss consumer-finance/energy app; white/off-white backgrounds, charcoal typography, restrained teal/emerald accents, crisp typography, accessible contrast, generous whitespace, simple charts and calm cards. NOT a desktop admin panel, NOT a sidebar-heavy B2B SaaS template. Main content max width ~1200px desktop. Use a sticky lightweight bottom navigation on mobile to jump among Overview, Appliances, Compare, Alerts. No excessive gradients, no decorative stock images. German default, English and French toggle.
>
> **Core requirements:** (1) accurate current-provider/tariff identity and enrollment status; (2) next-day tariff chart with native 15-minute or hourly intervals (no fabricated subdivisions); (3) per-appliance optimal start times for the *entire noninterruptible cycle* and a labeled cost estimate; (4) editable appliance settings and real UI updates; (5) daily digest and optional reminder preferences; (6) two separate comparison experiences, eligible local tariffs vs Swiss-wide educational benchmarks; (7) attribution, freshness, coverage and honesty about partial costs. Every sample value clearly bears a DEMO label.
>
> **Build all components and frontend states described in this specification, using deterministic fixture data, types and hooks.** On completion provide a README, `.env.example`, documented API mapping, all source files, and a way to switch between `VITE_USE_MOCK_API=true` and a real API via `VITE_API_BASE_URL`. Never ship API tokens or credentials to the client.

---

## 1. Product outcomes and non-goals

### Primary user story

“I live in Switzerland, have a particular electricity contract, and want to know when to start my appliances to reduce my electricity bill. I do not want to install additional hardware.”

### Secondary user stories

- I can identify my local grid operator and exact tariff product without assuming my postcode alone proves tariff enrollment.
- I can see tomorrow’s prices and know which charges are included or excluded.
- I can set my dishwasher to finish before 22:00 and see the cheapest *start time* for that entire cycle.
- I can compare plans **offered to me by my existing supplier**, subject to eligibility.
- I can explore Swiss municipal electricity-price benchmarks without being misled into thinking I can freely switch supplier.
- I can receive a daily summary and configurable appliance reminders, with consent.
- I can tell whether prices are live, stale, missing, partly modeled, or demo examples.

### Explicit non-goals for MVP

No inverter/solar control, home automation, remote appliance start, smart plug switching, battery dispatch, electricity trading, spot-price speculation, real-time bill claims, unrestricted utility switching marketplace, or background continuous polling from the frontend. Do not show misleading “You saved CHF X” unless measured savings are available from a verified source; default to **“Potential savings”**.

---

## 2. Page information architecture

Keep one scrolling dashboard page, with anchored mobile navigation and light dialogs/drawers for editing.

1. **Header & account context:** Brand mark, city/postcode, grid operator, selected tariff name, tariff enrollment state, language selector, profile/settings button.
2. **Top insight card:** “Best time to run your appliances”; Today/Tomorrow selector; next-day publication status; prominent suggested time and concise reason; “Set reminder” action.
3. **Electricity price chart:** 24–48 hours if available; hourly/quarter-hour intervals preserved; step-based tariff visualization, component toggles, shaded recommended cycle. Tooltips include timestamp, CHF or Rp./kWh, components, source, freshness.
4. **Appliance scheduler:** Cards for dishwasher, washing machine, dryer, EV charger and add-custom. Duration, energy estimate, earliest start, finish deadline, start recommendation, forecast cycle cost, baseline cost, potential saving, configure, remind.
5. **Price explanation:** Energy, network, metering, taxes/levies, VAT and fixed charges with completeness indication; emphasize when only network portion is dynamic/known.
6. **Tariff comparison:** tabs for “My available tariffs” and “Swiss price explorer”; eligibility and assumptions visible.
7. **Notification preferences:** Daily digest opt-in/time, appliance reminder lead, quiet hours, phone push, optional peerDesk channel (marked future/integration pending unless backend supports it); last delivery status.
8. **Trust footer:** utility source links, source published time, last synced, price completeness, tariff-version info, methodology, privacy and support.

### Mobile layout

At 360–430px, cards stack and horizontal scrolling is limited to price graphs and optional tables. Use bottom navigation **Overview / Appliances / Compare / Alerts** as anchor navigation, not separate pages. Tap targets >=44px. A summary chart never makes the viewport too tall. No left sidebar. The first screen should explain a best usable time and the user’s selected supplier.

### Desktop layout

Two-column overview when appropriate (insight and daily summary), large chart below, 2–3-column appliance cards, full-width comparison. Preserve the one-page model.

---

## 3. Detailed component specifications

### 3.1 Setup / onboarding modal (5 steps)

- Step 1: language (Deutsch default; English; Français), brief explanation and consent link.
- Step 2: city or Swiss postcode search and suggested distribution/network operator. If ambiguous, user selects manually. Postcode does NOT prove the exact operator.
- Step 3: utility tariff product selection. Offer “I’m not sure” with bill-based help. Show eligibility state: `confirmed`, `user_claimed`, `unknown`, `ineligible`. Show specific requirements such as EMS/smart meter where provider/product says they are mandatory. **A notification-only app does not satisfy an EMS prerequisite.**
- Step 4: select 1–3 appliances and edit typical cycle duration, kWh, earliest permissible start and required finish time.
- Step 5: notification choices, quiet hours, optional account/subscription call-to-action. Do not require payment to see demo data.

Provide stepper progress, back/forward, validation, cancel, and persisted frontend draft state. Real persistence will use backend endpoints when connected.

### 3.2 Top insight

Display local date, price publication status (`available`, `awaiting_publication`, `stale`, `unsupported`, `partial`) and a recommendation based on the selected appliance. If no tariff enrollment is confirmed, show a caution and a sample clearly marked demo, not a live personalized savings claim. CTA “Remind me”, or “Choose my tariff” when missing.

### 3.3 Price chart

- Today/Tomorrow segmented control; local times in Europe/Zurich.
- Toggled lines or step plots: energy, network, and known variable total. Only label “total electricity price” when all required variable components are verified. Fixed annual/monthly costs separate.
- Shaded full appliance duration, not just one cheapest-price quarter hour.
- Hover/tap tooltip, selected interval, accessible summary table beneath chart toggle.
- Differentiate hourly tariff from 15-minute tariff; **never invent 15-minute movement from hourly data**.
- Price unit switch Rp./kWh ↔ CHF/kWh; explicit VAT inclusion.
- DST correctness: autumn day can have 25 hours and duplicated 02:00 with different UTC offsets; spring day 23 hours. Do not assume 96 slots/day.
- Show provider, published-at, fetched-at, data confidence and source URL.

### 3.4 Appliances

Each card shows icon/name, duration, estimated kWh, deadline, recommendation start/end, modeled cost, comparison against user-defined baseline, savings indicator and reminder button. Edit drawer with inputs:

`type`, `name`, `duration_minutes`, `energy_kwh`, `earliest_start_local`, `latest_finish_local`, `allowed_weekdays`, `notification_lead_minutes`, `preferred_baseline_start`, `must_be_home`, `quiet_hours_policy`.

Use compact defaults (e.g., washing machine 120 min, 1 kWh; dishwasher 150 min, 1.2 kWh; dryer 90 min, 2 kWh), explicitly labeled **illustrative assumptions**, editable and not asserted as universal measurements. A device run is non-pausable. Display 1 best window and up to 3 alternatives. Show “Estimate based on flat consumption profile” when no detailed appliance curve is known. Validate start <= finish minus duration; validate numbers; update recommendation deterministically in demo mode.

### 3.5 Tariff breakdown

Show variable cost components with availability indicators, `Rp./kWh`, `CHF/kWh`, annual fixed fees. If only grid charge is available, label “Network tariff only — not the full electricity bill.” If tax/VAT missing, explicitly show “Not included/unknown.” No false all-in total.

### 3.6 Comparisons

**Tab A — My local tariff options:** only supplier/product options genuinely applicable to user's service area, with eligibility, activation requirements, valid-from dates, annual projected cost using an explicit usage/profile assumption, fixed costs and data completeness. An inactive or EMS-required tariff must not be marked as already usable.

**Tab B — Swiss price explorer:** annual ElCom regulated household tariff benchmarks by municipality/network operator; filter year/profile (H1/H2/H4/H5 where supplied), show energy/network/taxes/metering breakdown and ranking/graph; prominent permanent caveat: **“Most households in Switzerland cannot freely choose another electricity supplier. Comparisons outside your area are informational benchmarks, not switching offers.”**

If national reference data is missing, show demo dataset clearly labeled. Do not suggest buttons to switch between distant electricity suppliers.

### 3.7 Notifications/settings

Daily digest toggle and preferred time; specific appliance reminder toggle and lead-time options (5/15/30/60 minutes); quiet hours; permission needed/denied UI; push channel and optional peerDesk (marked **Coming later** unless enabled by backend feature flag); sample preview; last delivered event only if backend reports it. Demo actions may update visible local preferences but must show “Demo — no notification sent.”

### 3.8 Status design

Build realistic skeleton/loading, no supported provider, tariff not selected, ineligible tariff, awaiting next-day prices, stale feed, partial tariff coverage, offline, backend error, chart with missing intervals, empty appliance list, notification permissions denied, expired entitlement. Every missing source or gap should be represented explicitly, not silently interpolated.

---

## 4. Data models (TypeScript interfaces)

Provide shared types under `src/types/energy.ts`. Suggested shapes (adapt to backend OpenAPI schema when available):

```ts
type IsoInstant = string; // RFC3339 UTC or ISO8601 with timezone offset

type TariffEligibility = 'confirmed' | 'user_claimed' | 'unknown' | 'ineligible';
type PublicationStatus = 'available' | 'awaiting_publication' | 'stale' | 'unsupported' | 'partial';
type ApplianceType = 'dishwasher' | 'washing_machine' | 'tumble_dryer' | 'ev_charger' | 'water_heater' | 'other';

type PriceComponent = 'energy' | 'network' | 'levies' | 'tax' | 'other';

interface Provider { id: string; name: string; website_url?: string; supported: boolean; }
interface TariffProduct {
  id: string; provider_id: string; name: string;
  interval_minutes?: number; // null if variable/unknown
  requires_ems?: boolean; requires_smart_meter?: boolean;
  eligibility: TariffEligibility; effective_from?: string;
}
interface TariffSlot {
  start: IsoInstant; end: IsoInstant;
  components_chf_per_kwh: Partial<Record<PriceComponent, number>>;
  verified_total_variable_chf_per_kwh?: number;
  source_url?: string;
}
interface TariffSchedule {
  product_id: string; date_local: string; timezone: 'Europe/Zurich';
  status: PublicationStatus; fetched_at?: IsoInstant; published_at?: IsoInstant;
  source_url?: string; vat_included: boolean | null;
  components_complete: boolean; intervals: TariffSlot[];
}
interface Appliance {
  id: string; type: ApplianceType; name: string;
  duration_minutes: number; energy_kwh: number;
  earliest_start_local?: string; latest_finish_local?: string;
  preferred_baseline_start?: string; notification_lead_minutes?: number;
}
interface Recommendation {
  appliance_id: string; start: IsoInstant; end: IsoInstant;
  modeled_cost_chf?: number; baseline_cost_chf?: number;
  potential_savings_chf?: number; confidence: 'measured' | 'modeled' | 'partial';
  caveats: string[]; alternatives?: Array<{ start: IsoInstant; end: IsoInstant; modeled_cost_chf?: number }>;
}
interface Household { id: string; municipality_id?: string; postcode?: string; provider_id?: string; tariff_product_id?: string; enrollment: TariffEligibility; }
interface NotificationPreferences { daily_digest: boolean; digest_time_local?: string; reminders: boolean; lead_minutes: number; quiet_start?: string; quiet_end?: string; peerdesk_enabled?: boolean; }
```

Do not use `Math.random()` for prices or cost claims. Mock fixtures must be deterministic and fully labeled DEMO. Real backend schemas are the integration source of truth.

---

## 5. Typed frontend API boundary

Create `src/lib/api.ts` exposing interface `EnergyApi` and implementation `FastApiEnergyClient` using `VITE_API_BASE_URL`. Add `src/lib/mockApi.ts` implementing the exact same `EnergyApi` with fixtures and local in-memory state. Select implementation via `VITE_USE_MOCK_API=true` default in Lovable preview.

Proposed backend routes:

| Method | Endpoint | Frontend usage |
|---|---|---|
| GET | `/api/v1/providers` | provider dropdown |
| GET | `/api/v1/providers/{id}/products` | available tariffs, eligibility |
| GET | `/api/v1/locations/search?query=` | city/postcode search |
| GET | `/api/v1/tariffs/intervals?product_id=&date=` | today/tomorrow chart |
| GET | `/api/v1/tariffs/summary?product_id=&date=` | daily summary |
| GET/PUT | `/api/v1/me/household` | home and selected tariff |
| GET/POST | `/api/v1/me/appliances` | appliance cards |
| PATCH/DELETE | `/api/v1/me/appliances/{id}` | edit/delete |
| POST | `/api/v1/recommendations/preview` | preview run scheduling |
| GET | `/api/v1/me/recommendations?date=` | saved recommendations |
| POST | `/api/v1/me/recommendations/{id}/remind` | opt-in reminder |
| GET/PUT | `/api/v1/me/notifications/preferences` | digest, quiet hours |
| POST | `/api/v1/comparisons/local` | eligible plan comparison |
| GET | `/api/v1/comparisons/switzerland?year=&profile=` | national benchmarks |
| GET | `/api/v1/me/subscription` | entitlement label |

Have `src/hooks/useEnergyData.ts` or equivalent TanStack Query hooks and centralized error mapping. Auth will ultimately be provided by FastAPI; for preview use a clearly labeled demo user. Do not create separate identity or payment stores.

All API requests must have meaningful loading/error/empty UI. GET requests may cache, but respect provider publication times and backend freshness. Do not expose utility credentials in the browser. Avoid unnecessary network calls; retrieve tariff from backend rather than individual utilities in the frontend.

---

## 6. Mock recommendation algorithm for interactive preview

Frontend demo calculations are **illustrative** and will later be replaced by authoritative backend results. Nonetheless, they must be deterministic and correct enough for interactions:

1. Each tariff slot has `[start,end)` time bounds and price in CHF/kWh for verified known variable components.
2. For each candidate start in the allowed window (e.g. 15-minute increments), calculate fixed-duration non-interruptible appliance operation.
3. For a flat power profile, allocate energy proportionally to actual elapsed minutes and sum `kWh_in_slot × slot_price` across all overlapping intervals. Do not optimize just on the first price slot.
4. Drop candidates with incomplete price coverage, outside user allowed hours or finishing after deadline.
5. Return cheapest start and up to 3 alternate windows; earliest start breaks cost ties.
6. Baseline savings only if user has set a baseline time and full comparable coverage exists; otherwise show cheapest modeled cost but no savings number.
7. Mark mock results **DEMO — modeled**. Native hourly prices remain hourly; chart may use step lines.
8. Datetime arithmetic should use timezone-aware dates; do not assume all Swiss days have 24 hours.

Please keep domain math in isolated `src/lib/demoOptimizer.ts` with tests/examples, not embedded inside React JSX. In production, the FastAPI optimizer is authoritative.

---

## 7. Localization, accessibility, and trust

- `de-CH` default; `en` and `fr` supported via centralized translation dictionaries. No untranslated labels in initial screen.
- Swiss CHF currency formatting, decimal conventions, `Rp./kWh`, 24-hour clock, timezone `Europe/Zurich`.
- Explain “Potential savings”, “Unknown charge”, “Demo prices”, “Network-only dynamic tariff”, and “Prices not yet published” in plain language.
- WCAG AA color contrast; full keyboard navigation, visible focus, proper ARIA labels, reduced-motion preference, accessible data table fallback for graph.
- Surface terms/privacy links as placeholders for later review; do not invent legal approval, certifications or guaranteed savings.
- No real brand endorsement inferred from listing a Swiss utility.
- Static demo fixtures should use fictional sample tariffs and explicit “Sample illustration — not current prices” wording. Avoid presenting real utility names and sample prices together without a conspicuous demo badge.

---

## 8. Suggested code organization

```text
src/
  components/
    layout/AppHeader.tsx
    layout/MobileBottomNav.tsx
    onboarding/OnboardingWizard.tsx
    overview/BestTimeHero.tsx
    prices/PriceTimelineChart.tsx
    prices/TariffBreakdown.tsx
    appliances/ApplianceCard.tsx
    appliances/ApplianceEditor.tsx
    comparisons/LocalTariffs.tsx
    comparisons/SwissExplorer.tsx
    alerts/NotificationSettings.tsx
    shared/DataStatus.tsx
    shared/SourceAttribution.tsx
  hooks/useEnergyData.ts
  lib/api.ts
  lib/mockApi.ts
  lib/demoOptimizer.ts
  lib/formatters.ts
  lib/time.ts
  i18n/de-CH.ts
  i18n/en.ts
  i18n/fr.ts
  types/energy.ts
  pages/Dashboard.tsx
  App.tsx
.env.example
README.md
```

Component names may vary, but preserve separation of UI, models, mock fixtures, API client and calculations. Use shadcn/ui components and Lucide icons. Do not introduce state-management complexity without need.

---

## 9. Visual acceptance checklist

- [ ] Dashboard renders beautifully at 360px, 390px, 768px and desktop widths.
- [ ] At a glance user sees supplier/tariff, next recommended start and status of tomorrow’s prices.
- [ ] Today/Tomorrow changes graph and cost recommendations.
- [ ] Editing a washer’s cycle duration or deadline updates its demo recommendation and cost.
- [ ] Each appliance may have a reminder toggle; demo mode clearly says no real push was sent.
- [ ] Price graph never suggests fabricated 15-minute granularity from hourly data.
- [ ] Both comparison tabs exist and display their legal/eligibility caveats.
- [ ] User can choose German, English or French without a reload.
- [ ] Missing data, invalid input, API failure, partial prices, and unknown tariff have coherent states.
- [ ] DEMO badge appears anywhere a sample price, savings number or schedule is displayed.
- [ ] Tooltips, charts, table fallback, keyboard behavior and focus meet accessibility requirements.
- [ ] All data comes from one typed API boundary, not hardcoded into individual components.
- [ ] Production build succeeds with `npm run build` and no TypeScript errors.
- [ ] README explains preview, backend connection, limitations and how to export to Cursor.

---

## 10. Explicit instructions for Lovable handoff

Generate the app in **mock mode first**; do not make successful visual delivery dependent on external electricity APIs. Use representative synthetic Swiss hourly and 15-minute curves and a minimal mock municipality/product catalog. Implement interactive form validation, comparison filters and recommendation calculations using the mock service. Do not imply a local utility or nationwide market allows switching when not verified.

After generating, provide:

1. Complete runnable frontend source.
2. `.env.example` containing `VITE_USE_MOCK_API=true` and `VITE_API_BASE_URL=http://localhost:8000`.
3. `README.md`: run instructions, component overview, endpoint integration mapping, which interactions are demo-only, and Capacitor packaging note.
4. List of mock fixtures and assumptions, with live-vs-demo labeling policy.
5. Confirmation that no Supabase backend/auth or appliance hardware integration was created.

### Final copy-paste follow-up instruction for Lovable

> Refine the current implementation against the attached `Swiss Energy Assistant — Lovable.dev Frontend Specification`. Keep it a single-page mobile-first React application, front-end only. Ensure every interactive control works using typed deterministic mock data, pricing and savings are clearly marked DEMO, provider tariff enrollment prerequisites are visible, local plan choices are distinct from informational Swiss-wide comparisons, and the API layer can be swapped to an existing FastAPI service. Run a production build and fix all TypeScript issues before completion.

---

**Recommended build order:** layout → mocked provider selection/onboarding → price chart → appliance optimizer UI → reminders UI → local/national comparisons → localization/states → API adapter → responsive polish.

**Source:** Adapted as a standalone Lovable frontend specification from the Swiss Energy Assistant master implementation document, 28 October 2026. Backend source of truth remains the corresponding Cursor/FastAPI master specification.
