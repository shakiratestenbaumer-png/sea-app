# 002 — Swiss Energy Assistant & Home Assistant: Competitive and Complementary Analysis

**Version:** 1.0  
**Created:** 30 October 2026  
**Author:** Product & Architecture Analysis  
**Sources:** `specs/chatgpt_homeassistant.md`, `docs/001_understanding_and_wbs.md` (§9), live deployment at [https://sea.supercharged.ch/](https://sea.supercharged.ch/)  
**Product:** Swiss Energy Assistant (SEA) — Swiss electricity tariff intelligence SaaS  
**Related systems:** [Home Assistant](https://www.home-assistant.io/) (open-source home automation)

---

## TABLE OF CONTENTS

1. [Executive Summary](#1-executive-summary)
2. [Home Assistant Capabilities Assessment](#2-home-assistant-capabilities-assessment)
3. [Competitive Analysis Matrix](#3-competitive-analysis-matrix)
4. [Strategy: Complement, Don't Compete](#4-strategy-complement-dont-compete)
5. [From Notifications to Real Energy Savings](#5-from-notifications-to-real-energy-savings)
6. [Technical Integration Architecture](#6-technical-integration-architecture)
7. [Business Model Impact](#7-business-model-impact)
8. [Risk Assessment](#8-risk-assessment)
9. [Recommended Action Items](#9-recommended-action-items)

---

## 1. Executive Summary

**Swiss Energy Assistant (SEA)** is a mobile-first, cloud-native application that ingests day-ahead tariff data from Swiss utilities (today: **CKW**, **Groupe E VARIO**, and **Primeo NetzDynamisch** via public SmartGridready APIs), computes cheapest operating windows for household loads, and delivers actionable guidance through dashboards and push notifications. It is deliberately scoped as an **advice and intelligence layer**, not an Energy Management System (EMS): it tells households *when* to run dishwashers, washers, dryers, and (later) EV chargers, without switching mains power on their behalf in the MVP.

**Home Assistant (HA)** is a mature, free, open-source home automation platform that runs on local hardware (Raspberry Pi, Home Assistant Green, NAS, etc.). It excels at device integration, automations, dashboards, energy monitoring, and optional cloud hooks. With community or custom integrations, HA can display electricity prices, trigger notifications, and control smart plugs, EV chargers, heat pumps, inverters, and batteries. For technically inclined households, HA can approximate much of SEA’s scheduling logic—but it does not ship with **native, maintained Swiss utility tariff pipelines** (full bill components, provider-specific publication times, eligibility rules, or CKW “network-only” labeling).

The strategic conclusion for SEA is **complement, don’t compete**. HA is not a substitute for a simple Swiss tariff product for the mass market; it is the **execution layer** many power users already operate. SEA should own the **Swiss tariff brain**: accurate provider data, bill-aware comparisons, mobile UX, regulatory-safe positioning, and optimization outputs that HA (or standalone users) can consume. Competing on generic automation, hardware drivers, or “free software” would dilute focus and increase safety/regulatory exposure without improving our core differentiator.

Over three phases—standalone app (now), HA integration (MQTT/REST schedules), and selective direct control via Matter/Thread and vendor APIs—SEA becomes the authoritative schedule and savings analytics service for Switzerland, whether the household uses only a phone or a full HA stack.

---

## 2. Home Assistant Capabilities Assessment

### 2.1 What Home Assistant Can Do Today (Energy-Relevant)

| Area | HA capability | Typical integration path |
|------|---------------|---------------------------|
| **Price display** | Sensors for spot/market or custom tariff feeds | Nord Pool, ENTSO-E, custom REST, HACS cards |
| **Cheapest-window logic** | Templates, `utility_meter`, automations, Node-RED, AppDaemon | User-configured or community blueprints |
| **Notifications** | Mobile app, Telegram, email, persistent notifications | Built-in notify services |
| **Smart plugs / relays** | Switch entities, power/energy sensors | Shelly, myStrom, Tapo, Zigbee, Matter |
| **Energy dashboard** | Grid import/export, device breakdown | Requires compatible metering |
| **Solar / battery** | Inverter integrations (Fronius, SMA, Huawei, etc.) | Vendor-specific; often local LAN |
| **EV charging** | go-e, Easee, Wallbox, OCPP (with add-ons) | REST/local APIs; evcc as adjacent OSS |
| **Heat pumps** | SG-Ready relays, vendor APIs, Modbus | Installer-dependent |
| **Scheduling** | Time-based and state-based automations | Full flexibility; user maintains rules |

HA’s **strengths** for energy management:

- **Local control and privacy** — automations run on-premises; no mandatory cloud for device actuation.
- **Device breadth** — hundreds of integrations; one hub for plugs, climate, EV, PV.
- **No software subscription** — core features are free; community extensions fill gaps.
- **Power user extensibility** — MQTT, REST, Python (AppDaemon), custom components.
- **Energy monitoring** — when hardware exposes `power`/`energy` entities, HA can correlate usage with tariffs (if the user wires the logic).

### 2.2 What Home Assistant Does Not Do Easily (SEA Opportunity)

| Gap | Why it matters in Switzerland |
|-----|-------------------------------|
| **Swiss utility-native tariffs** | Generic European spot price ≠ CKW dynamic **network** component, Groupe E 15-minute VARIO stack, or Primeo hourly dynamic with EMS enrollment rules |
| **Bill explainer & component labeling** | Network, energy, metering, levies, VAT, fixed fees from different sources; HA shows a sensor, not a regulated bill narrative |
| **Eligibility & EMS disclaimers** | EKZ/Primeo dynamic products require compatible EMS; HA does not encode Swiss enrollment policy |
| **Publication-time reliability** | CKW ~12:00, Groupe E/Primeo ~18:00 CET/CEST; retries, staleness, DST 23/25-hour days need product-grade handling |
| **Mobile-first household UX** | HA mobile app is capable but still “automation admin” oriented |
| **Measured savings vs advice** | HA can meter devices but does not productize “you saved CHF X vs baseline” without significant custom work |
| **Zero-setup onboarding** | HA expects server, updates, backups, integration debugging |

### 2.3 Important Limitation: Switching Power ≠ Starting Appliances

As noted in internal analysis and HA community practice, **cutting mains with a smart plug does not reliably start washing machines, dishwashers, or dryers** when power returns; many appliances require physical button confirmation or built-in delayed start. Remote switching also raises **safety and rating** issues (e.g. 10 A Type J plugs vs ~2.3 kW continuous loads). SEA’s MVP focus on **notifications and delayed-start guidance** aligns with this reality; HA users should use plugs primarily for **monitoring**, **simple loads**, and **EV/HP/charger** paths with proper interfaces—not forced laundry cycles.

---

## 3. Competitive Analysis Matrix

Detailed comparison for strategic positioning (SEA live at three providers; HA as generic self-hosted stack).

| Dimension | Home Assistant | Swiss Energy Assistant (SEA) | Winner / Notes |
|-----------|----------------|------------------------------|----------------|
| **Setup complexity** | Requires hardware, OS/container, updates, integration troubleshooting; optional €179 Green | Install app, select provider/tariff, cloud account; no home server | **SEA** for non-technical users; **HA** for DIY |
| **Swiss-specific tariff support** | Custom/community feeds; user must map components; no first-class CKW/Groupe E/Primeo maintenance | Native adapters: CKW (hourly grid), Groupe E (15-min), Primeo (hourly); component-aware UI | **SEA** (core moat) |
| **Tariff comparison & bill explainer** | Possible via custom templates; not productized | Local plan comparison + ElCom benchmarks + bill breakdown (roadmap) | **SEA** |
| **Appliance control** | Excellent for supported devices and automations | Advice-only MVP; later HA/Matter/vendor APIs | **HA** today; **SEA+HA** later |
| **UX for non-technical households** | Steep learning curve; dashboards require design | Mobile-first dashboard, appliance-centric recommendations | **SEA** |
| **Software cost** | Free (OSS); time cost high | Free tier (notifications); paid tiers (see §7) | **HA** on sticker price; **SEA** on time-to-value |
| **Hardware cost** | Pi/NAS/ Green + smart devices (e.g. myStrom ~CHF 36) | None required for MVP | **SEA** for advice-only |
| **Notification capabilities** | Flexible notify services; user configures | Push digests, appliance reminders, tariff publish alerts | **Tie** (SEA simpler defaults; HA more flexible) |
| **Solar / battery integration** | Strong vendor ecosystem; local LAN | Stage 6 roadmap: read-only APIs (Huawei, SMA, Fronius, etc.) then dispatch optimization | **HA** today; **SEA** for tariff-aware optimization narrative |
| **EV smart charging** | go-e, Easee, evcc, many others | Recommendations first; API scheduling Phase 2+ | **HA** now; **SEA** for Swiss tariff-optimized schedules fed to HA/evcc |
| **Privacy / data residency** | Local-first | Cloud backend; Swiss nDSG compliance required | **HA** for paranoid localists; **SEA** must be transparent |
| **Maintenance burden** | User owns upgrades, security, backups | Vendor-operated service | **SEA** |
| **Regulatory positioning** | User responsibility | Explicit “not an EMS”; eligibility gating | **SEA** (clarity for Swiss market) |

**Competitive verdict:** HA competes with SEA only for **homelab energy enthusiasts** who enjoy building automations. For **Swiss dynamic-tariff households** seeking savings without running a server, SEA competes with **spreadsheets, utility portals, and ignorance**—not with HA. For **HA owners**, SEA should be a **paid intelligence feed**, not a replacement hub.

---

## 4. Strategy: Complement, Don't Compete

### 4.1 Positioning Statement

> **SEA is the Swiss tariff brain; Home Assistant is optional muscle.**

SEA maximizes value by mastering provider data, optimization, savings measurement, and mobile UX—then **exporting schedules** to HA or vendor devices instead of replicating HA’s integration long tail.

### 4.2 Phased Roadmap

| Phase | Timeframe (indicative) | SEA capability | HA / devices role |
|-------|------------------------|----------------|-------------------|
| **Phase 1 — Standalone tariff intelligence** | Now (deployed) | Live CKW, Groupe E, Primeo data; cheapest windows; notifications; no control | None required |
| **Phase 2 — HA integration** | Months 8+ (aligns with WBS Stage 7) | Publish optimal schedules, price sensors, appliance windows via MQTT/REST; optional HA custom integration or add-on | HA executes automations (plugs, scripts, evcc triggers) |
| **Phase 3 — Direct device paths** | Later | Matter/Thread bridge or certified vendor APIs for EV, HP (SG-Ready), storage dispatch | HA optional; SEA can operate standalone for supported devices |

### 4.3 Dual-Mode Product

| Mode | Target user | SEA delivers | HA delivers |
|------|-------------|--------------|-------------|
| **Standard** | Phone-only household | Tariffs, advice, notifications, savings estimates | — |
| **Connected** | Existing HA user | Same + signed schedule entities, webhook/MQTT, API key | Device control, local fail-safe, user-defined interlocks |

### 4.4 What We Deliberately Do Not Build (Phase 1–2)

- A general-purpose automation engine rivaling HA
- Hundreds of device drivers (reuse HA, evcc, Solar Manager, myStrom local API)
- Mains-cut “forced start” for laundry appliances
- Marketing as EMS where provider rules forbid it

---

## 5. From Notifications to Real Energy Savings

Advice alone is hard to monetize if users cannot **verify** CHF impact. SEA should close the loop: **predict → act (manually or via HA) → measure → report**.

### 5.1 Smart Plug Monitoring (Swiss-Friendly)

| Device | Role | SEA use |
|--------|------|---------|
| **myStrom Energy Control Switch** | Type J, Wi-Fi, local REST, power measurement | Detect actual run times; compare energy cost vs optimal window; HA or direct poll (with user consent) |
| **Shelly** | Relays/plugs (often behind electrician install) | Energy monitoring for fixed circuits |
| **Matter plugs (e.g. Steffen T12/T13)** | Interop, scheduling experiments | Phase 3; verify metering support per model |

**Rule:** Use plugs for **measurement and simple loads**, not unsafe laundry remote-start (per `001` §9 safety rules).

### 5.2 Actual vs Optimal Timing Costs

1. **Baseline model** — “If you ran at default time (e.g. 20:00), cost would be X Rp/kWh × kWh.”
2. **Observed model** — Metered kWh during session × interval prices from SEA tariff engine.
3. **Optimal counterfactual** — Cheapest feasible window same day for that appliance duration.
4. **Reported savings** — `baseline − observed` and `observed − optimal` (honest about user compliance).

Store interval prices in UTC; display in `Europe/Zurich`; handle 15-minute (Groupe E) vs hourly (CKW, Primeo) granularity.

### 5.3 EV Charger Integration

| Platform | Integration style | SEA role |
|----------|-------------------|----------|
| **go-e** | Local/cloud API | Push charging schedule aligned to tariff windows |
| **Easee** | Cloud API | Same; respect site limits |
| **evcc** (OSS) | Often paired with HA | SEA as price/schedule provider via MQTT; evcc executes |

EV loads dominate savings potential (R09 in risk register: small dishwasher savings → pivot emphasis to EV/HP).

### 5.4 Heat Pump Scheduling

- **SG-Ready** interface (relay levels 1–4) — standard path for grid-friendly HP deferral; HA has patterns; SEA publishes “allow increase / block” windows from tariff + comfort constraints.
- **Manufacturer APIs** — only where documented and installer-approved; never bypass safety limits.

### 5.5 Solar Panel Integration Roadmap

Align with `001` §9 Stage 6 (read-only first):

| Manufacturer | API | Phase |
|--------------|-----|-------|
| Huawei SUN2000 / LUNA2000 | Modbus / cloud | Read production & battery SOC |
| SMA | Sunny Portal API | Read |
| Fronius | Solar API (local) | Read |
| Sungrow / SolarEdge | Cloud (agreements) | Read |

**Then:** Joint optimization — run loads when `{local PV surplus}` or `{cheap grid interval}` dominates; show **net export value** at feed-in tariff.

### 5.6 Battery Storage Dispatch

- Read-only: SOC, charge/discharge power, grid import/export.
- Optimization (later): SEA recommends charge from grid only in cheap windows (where tariff rules allow), discharge to cover peak-priced consumption—subject to **warranty, provider rules, and EMS boundaries**.
- HA remains viable **executor** for vendor-specific battery modes until SEA has certified paths.

---

## 6. Technical Integration Architecture

Goal: SEA backend publishes **authoritative tariff and schedule objects**; HA (or other consumers) subscribes without scraping Swiss utilities.

### 6.1 High-Level Diagram

```text
┌─────────────────────┐     day-ahead      ┌──────────────────────────┐
│ Swiss APIs          │ ─────────────────► │ SEA Backend (FastAPI)    │
│ CKW / Groupe E /    │                    │ Tariff engine, optimizer │
│ Primeo              │                    └───────────┬──────────────┘
└─────────────────────┘                                │
                                                       │ schedules, prices
                       ┌───────────────────────────────┼───────────────────────────────┐
                       ▼                               ▼                               ▼
              ┌────────────────┐              ┌─────────────────┐              ┌─────────────────┐
              │ Flutter / Web  │              │ MQTT broker     │              │ REST API        │
              │ App (SEA)      │              │ (user/HA/local) │              │ (HA integration)│
              └────────────────┘              └────────┬────────┘              └────────┬────────┘
                                                         │                                │
                                                         └──────────────┬─────────────────┘
                                                                        ▼
                                                              ┌─────────────────┐
                                                              │ Home Assistant  │
                                                              │ automations     │
                                                              └─────────────────┘
```

### 6.2 MQTT Topic Structure (Proposal)

Prefix: `sea/{user_id}/{site_id}/` (TLS, per-user credentials; never expose myStrom-style unauthenticated LAN patterns to the public internet).

| Topic | Payload (JSON) | Retain | Purpose |
|-------|----------------|--------|---------|
| `.../tariff/current` | Active tariff metadata, components, eligibility | yes | HA sensor for plan |
| `.../prices/day/{YYYY-MM-DD}` | Array of `{start, end, total_rp_kwh, components}` | yes | Price array for automations |
| `.../appliance/{appliance_id}/recommendation` | `{window_start, window_end, estimated_cost_chf, reason}` | yes | Cheapest run window |
| `.../appliance/{appliance_id}/schedule` | `{state: armed|cancelled, start, duration_min}` | no | Trigger HA automation |
| `.../health` | `{last_fetch, stale, provider}` | yes | Staleness watchdog |

HA automation example: when `schedule.state == armed` and `now >= start`, call script to enable EV charging or notify user.

### 6.3 REST API for HA Custom Integration

Versioned HTTPS API (e.g. `GET /v1/integrations/homeassistant/prices?date=`) returning:

- Normalized interval prices (ISO 8601 UTC + local offset)
- Next-day publish status and retry hints
- Appliance recommendations keyed by SEA appliance UUID
- HMAC or OAuth2 device flow for **Connected** tier

Custom integration (`config_flow`) stores API token, creates HA `sensor` entities for today/tomorrow prices and `binary_sensor` for “cheap window active.”

### 6.4 Home Assistant Add-On Possibility

Package a **thin add-on** (Docker on HA OS) that:

- Bridges SEA cloud → local MQTT (no cloud control of devices)
- Caches last-good prices if WAN down
- Does **not** duplicate tariff parsing (single source of truth in SEA cloud)

Add-on simplifies setup for HA users; backend remains shared for mobile users.

### 6.5 Matter Bridge (Phase 3)

Optional SEA or partner bridge exposing:

- **Energy Price Cluster** (where applicable) or vendor-specific schedules
- Commissioned loads (smart plug) with explicit user consent

Reduces HA dependency for households without a server; increases certification effort (NEV/ESTI, see §8).

### 6.6 Security Principles

- TLS everywhere; rotate API keys; scoped site IDs
- No publishing to open MQTT brokers without auth
- Read-only device credentials by default in Phase 2
- Audit log for any control command in Phase 3

---

## 7. Business Model Impact

HA integration changes **who pays** and **what they pay for**, without racing HA to “free.”

| Tier | Price (hypothesis) | Features | HA relationship |
|------|-------------------|----------|-----------------|
| **Free** | CHF 0 | Notification-only digests, basic tomorrow prices, limited appliances | None |
| **Smart** | CHF 10/year | Full scheduling, all supported providers, bill explainer, comparison views | Export CSV/ICS; no live link |
| **Connected** | CHF 30/year | MQTT + REST integration, HA blueprint pack, staleness SLA, savings reports with metered devices | Official custom integration / add-on |
| **B2B API** | Custom | Installer/consultant access, white-label schedules, multi-site | Solar installers, energy advisors, smart-home integrators |

**Rationale:**

- **CHF 10/year** remains the mass-market impulse buy vs hours of HA configuration (aligns with D05 in `001`).
- **CHF 30/year** captures HA enthusiasts and prosumers who already spend on hardware; they pay for **maintained Swiss data**, not for OSS duplication.
- **B2B** avoids competing with HA; partners sell **installation + SEA Connected** bundles.

**Cannibalization risk:** Low—HA users are a subset; free HA + free SEA notifications might coexist, but **Connected** tier monetizes convenience and accuracy.

---

## 8. Risk Assessment

| ID | Risk | Severity | Mitigation |
|----|------|----------|------------|
| R-HA-01 | **HA or community ships native Swiss CKW/Groupe E/Primeo integrations** | Medium | Move fast on data quality, bill labeling, support, and official provider relationships; API license clarity (R04) |
| R-HA-02 | **Users expect SEA to control laundry via plugs** | High | Product copy, onboarding, and HA blueprints enforce delayed-start; no forced-start |
| R-HA-03 | **Safety incident from remote switching** | Critical | Phase 2 read-only; Phase 3 interlocks, user confirmation, rated hardware only, installer docs |
| R-HA-04 | **Regulatory: SEA classified as EMS** | Critical | Maintain advice-first positioning; eligibility flags; legal review for Connected tier |
| R-HA-05 | **NEV / ESTI compliance for switching hardware** | High | No SEA-branded mains hardware in early phases; partner with certified devices; professional install for Shelly-in-cabinet |
| R-HA-06 | **Provider API redistribution restrictions** | Critical | Written permission; B2B terms; HA integration uses SEA as licensed proxy, not republishing raw feeds |
| R-HA-07 | **Small measured savings on laundry** | High | Emphasize EV/HP/solar in marketing; show honest kWh and Rp. savings; pivot messaging with data (R09) |
| R-HA-08 | **HA version fragmentation breaks integration** | Medium | Custom integration in HACS; semver API; integration tests against HA LTS |
| R-HA-09 | **Cloud outage disables HA automations** | Medium | Retained MQTT messages; local cache in add-on; HA automations fail-safe to manual |
| R-HA-10 | **Privacy backlash (cloud tariff profile)** | Medium | nDSG compliance, data minimization, on-prem MQTT bridge option |

---

## 9. Recommended Action Items

Prioritized for a live product with three provider adapters and deployment at [sea.supercharged.ch](https://sea.supercharged.ch/).

| Priority | Action | Owner | Outcome |
|----------|--------|-------|---------|
| **P0** | Document and ship in-app copy: “Advice only — not an EMS”; per-provider eligibility (Primeo/EKZ EMS required) | Product + Legal | Regulatory safe harbor |
| **P0** | Validate Phase 1 savings narrative with pilot users (manual compliance + estimated CHF) | Product | Evidence for CHF 10/year conversion |
| **P1** | Internal PoC: HA on Pi 5 + myStrom lamp load + SEA schedule via MQTT | Engineering | Prove Phase 2 architecture |
| **P1** | Specify MQTT topic schema + REST `/integrations/homeassistant` OpenAPI | Architecture | Contract for custom integration |
| **P1** | Draft HA custom integration (sensors for tomorrow prices + recommendation entity) | Engineering | HACS-ready beta for Connected tier |
| **P2** | Publish HA blueprint: “Notify cheap window” (no mains cut) | Community | Complement story, low support burden |
| **P2** | Partner outreach: myStrom / evcc / Swiss installers for “Connected bundle” | Business | Channel for CHF 30/year |
| **P2** | Savings v2: ingest smart-plug energy (myStrom REST) with user opt-in | Engineering | Measured vs optimal dashboard |
| **P3** | Solar read-only integration (Fronius or SMA first) | Engineering | Prosumer segment |
| **P3** | EV schedule export to go-e/Easee via HA or direct API | Engineering | High-impact savings |
| **P3** | Legal review: Connected tier, B2B API redistribution, control features | Legal | Unlock Phase 3 investment |

### 9.1 Success Metrics (12 Months)

| Metric | Target |
|--------|--------|
| Paying Smart tier subscribers | Validate CHF 10/year WTP |
| Connected tier attach rate among HA users | ≥ 30% of identified HA cohort |
| Median setup time (Connected) | < 30 minutes with add-on |
| Staleness incidents post-publish window | < 1% of user-days |
| Documented kWh shift (EV or simple load pilots) | Demonstrate > 5% cost reduction vs baseline |

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-10-30 | Initial comprehensive HA complement/compete analysis |

---

## References

- Internal: `docs/001_understanding_and_wbs.md` §9 (Solar, Home Automation & IoT)
- Internal: `specs/chatgpt_homeassistant.md` (smart plugs, HA comparison, integration recommendation)
- Live product: [https://sea.supercharged.ch/](https://sea.supercharged.ch/)
- Home Assistant Energy: [https://www.home-assistant.io/docs/energy/](https://www.home-assistant.io/docs/energy/)
- myStrom developer API: [https://mystrom.ch/mystrom-for-developers/](https://mystrom.ch/mystrom-for-developers/)
