# Swiss Energy Assistant

> Understand your Swiss electricity tariff. Know the best time to run your appliances. No hardware required.

A tariff intelligence and appliance scheduling application for Swiss households. Provides day-ahead electricity price visualization, personalized appliance scheduling recommendations, and transparent tariff comparisons.

![Architecture](docs/architecture.md)

## Quick Start

### Prerequisites
- Node.js 20+
- Python 3.12+
- Docker & Docker Compose (for full stack with database)

### Option A: Frontend only (demo mode)
```bash
cd frontend
cp .env.example .env.local
npm install
npm run dev
# → Open http://localhost:3000
```

### Option B: Full stack with Docker
```bash
cp .env.example .env
docker compose up --build
# → Frontend: http://localhost:3000
# → Backend API: http://localhost:8000
# → API Docs: http://localhost:8000/docs
```

### Option C: Backend only (local development)
```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -e ".[dev]"

# Run tests
pytest tests/ -v

# Start server (requires PostgreSQL)
uvicorn app.main:app --reload
# → http://localhost:8000/docs
```

## Project Structure

```
swiss-energy-assistant/
├── docs/                         # Documentation
│   └── 001_understanding_and_wbs.md
├── backend/                      # FastAPI Python backend
│   ├── app/
│   │   ├── main.py              # FastAPI app entry
│   │   ├── core/                # Config, security, clock, logging
│   │   ├── api/v1/             # REST API endpoints
│   │   ├── models/             # SQLAlchemy database models
│   │   ├── schemas/            # Pydantic request/response schemas
│   │   ├── services/           # Business logic (optimizer, calculator)
│   │   ├── integrations/       # Provider adapters (CKW, Groupe E, etc.)
│   │   └── jobs/               # Tariff ingestion schedulers
│   └── tests/                  # Unit & integration tests
├── frontend/                    # Next.js dashboard
│   └── src/
│       ├── app/                # Next.js app router (single page)
│       ├── components/         # React components
│       ├── hooks/              # Zustand store & custom hooks
│       ├── i18n/               # DE/EN/FR translations
│       ├── lib/                # API client, mock data, utilities
│       └── types/              # TypeScript type definitions
├── docker-compose.yml
└── .env.example
```

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/healthz` | Health check |
| GET | `/api/v1/providers` | List energy providers |
| GET | `/api/v1/providers/{id}/products` | Provider tariff products |
| GET | `/api/v1/locations/search?query=` | Municipality/postcode search |
| GET | `/api/v1/tariffs/intervals?product_id=&date=` | Day-ahead price intervals |
| GET | `/api/v1/tariffs/summary?product_id=&date=` | Daily price summary stats |
| GET | `/api/v1/annual-tariffs?year=&municipality_id=` | ElCom regulated annual tariffs |
| POST | `/api/v1/auth/bootstrap` | Create/retrieve user account |
| GET/POST | `/api/v1/me/appliances` | List/create appliances |
| PATCH/DELETE | `/api/v1/me/appliances/{id}` | Update/remove appliance |
| POST | `/api/v1/recommendations/preview` | Preview optimal scheduling |
| POST | `/api/v1/comparisons/local` | Compare local eligible tariffs |
| GET | `/api/v1/comparisons/switzerland` | Swiss-wide tariff benchmarks |
| GET/PUT | `/api/v1/me/notifications/preferences` | Notification settings |
| GET | `/api/v1/admin/providers/health` | Provider adapter status |

## Dashboard Features

- **Price Chart**: 24-48h step-line chart with energy/network component toggle, Rp./kWh and CHF/kWh units
- **Appliance Cards**: Washer, dishwasher, dryer, EV with best start time, cost estimate, savings indicator
- **Tariff Breakdown**: Visual component breakdown (energy, network, levies, VAT, fixed fees)
- **Local Comparison**: Eligible tariff products with eligibility requirements
- **Swiss Explorer**: Municipality-level ElCom benchmark table with non-switchable disclaimer
- **Notifications**: Daily digest, appliance reminders, quiet hours configuration
- **Multilingual**: German (default), English, French with live language toggle

## Key Design Decisions

1. **Software-only MVP** — advice before automation, no appliance switching
2. **Next.js frontend** — SSR-capable, responsive single-page dashboard
3. **FastAPI backend** — modular monolith, async, typed schemas
4. **Component-level pricing** — never present partial prices as full bill
5. **Provider adapters** — each provider's API has a dedicated adapter with fixtures
6. **DST-safe** — all times stored in UTC; 23/25-hour days handled correctly
7. **DEMO labeling** — all mock data clearly marked, never presented as real prices

## Supported Providers (MVP)

| Provider | Status | Resolution | Scope |
|----------|--------|------------|-------|
| CKW | Needs access | Hourly | Network only |
| Groupe E | Needs access | 15-min | Full tariff |
| EKZ | Comparison only | 15-min | Requires EMS |
| Primeo | 2027 readiness | Hourly | Requires EMS |
| ElCom | Annual data | Annual | Reference |

## Testing

```bash
# Backend tests
cd backend && source venv/bin/activate
pytest tests/ -v

# Frontend build check
cd frontend
npm run build
```

## License

Private — all rights reserved.
