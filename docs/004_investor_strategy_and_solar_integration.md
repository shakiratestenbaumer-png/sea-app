# 004 — Investor Strategy, Partnership Roadmap & Solar Integration

**Version:** 1.0  
**Created:** 30 October 2026  
**Author:** Project AI Architect  
**Product:** Swiss Energy Assistant (SEA) — Swiss electricity tariff intelligence SaaS  
**Deployment:** Web — [https://sea.supercharged.ch/](https://sea.supercharged.ch/) · Flutter mobile (Android APK built; iOS build-ready)  
**Sources:** `docs/001_understanding_and_wbs.md` (§1, §9), `docs/002_home_assistant_analysis.md`, `docs/003_provider_landscape_and_energy_savings.md`, `specs/chatgpt_homeassistant.md`, Fronius Solar API public documentation, Swiss PV remuneration references (BFE/ElCom)

---

## TABLE OF CONTENTS

1. [Document Purpose & Executive Summary](#1-document-purpose--executive-summary)
2. [Solar Panel Integration Roadmap](#2-solar-panel-integration-roadmap)
   - 2.1 [Fronius Solar API (Priority — Field Test Next Week)](#21-fronius-solar-api-priority--field-test-next-week)
   - 2.2 [Other Major Inverter APIs](#22-other-major-inverter-apis)
   - 2.3 [Swiss-Specific Solar Context](#23-swiss-specific-solar-context)
3. [Making the App Attractive to Partners & Investors](#3-making-the-app-attractive-to-partners--investors)
   - 3.1 [Value Proposition](#31-value-proposition)
   - 3.2 [Revenue Model](#32-revenue-model)
   - 3.3 [Competitive Landscape in Switzerland](#33-competitive-landscape-in-switzerland)
   - 3.4 [Traction Metrics to Show Investors](#34-traction-metrics-to-show-investors)
   - 3.5 [Partnership Opportunities](#35-partnership-opportunities)
   - 3.6 [Investor Pitch Points](#36-investor-pitch-points)
4. [Technical Next Steps (Priority Order)](#4-technical-next-steps-priority-order)
5. [Risk Analysis for Investors](#5-risk-analysis-for-investors)
6. [Appendices](#6-appendices)

---

## 1. Document Purpose & Executive Summary

Document **004** connects three threads that define SEA’s next 12–18 months:

1. **Product expansion** — from tariff-only advice to **PV-aware scheduling** (read-only first, optimization second), starting with a **Fronius** field test.
2. **Go-to-market** — how Swiss specificity, live provider integrations, and a hardware-agnostic platform support **freemium SaaS**, **B2B**, and **B2B2C** paths.
3. **Execution order** — a ranked engineering backlog that balances **near-term proof** (Fronius, myStrom, FCM) with **store distribution** and **accounts**.

**Strategic anchor (unchanged from document 001):**

> Software first, advice before automation, no proprietary electrical hardware in MVP.

Solar integration in 2026–2027 remains **read-only and recommendation-first**. SEA is **not** marketed as a certified Energy Management System (EMS); provider enrollment rules for dynamic tariffs (EKZ, Primeo) still require compatible EMS where stated. SEA combines **import tariff intelligence** with **local PV surplus signals** to answer: *“Run this load now on self-generated power, or wait for the cheapest grid window?”*

**Immediate milestone:** Validate Fronius **local Solar API** polling on a friend’s installation (next week), then mirror the existing `ProviderAdapter` pattern with a `SolarSourceAdapter` in the FastAPI backend.

---

## 2. Solar Panel Integration Roadmap

### 2.1 Fronius Solar API (Priority — Field Test Next Week)

Fronius is a strong **first OEM** for Switzerland: widespread Symo/Primo inverters, mature **local HTTP API** on the data logger (Datamanager / inverter with built-in web server), excellent Home Assistant community coverage, and no mandatory cloud account for LAN access.

#### 2.1.1 API Generations: v1 (Local REST) vs v2 / Cloud

| Layer | Base URL / access | Typical use in SEA |
|-------|-------------------|-------------------|
| **Solar API v1** | `http://{host}/solar_api/v1/` on LAN | **Primary** — realtime production, power flow, archive |
| **Solar API “v2” naming** | Often used informally for **extended** endpoints (e.g. `.fcgi` power flow, storage blocks) | Same host; not a separate product — treat as v1 family |
| **Fronius Solar.web (cloud)** | `https://solarweb.com` + **API key** / OAuth-style portal credentials | Remote sites, no VPN; higher latency; ToS review |
| **Modbus TCP** | Port **502** on compatible devices | Alternative if HTTP disabled; requires register map |

**Recommendation for next week’s test:** Use **local v1 HTTP** only. Cloud can follow for users without LAN bridge.

#### 2.1.2 Key Endpoints (Local v1)

All are **GET**, typically **no authentication** on the local network (security = network isolation — never expose port 80/502 to the public internet).

| Endpoint | Purpose | Key fields (typical JSON path) |
|----------|---------|--------------------------------|
| `GetInverterInfo.cgi` | Device inventory | `Body.Data` — serial, device type, `UniqueID` |
| `GetInverterRealtimeData.cgi` | Inverter snapshot | `Scope=Device&DeviceId={n}&DataCollection=CommonInverterData` → `PAC` (W), `DAY_ENERGY` (Wh), `YEAR_ENERGY`, `TOTAL_ENERGY` |
| `GetPowerFlowRealtimeData.fcgi` | Site energy flow | `Body.Data.Site` — `P_Grid`, `P_Load`, `P_Akku`, `P_PV`; `Body.Data.Inverters` |
| `GetArchiveData.cgi` | Historical intervals | `Scope=System&StartDate=YYYY/MM/DD&EndDate=...` — production/consumption series |
| `GetMeterRealtimeData.cgi` | Smart meter (if present) | Grid import/export power and energy counters |
| `GetStorageRealtimeData.cgi` | Battery (if present) | SOC, charge/discharge power |

**Example requests (replace `{IP}`):**

```http
GET http://{IP}/solar_api/v1/GetInverterInfo.cgi
GET http://{IP}/solar_api/v1/GetInverterRealtimeData.cgi?Scope=Device&DeviceId=1&DataCollection=CommonInverterData
GET http://{IP}/solar_api/v1/GetPowerFlowRealtimeData.fcgi
GET http://{IP}/solar_api/v1/GetArchiveData.cgi?Scope=System&StartDate=2026/10/30&EndDate=2026/10/30&Channel=EnergyProductionTotal
```

**Note:** `DeviceId` is **1-based** and must match `GetInverterInfo.cgi`. Multi-inverter sites iterate IDs.

**`GetInverterRealtimeData.cgi` query parameters:**

| Parameter | Values | Role |
|-----------|--------|------|
| `Scope` | `Device` | Required for per-inverter data |
| `DeviceId` | `1`, `2`, … | From `GetInverterInfo.cgi` |
| `DataCollection` | `CommonInverterData`, `MinMaxInverterData`, `3PInverterData` | Start with **CommonInverterData** |

**`GetArchiveData.cgi` (historical alignment with tariff intervals):**

| Parameter | Example | Role |
|-----------|---------|------|
| `Scope` | `System` | Whole-site aggregates |
| `StartDate` / `EndDate` | `2026/10/30` | Inclusive day range |
| `Channel` | `EnergyProductionTotal`, `EnergyConsumptionTotal`, `EnergySelfConsumptionTotal` | Pick channels available in `GetArchiveDataQueryParameters.cgi` |

Call `GetArchiveDataQueryParameters.cgi` once during onboarding to list valid `Channel` names for that firmware — channels differ if a Fronius Smart Meter is installed.

**Response status:** Top-level `Head.Status.Code` — `0` = OK; non-zero → surface user-friendly “inverter unreachable” and retry with exponential backoff (cap 5 min).

#### 2.1.3 What the Electrician / Admin Must Enable

| Requirement | Needed for SEA v1? | Notes |
|-------------|-------------------|-------|
| **Inverter on LAN + known IP** | **Yes** | DHCP reservation recommended |
| **Datamanager / datalogger web server** | **Yes** | Solar API served by Fronius device firmware |
| **Modbus TCP** | **No** (for HTTP path) | Enable only if HTTP unavailable or for redundant reads |
| **Solar.web account** | **No** (local test) | Optional for cloud path |
| **Firewall** | Site policy | Allow phone/bridge → inverter; block WAN |

Ask the installer: *“Is the Fronius Solar API reachable on the home network?”* — Home Assistant users often already have this working via the Fronius integration.

#### 2.1.4 Data Available for Optimization

| Signal | Unit | SEA usage |
|--------|------|-----------|
| `PAC` / PV power | W | Instant surplus vs load |
| `P_Load`, `P_Grid` | W | Self-consumption vs import/export |
| `DAY_ENERGY` | Wh → kWh | Dashboard yield |
| Archive channels | Wh per interval | Calibration, “did we shift into sun?” |
| Battery SOC / `P_Akku` | %, W | Charge/discharge scheduling hints |

Map internally to a normalized **`SolarSnapshot`** (timestamp UTC, `pv_w`, `load_w`, `grid_w` positive=import, `export_w`, `battery_soc`, `daily_yield_kwh`).

#### 2.1.5 Integration Architecture: Poll vs Push

Fronius local API is **request/response**; there is no standard WebSocket push to third-party clouds.

| Mode | Interval | Pros | Cons |
|------|----------|------|------|
| **LAN poll (recommended)** | **10–15 s** for UI; **60 s** for cloud sync | Simple; matches HA defaults | Requires **on-prem bridge** or user VPN |
| **Cloud poll (Solar.web)** | 1–5 min | No LAN agent | Keys, rate limits, privacy |
| **Push to SEA** | N/A native | — | Would need **MQTT agent** on Pi/HA posting deltas |

**Phase 1 implementation:**

1. **Development:** Backend or CLI on same LAN as inverter (next week’s test).
2. **Production:** **Connected tier** — optional **SEA Edge Agent** (Docker on HA, or small Pi) polls Fronius and POSTs signed snapshots to `POST /v1/integrations/solar/ingest`.
3. **Never** embed raw inverter IP in the public Flutter app; credentials stay on LAN.

**Polling budget:** `GetPowerFlowRealtimeData.fcgi` alone is sufficient for optimization; add `GetInverterRealtimeData` for redundancy. At 15 s, ~5,760 requests/day — well within typical inverter limits; back off on HTTP errors.

#### 2.1.6 Code-Level Integration (FastAPI)

Align with `backend/app/integrations/providers/base.py` — add parallel **`SolarSourceAdapter`**:

```python
# backend/app/integrations/solar/fronius.py (proposed)
from dataclasses import dataclass
from datetime import datetime
from decimal import Decimal
import httpx

@dataclass(frozen=True)
class SolarSnapshot:
    captured_at: datetime
    pv_w: int
    load_w: int | None
    grid_import_w: int  # max(grid, 0)
    grid_export_w: int  # max(-grid, 0)
    battery_soc_pct: Decimal | None
    daily_yield_kwh: Decimal | None
    source_id: str  # e.g. fronius:{host}:{device_id}

class FroniusLocalClient:
    def __init__(self, base_url: str, timeout: float = 5.0):
        self.base_url = base_url.rstrip("/") + "/solar_api/v1"

    async def fetch_power_flow(self) -> SolarSnapshot:
        async with httpx.AsyncClient(timeout=self.timeout) as client:
            r = await client.get(f"{self.base_url}/GetPowerFlowRealtimeData.fcgi")
            r.raise_for_status()
            body = r.json()["Body"]["Data"]
            site = body["Site"]
            pv = int(site.get("P_PV") or 0)
            load = int(site.get("P_Load") or 0)
            grid = int(site.get("P_Grid") or 0)
            akku = site.get("P_Akku")
            soc = None  # from GetStorageRealtimeData if akku present
            return SolarSnapshot(
                captured_at=datetime.utcnow(),
                pv_w=pv,
                load_w=load,
                grid_import_w=max(grid, 0),
                grid_export_w=max(-grid, 0),
                battery_soc_pct=soc,
                daily_yield_kwh=None,
                source_id="fronius:local",
            )
```

**Health check:** `GET .../GetInverterInfo.cgi` — parse `Status.Code` (0 = OK).

**Error handling:** Timeouts → stale badge in UI; do not fall back to “free solar” assumptions.

#### 2.1.7 Self-Consumption Optimization Algorithm

Combine **solar snapshot** with **day-ahead tariff intervals** from CKW / Groupe E / Primeo (already normalized to `PriceInterval` with `Component.ENERGY` / `GRID_USAGE`).

**Definitions (per decision time `t`):**

- `surplus_w = max(0, pv_w - load_w)` — approximate **immediate** self-consumption headroom (ignoring battery for v1).
- `marginal_grid_rp = price_integrated(t)` — CHF/kWh or Rp/kWh from tariff engine.
- `export_value_rp` — user-configured **feed-in remuneration** (KEV/PRE/contract); default from ElCom/BFE quarterly reference, not zero.

**Decision rules for shiftable appliance** (energy `E_kwh`, duration `D` min, deadline `t_deadline`):

1. **Solar-dominant (run NOW):**  
   If `surplus_w >= P_appliance` (or expected average surplus over `D` exceeds `E_kwh` from forecast/heuristic) **and** `marginal_grid_rp > export_value_rp`  
   → Recommend **immediate** start — marginal cost ≈ **opportunity cost of export**, not grid price.

2. **Grid-dominant (defer):**  
   If `surplus_w < P_appliance` for foreseeable window  
   → Run existing **cheapest-interval optimizer** (document 001, WBS 5.0) over `[t, t_deadline]`.

3. **Hybrid:**  
   Score each candidate start time `s`:  
   `cost(s) = E_grid(s) * price(s) + E_pv(s) * export_value_rp`  
   with `E_pv + E_grid = E_kwh`, `E_pv` estimated from archive-shaped PV curve or same-day production pace.  
   Pick `s* = argmin cost(s)`.

**Battery extension (when `GetStorageRealtimeData` available):**

| Condition | Recommendation |
|-----------|----------------|
| PV surplus & SOC < SOC_max | Prefer **charge battery**; defer non-urgent loads |
| Grid price high & SOC > SOC_min | **Discharge** to cover load before importing |
| Grid price low & SOC low | **Grid charge** only if tariff + battery rules allow (user opt-in; warranty disclaimer) |

**UX copy:** Show **“Using your solar (~X W surplus)”** vs **“Cheapest grid window 02:15–04:15”** — never claim EMS certification.

**Pseudocode (appliance window):**

```text
function recommend(appliance, tariff_day, solar_now, pv_forecast_optional):
  if solar_now.surplus_w >= appliance.typical_power_w:
    if export_value < min_price(tariff_day):
      return NOW, reason="PV surplus beats export value"
  windows = optimizer.cheapest_windows(appliance, tariff_day)
  return best_hybrid(windows, pv_forecast_optional, export_value)
```

#### 2.1.8 Fronius Solar.web (Cloud API) — Later Phase

For users without LAN bridge:

- Register system in **Solar.web**, generate **API credentials** in portal (policy changes over time — verify current Fronius developer terms).
- Poll cloud endpoints for production history (minute/hour granularity varies).
- **Latency** and **ToS** make this secondary to local API.

Store cloud tokens encrypted server-side; scoped read-only.

**Modbus TCP (fallback path):** If HTTP is disabled, Fronius exposes holding/input registers per **Fronius Datamanager Modbus TCP Register Map** (SunSpec-aligned blocks). SEA should defer Modbus to **Phase 2** unless the field test site blocks HTTP — a small **pymodbus** reader can map register `W`/`Wh` to the same `SolarSnapshot`. Typical settings: unit ID **1**, port **502**, polling 5–10 s (slower than HTTP).

#### 2.1.9 Next-Week Test Checklist

| Step | Action |
|------|--------|
| 1 | Confirm inverter IP; ping `GetInverterInfo.cgi` from laptop on same Wi‑Fi |
| 2 | Log `GetPowerFlowRealtimeData.fcgi` for 30 min; note `P_PV`, `P_Load`, `P_Grid` sign convention |
| 3 | Run proposed `FroniusLocalClient` script; validate against HA Fronius entities if present |
| 4 | Overlay CKW/Groupe E/Primeo prices for “run now vs wait” demo screenshot |
| 5 | Document `DeviceId`, meter presence, battery presence for adapter fixtures |

---

### 2.2 Other Major Inverter APIs

SEA should **not** build five full integrations before Fronius is proven; this table guides **Phase 2 OEM priority** by Swiss install share and API quality.

#### 2.2.1 SMA — Sunny Portal / Data Manager

| Aspect | Detail |
|--------|--------|
| **Access** | **SMA Monitoring API** (OAuth2, site-based) via Sunny Portal; local **Speedwire/Webconnect** on LAN for some models |
| **Auth** | Client ID/secret + user consent; or local UDP multicast for live production |
| **Data** | Plant energy, inverter power, grid meter if configured, battery on Sunny Boy Storage |
| **SEA fit** | Cloud good for **mobile-only users**; local for low latency |
| **Effort** | Medium–high (OAuth, token refresh, plant ID mapping) |

#### 2.2.2 Huawei — FusionSolar (Very Popular in CH)

| Aspect | Detail |
|--------|--------|
| **Access** | **FusionSolar Northbound API** (enterprise) or **Modbus TCP** to SUN2000; residential often cloud-linked |
| **Auth** | Northbound: API account approved by Huawei; Modbus: installer enables port, register map by model/firmware |
| **Data** | String/inverter power, battery (LUNA), grid import/export, alarms |
| **SEA fit** | High priority **after Fronius** due to Swiss market share |
| **Effort** | High — firmware fragmentation; legal agreement for cloud API |

#### 2.2.3 SolarEdge — Monitoring API

| Aspect | Detail |
|--------|--------|
| **Access** | **Monitoring API** per site (`https://monitoringapi.solaredge.com/...`) |
| **Auth** | **API key** in query param; site ID |
| **Data** | Power, energy, overview, inventory, storage if present |
| **Rate limits** | Strict (e.g. 300 calls/day for some endpoints) — cache aggressively |
| **SEA fit** | Solid cloud-only path; no LAN required |

#### 2.2.4 Enphase — Enlighten API

| Aspect | Detail |
|--------|--------|
| **Access** | **Enphase Enlighten API** (OAuth2, v4) |
| **Auth** | Developer app + user authorization |
| **Data** | Microinverter production, consumption (with IQ Gateway), battery (IQ Battery) |
| **SEA fit** | Growing in residential; microinverter granularity is excellent for forecasting |
| **Effort** | Medium — OAuth + per-system IDs |

#### 2.2.5 Sungrow — iSolarCloud

| Aspect | Detail |
|--------|--------|
| **Access** | Cloud API under developer agreement |
| **Auth** | App key + secret |
| **Data** | Plant generation, devices, historical curves |
| **SEA fit** | Secondary; similar to Huawei cloud path |

#### 2.2.6 Integration Strategy Summary

| OEM | First path | Read-only MVP | Tariff-aware optimization |
|-----|------------|---------------|---------------------------|
| Fronius | Local HTTP | **Week 1 test** | Phase 4 (doc 003) |
| Huawei | Modbus or FusionSolar | Phase 2 | Phase 4 |
| SMA | Sunny Portal OAuth | Phase 2 | Phase 4 |
| SolarEdge | Monitoring API key | Phase 2 | Phase 4 |
| Enphase | Enlighten OAuth | Phase 3 | Phase 4 |

Reuse **Home Assistant** as optional executor: SEA publishes **`/integrations/homeassistant/`** schedule + **`solar/surplus_active`** boolean (document 002, §6).

---

### 2.3 Swiss-Specific Solar Context

#### 2.3.1 KEV / PRE Feed-In Tariffs

| Mechanism | Meaning for SEA |
|-----------|-----------------|
| **KEV** (Kostendeckende Einspeisevergütung) | Regulated **cost-covering feed-in** for smaller plants; remuneration follows federal/canton rules and **reference market prices** (quarterly updates). |
| **PRE** (Privilegierte Erzeugungsanlagen) | Older **privileged** plants with **fixed long-term** feed-in tariffs — export value is **contractual**, not spot-like. |
| **2027 reform trajectory** (see doc 001, §8) | Import tariffs and **export remuneration** decouple further; app must store **user feed-in rate** separately from **dynamic import** schedule. |

**Product rule:** Optimization uses **`export_value_rp`** from user settings (with ElCom/BFE defaults as hints). Never assume export = 0 or export = import price.

#### 2.3.2 Eigenverbrauchsgemeinschaft (EVG) / ZEV

| Model | Relevance |
|-------|-----------|
| **Self-consumption within single meter** | Simple: `P_PV` vs `P_Load` from Fronius |
| **ZEV (Zusammenschluss zum Eigenverbrauch)** | Multiple parties share PV; allocation keys and virtual billing — SEA shows **household share** only with user-entered allocation % |
| **vZEV / community models** | UI education + link to canton-specific rules; full billing out of scope for v1 |

#### 2.3.3 Net Metering vs Feed-In: Self-Consume vs Export

Swiss households often face:

- **Dynamic import price** (CKW network, Groupe E VARIO, Primeo) on **grid draw**.
- **Separate feed-in credit** on **export**.

**When to self-consume:** When `price_import(t) > export_remuneration` — using 1 kWh behind-the-meter avoids buying at `price_import` and foregoes only `export_remuneration`.  
**When export is acceptable:** Midday surplus when **appliance cannot run** and **battery full** — show **“Exporting at ~X Rp/kWh”** vs **peak evening import ~Y Rp/kWh** to motivate shifting loads.

**Regulatory boundary:** SEA advises **timing**; it does not settle ZEV invoices or replace supplier contracts.

#### 2.3.4 Swiss PV Market Context (Investor-Relevant)

| Indicator | Order of magnitude | Source / note |
|-----------|-------------------|---------------|
| Installed PV capacity | **>6 GW** nationwide (growth ongoing) | BFE energy statistics — use latest year in pitch deck |
| Residential share | Significant and rising | New builds + retrofit; Huawei/SMA/Fronius common |
| Dynamic import tariffs | **3 public APIs** today (doc 003) | Overlap PV owners in CKW / Groupe E / Primeo regions |
| Typical system size | **8–15 kWp** residential | Drives midday surplus vs evening peak load mismatch |

**Combined value story:** A prosumer on **Primeo NetzDynamisch** with **10 kWp** and **EV** sits in the highest **CHF 300–800/year** optimization band (document 003 §14.4) — exactly the segment **Connected** tier targets.

---

## 3. Making the App Attractive to Partners & Investors

### 3.1 Value Proposition

| Element | Detail |
|---------|--------|
| **Problem** | Swiss households on **dynamic or time-varying** tariffs overpay by running loads at peak intervals — modelled range **CHF 50–800/year** depending on shiftable kWh, EV presence, PV/battery, and adherence (documents 003 §14, 002 §5). |
| **Solution** | **Real-time tariff intelligence** + **appliance window recommendations** + (roadmap) **verified savings** via smart plugs and **PV-aware** scheduling. |
| **Unique advantages** | **Swiss-specific** (regulated DSO model, not Nord Pool generic); **SmartGridready**-aligned parsing; **trilingual** (DE/EN/FR); **first mover** with **3 live provider APIs**; clear path to **hardware integration** without becoming a hardware vendor. |

**One-line pitch:** *The Swiss tariff brain for your phone — optional muscle via Home Assistant, myStrom, Fronius, and EV APIs.*

### 3.2 Revenue Model

| Stream | Pricing (hypothesis) | Contents |
|--------|----------------------|----------|
| **Freemium — Free** | CHF 0 | Tomorrow’s prices (limited), basic notifications |
| **Smart** | **CHF 10/year** | Full scheduling, all supported providers, bill explainer, comparisons |
| **Connected** | **CHF 30/year** | Solar read (Fronius+), HA MQTT/REST, myStrom verification, staleness SLA |
| **B2B API** | Custom annual | Consultants, installers, property managers — multi-site, white-label JSON |
| **B2B2C white-label** | Revenue share | Utility-branded app shell on SEA backend |
| **Data monetization (long-term)** | Aggregated only | Anonymized load-shift potential by canton/DSO for **grid operators** — strict nDSG/FADP review |

**Unit economics hypothesis:** Low marginal cost per user (shared tariff fetchers); **Connected** tier subsidizes free tier if conversion ≥ 3–5%.

### 3.3 Competitive Landscape in Switzerland

| Competitor | Role | Gap SEA fills |
|------------|------|---------------|
| **No established Swiss dynamic-tariff consumer app** | — | **Open category** for mobile-first optimization |
| **Home Assistant** | Free automation hub | No maintained CKW/Groupe E/Primeo stack; high setup burden (doc 002) |
| **Tibber** | Dynamic tariff app (DE/Nordics) | **Not in Switzerland**; no Swiss DSO components |
| **Utility portals** | Static PDFs / basic charts | No cross-appliance optimization or push digests |
| **Solar Manager** | Swiss EMS | Hardware/installer-centric; different buyer; potential **partner** not pure rival |
| **evcc** | EV charging OSS | Complement for EV execution; SEA feeds schedules |

**Positioning:** Compete with **ignorance and spreadsheets**, complement **HA** and **installers**.

### 3.4 Traction Metrics to Show Investors

| Metric | Status (October 2026) |
|--------|------------------------|
| Live provider APIs | **3** — CKW, Groupe E, Primeo |
| Web production | **https://sea.supercharged.ch/** |
| Mobile | **Android APK** built and functional |
| iOS | **Flutter cross-platform** — store submission pending |
| Provider research | **30** DSOs scanned; expansion pipeline documented (doc 003) |
| Solar prototype | **Fronius** local API — **field test scheduled** (next week) |
| SmartGridready | Normalized adapter pipeline (`swiss_tariff.py`) |
| Savings proof | Phase 1 adherence + Phase 2 myStrom on roadmap (doc 003) |

**Suggested KPIs for next funding conversation:**

- MAU / WAU, notification opt-in rate  
- **Adherence rate** (target 25%+ pilot, doc 003 §10.5)  
- **Self-reported or metered CHF saved** per active Smart/Connected user  
- Provider coverage (% Swiss population with public dynamic API)  
- Connected tier attach rate among HA/Fronius owners  

### 3.5 Partnership Opportunities

| Partner type | Examples | Value exchange |
|--------------|----------|----------------|
| **Energy providers** | CKW, Groupe E, Primeo | Referral, co-marketing, **API license clarity**, white-label |
| **Smart plug OEM** | **myStrom** (Baar, CH) | Bundled **Connected** tier, verified savings case study |
| **Solar installers** | 100+ CH installers | Lead gen: “free 1-year Smart with install”; B2B dashboard |
| **Property managers** | Multi-family | ESG reporting, tenant engagement, bulk Connected |
| **EV charging** | go-e, Easee | Tariff-optimized charging schedules via API v2 |
| **Research / policy** | BFE, ETHZ | Pilots, anonymized datasets, credibility |

**myStrom note:** ~CHF 36/plug, local REST, Swiss Type J — ideal **Phase 2** measurement partner (doc 003 §11, `specs/chatgpt_homeassistant.md`).

### 3.6 Investor Pitch Points

| Theme | Data point |
|-------|------------|
| **Market size** | ~**3.8M households** in Switzerland; dynamic products growing with smart meters + 2027 transparency |
| **Timing** | EU-style **dynamic tariff** momentum; Swiss **voluntary** adoption + regulatory clarity on publication |
| **Platform play** | **Hardware-agnostic** — tariffs + algorithms core; devices via partners |
| **Moat** | **Provider API integrations**, component-aware bill logic, Swiss regulatory positioning, optimization + savings ledger |
| **Revenue** | Recurring **SaaS** with natural upsell **Smart → Connected** as users add PV/HA/EV |
| **Exit paths** | Strategic by utility, EMS vendor (Solar Manager), or European energy-tech roll-up |

---

## 4. Technical Next Steps (Priority Order)

| Priority | Initiative | Rationale | Success criterion |
|----------|------------|-----------|-------------------|
| **1** | **Fronius solar API integration** | Field test next week; unlocks prosumer segment | 24 h stable `SolarSnapshot` ingest; demo “run on sun” |
| **2** | **myStrom smart plug integration** | Verify **actual** savings (doc 003 Phase 2) | Metered Wh matched to tariff intervals |
| **3** | **EV charger API (go-e v2)** | Largest shiftable load | Read state + publish recommended charge window |
| **4** | **Push notifications (FCM)** | Retention + adherence | Daily digest + appliance reminders shipped |
| **5** | **Google Play publication** | Distribution | Production track live |
| **6** | **Apple App Store publication** | iOS market share CH | TestFlight → App Store |
| **7** | **User accounts + backend persistence** | Cross-device, subscriptions | Auth + household profile sync |
| **8** | **More provider APIs** | TAM expansion | EKZ production feed, outreach wins from 30-DSO list |

**Dependencies:** Items 1–2 can proceed in parallel after Fronius test; FCM (4) before store releases (5–6) is ideal for store review demos; accounts (7) before Connected tier billing.

#### 4.1 Priority 2 — myStrom (Local REST)

Documented at [myStrom for Developers](https://mystrom.ch/mystrom-for-developers/):

```http
GET http://{plug_ip}/report
```

Returns JSON with `power` (W), `relay` (bool), `temperature`, etc. **No auth on LAN** — same security model as Fronius: never route raw LAN IPs through SEA cloud without an **edge relay**.

**Integration:** Map plug power to `ApplianceRunSession`; when `power > P_on` for 2+ minutes, open session and integrate Wh against `PriceInterval` series (document 003 §11.3).

#### 4.2 Priority 3 — go-e Charger API v2

Local HTTP on charger hostname (mDNS `go-e-xxxx.local`):

```http
GET http://{host}/api/v2/status
POST http://{host}/api/v2/go-e/setCurrent  (only with explicit Connected + user consent)
```

**Read-only MVP:** Parse `nrg` array (power, session energy), `car` connection state, `allowCharging` — feed EV optimizer with **departure time** constraint from user profile. **Write path** (current limit / pause) stays behind feature flag until safety review (document 002 §5.4).

#### 4.3 Priority 4 — FCM Push Notifications

Flutter: `firebase_messaging` + backend topics per household (`tariff_published`, `appliance_reminder`). Payload includes deep link to scheduler screen with pre-filled **recommended window**. Aligns with WBS 7.0 (document 001).

#### 4.4 Priority 7 — User Accounts

Extend existing `household` schema (`has_solar`, provider, postcode) with encrypted token vault for **Connected** integrations (Fronius host/IP stays on edge agent; cloud stores only **agent public key** + last snapshot).

---

## 5. Risk Analysis for Investors

| Risk | Severity | Description | Mitigation |
|------|----------|-------------|------------|
| **Provider API stability** | High | URLs change, keys required, feeds stale (EKZ placeholder) | Health checks, stale UI, multi-provider; **written redistribution terms**; SEA as licensed proxy (doc 002 R-HA-06) |
| **Regulatory / data privacy** | High | nDSG/FADP, **ESTI/NEV** if control expands | Advice-first; no EMS claims; privacy-by-design; Swiss hosting option; minimal data |
| **EMS misclassification** | Critical | Primeo/EKZ require certified EMS for enrollment | Eligibility flags; legal review; “not an EMS” in all copy (doc 001 §2) |
| **Competition — HA** | Medium | Free stack for DIY users | **Complement** strategy; Connected tier; Swiss data moat (doc 002) |
| **Competition — Tibber / utilities** | Medium | Entrant with brand + API | Speed to **multi-provider** + **solar/EV**; local partnerships |
| **Solar API / LAN access** | Medium | Users cannot expose inverter to cloud | **Edge agent**; HA bridge; optional Solar.web |
| **Overstated savings** | High | Marketing backlash | “Potential” vs “verified”; Phase 2 metering (doc 003) |
| **Safety (smart plugs)** | Critical | Remote switching laundry | **No forced-start**; monitoring-first (doc 001 §9, chatgpt_homeassistant spec) |
| **OEM API dependency** | Medium | Huawei/Fronius terms change | Read-only scope; adapter isolation; HA fallback |

**Investor narrative:** Risks are **real but bounded** by a phased roadmap that already shipped **production tariff intelligence** before touching control or hardware certification.

---

## 6. Appendices

### Appendix A — Fronius Response Shape (Power Flow, Illustrative)

```json
{
  "Body": {
    "Data": {
      "Site": {
        "Mode": "meter",
        "P_Grid": -1200,
        "P_Load": 2100,
        "P_PV": 3300,
        "P_Akku": null,
        "E_Day": 12500
      }
    }
  }
}
```

Sign conventions may vary by site wiring — **calibrate once** against meter display during field test.

### Appendix B — Normalized SEA Solar Object (API Proposal)

`GET /v1/sites/{id}/solar/current` (auth required):

```json
{
  "captured_at": "2026-10-30T11:15:00Z",
  "pv_w": 3300,
  "load_w": 2100,
  "grid_import_w": 0,
  "grid_export_w": 1200,
  "battery_soc_pct": null,
  "daily_yield_kwh": 12.5,
  "source": "fronius_local",
  "stale": false
}
```

### Appendix C — Cross-References

| Document | Relevance |
|----------|-----------|
| **001 §1** | Product scope, EMS boundary |
| **001 §9** | Solar & IoT stages 6–7 |
| **002** | HA complement, MQTT, business tiers |
| **003 §13–14** | Solar Phase 4, savings model CHF 50–800 |
| **chatgpt_homeassistant.md** | myStrom, plug safety |
| **Backend** | `backend/app/integrations/providers/` — pattern for new adapters |

### Appendix D — Glossary (Solar + Swiss)

| Term | Definition |
|------|------------|
| **Eigenverbrauch** | Self-consumption of PV on-site |
| **Einspeisung** | Grid export / feed-in |
| **EVG** | Self-consumption community structures |
| **ZEV** | Statutory self-consumption association (multiple participants) |
| **KEV / PRE** | Feed-in remuneration regimes (see §2.3.1) |
| **DSO** | Distribution system operator (Netzbetreiber) |

---

**Next actions:** Execute Fronius field test checklist (§2.1.9); scaffold `FroniusLocalClient` + `SolarSourceAdapter`; prepare investor one-pager from §3.4 metrics; schedule myStrom pilot alongside Connected tier pricing experiments.
