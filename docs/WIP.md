# Swiss Energy Assistant — Work In Progress

> **Last updated:** 1 November 2026 | **Status:** Ready for Play Store publication

---

## ✅ Completed (Investment Already Made)

| # | Item | Hours | Status |
|---|------|-------|--------|
| 1 | **Master spec analysis & WBS** — 20 work packages, 666h total estimate, 6-phase timeline | 12h | ✅ Done |
| 2 | **FastAPI backend** — Modular monolith, PostgreSQL, async, DST-safe, 14 unit tests | 40h | ✅ Live |
| 3 | **Next.js web dashboard** — Plotly charts, trilingual (DE/EN/FR), real-time provider data | 50h | ✅ Live |
| 4 | **3 Swiss provider integrations** — CKW, Groupe E, Primeo (SmartGridready schema) | 16h | ✅ Live |
| 5 | **Server-side proxy + 15-min cache** — Solves CORS + rate-limiting for all providers | 8h | ✅ Live |
| 6 | **Docker production deployment** — Multi-stage builds, nginx reverse proxy, TLS | 12h | ✅ Live |
| 7 | **VPS hosting** — `sea.supercharged.ch`, Hostinger VPS, CI-ready deploy script | 4h | ✅ Live |
| 8 | **Flutter mobile app** — Android APK, all WBS sections 9–16, Plotly WebView charts | 40h | ✅ Built |
| 9 | **Onboarding wizard** — 5-step flow, language selection, appliance management | 8h | ✅ Done |
| 10 | **Appliance optimizer** — Deterministic cheapest-window calculation (contiguous, non-interruptible) | 6h | ✅ Done |
| 11 | **Savings estimate** — Per-appliance + annual savings projection, best vs worst case | 4h | ✅ Done |
| 12 | **Provider landscape scan** — 30 Swiss providers researched, 3 with live public APIs | 4h | ✅ Done |
| 13 | **Home Assistant analysis** (doc 002) — Compete vs complement strategy | 4h | ✅ Done |
| 14 | **Energy savings strategy** (doc 003) — 4-phase roadmap, CHF savings model | 4h | ✅ Done |
| 15 | **Investor strategy + Solar roadmap** (doc 004) — Fronius API, partnership plan | 4h | ✅ Done |
| 16 | **Smooth Plotly charts** — Spline interpolation, pinch-to-zoom on mobile | 2h | ✅ Deployed |
| 17 | **PLZ auto-lookup** — 150+ Swiss PLZ offline database, auto-suggest provider | 2h | ✅ Done |
| 18 | **System language detection** — Defaults to device locale (DE/EN/FR) | 1h | ✅ Done |
| 19 | **Custom app icon** — Swiss Energy Clock icon in all platforms (Android/iOS/Web/PWA) | 2h | ✅ Done |
| 20 | **PWA support** — manifest.json, service worker, installable on mobile browsers | 2h | ✅ Deployed |
| 21 | **App Store badges** — "Get the App" section with Play Store + App Store links | 1h | ✅ Deployed |
| 22 | **Privacy policy** — Deployed at sea.supercharged.ch/privacy | 1h | ✅ Live |
| 23 | **Terms & conditions** — Deployed at sea.supercharged.ch/terms | 1h | ✅ Live |
| 24 | **AAB for Play Store** — Android App Bundle built and ready to upload | 1h | ✅ Ready |
| 25 | **Play Store guide** — Complete publishing instructions (doc 005) | 2h | ✅ Done |
| 26 | **Landing page redesign** — Professional layout, Myrax Core footer, no bloat | 4h | ✅ Deployed |
| 27 | **Chart legend fix** — Legend no longer overlaps chart lines | 1h | ✅ Deployed |
| 28 | **NullLink ID plan** — Zero-knowledge auth integration plan (doc 006) | 2h | ✅ Done |

**Total invested: ~238 hours**

---

## 🔧 Needs Profitable Implementation (Priority Order)

### P0 — Must-Have for MVP Launch (Next 2 Weeks)

| # | Item | Why | Est. |
|---|------|-----|------|
| 1 | **Play Store publication** | App is built, needs store listing, screenshots, privacy policy | 8h |
| 2 | **Fronius solar API integration** | Field test next week with real hardware, differentiator | 16h |
| 3 | **Push notifications (FCM)** | Core value — remind users before cheapest window | 12h |
| 4 | **User accounts + backend persistence** | Currently local-only, need cloud sync for retention | 20h |
| 5 | **App Store (iOS) publication** | Flutter already builds for iOS, need Apple developer setup | 8h |

### P1 — Revenue Enablers (Month 2)

| # | Item | Why | Est. |
|---|------|-----|------|
| 6 | **myStrom smart plug integration** | CHF 36/plug, verify actual savings, REST API | 12h |
| 7 | **Subscription/paywall** | Free tier → CHF 10/yr scheduling → CHF 30/yr connected | 16h |
| 8 | **More provider APIs** | As providers open APIs, expand coverage, increase TAM | 8h/provider |
| 9 | **EV charger integration** | go-e Charger API v2, Easee — high-value users | 16h |
| 10 | **Savings verification** | Measure actual vs predicted savings for credibility | 12h |

### P2 — Growth & Partnership (Month 3+)

| # | Item | Why | Est. |
|---|------|-----|------|
| 11 | **Home Assistant add-on** | MQTT/REST bridge, huge HA community | 24h |
| 12 | **SMA / Huawei / SolarEdge solar APIs** | Cover 80% of Swiss PV market | 12h/inverter |
| 13 | **Heat pump SG-Ready signaling** | Large savings potential, property manager value-add | 20h |
| 14 | **White-label for providers** | B2B2C revenue channel | 40h |
| 15 | **API for energy consultants** | B2B SaaS revenue, recurring | 24h |
| 16 | **ElCom annual tariff database** | Cover non-dynamic providers, 650+ utilities | 16h |
| 17 | **Battery storage optimization** | Charge/discharge scheduling with solar + grid prices | 20h |

---

## 📊 Key Metrics

| Metric | Current | Target (3 months) |
|--------|---------|-------------------|
| Swiss providers with live data | 3 | 8+ |
| Platforms | Web + Android APK | Web + Play Store + App Store |
| Users | 0 (pre-launch) | 500 beta users |
| Solar inverter brands supported | 0 | 2 (Fronius, SMA) |
| Revenue | CHF 0 | First paying users |

---

## 📁 Documentation Index

| Doc # | Title | Words |
|-------|-------|-------|
| 001 | Understanding & WBS | 8,500 |
| 002 | Home Assistant Analysis | 3,400 |
| 003 | Provider Landscape & Energy Savings | 4,250 |
| 004 | Investor Strategy & Solar Integration | 4,450 |
| 005 | Play Store Publishing Guide | 3,200 |
| 006 | NullLink ID Integration Plan | 1,800 |
| WIP | This document | — |

---

## 🔗 Live URLs

- **Web app:** https://sea.supercharged.ch/
- **API docs:** https://sea.supercharged.ch/docs
- **Health:** https://sea.supercharged.ch/api/v1/healthz

---

## 💡 Key Insight for Investors

The Swiss electricity market has **3.8 million households**. Dynamic tariffs are accelerating (EU Energy Efficiency Directive, Swiss voluntary adoption). There is **no established Swiss-specific tariff intelligence app**. We are the first with live provider API integrations and a working product. The path from "tariff viewer" to "energy management platform" is clear and technically validated.

**The moat:** Swiss provider API integrations + optimization algorithms + SmartGridready compliance + trilingual support. This is not a weekend project — it's infrastructure that takes months to build and test.
