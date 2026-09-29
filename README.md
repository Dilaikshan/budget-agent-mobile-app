# Budget Agent

An AI-first personal finance mobile application with an offline ledger and transparent, confirmable AI assistance. Enter “lunch kfc 2500 cash” or choose Food → Restaurant, review the same normalized transaction, and save immediately even without connectivity.

**Repository status (2026-09-29):** backend implemented, tested (154 tests) and deployed to Vercel at https://budget-agent-backend.vercel.app (health live; data/AI routes wait for Firebase and model secrets). Flutter Android app implemented with 40 passing unit/widget tests. Export/restore, CI workflows, emulator/device tests and release review remain; see task statuses and [MANUAL_STEPS.md](MANUAL_STEPS.md).

## Capabilities and stack

MVP: Google/email sign-in, guided opening balances, accounts, categories, income sources, income/expense/transfers, monthly category budgets, offline synchronization, natural-language proposals, learned rules, daily review, recurring-pattern suggestions, insights and AI Activity. AI failures never block manual entry.

Flutter + Riverpod + go_router + Drift/SQLite; Firebase Auth, Firestore Spark, App Check and Crashlytics; TypeScript on Vercel Hobby using Vercel AI SDK, Gemini primary and OpenRouter fallback. No required Cloud Functions, Firebase Storage, bank PDF ingestion or n8n.

## Repository layout

```text
AGENTS.md                    Coding-agent operating rules
README.md                    Entry point
docs/00-...14-*.md           Implementation specifications
docs/diagrams/               Reserved for shared Mermaid sources if needed
tasks/001-...019-*.md        Implementation backlog with explicit dependencies
mobile/                     Reserved Flutter root
backend/                    Reserved Vercel TypeScript root
budget_ai_agent_*.docx       Preserved legacy references
```

Diagrams are embedded in the owning specifications to avoid duplicate versions. Empty application directories are intentional.

## Local setup and workflow

Toolchain used: Flutter 3.47.5 (Dart 3.13.4), Node 22 (Vercel runtime 22.x), npm lockfile and pubspec.lock committed.

```text
backend:  npm ci; npm run typecheck; npm test
          vercel deploy --prod            (project root = backend/)
mobile:   flutter pub get
          dart run build_runner build     (only after changing Drift tables)
          flutter analyze; flutter test
          flutter run --dart-define-from-file=env/dev.json
root:     firebase deploy --only firestore:rules,firestore:indexes
```

Operator setup (Firebase project, secrets, owner UID, App Check, model keys) is in [MANUAL_STEPS.md](MANUAL_STEPS.md). Fake/in-memory adapters back all automated tests; no live provider or production data is used by CI. Do not enable production AI with private financial data before the provider-privacy gate in docs/07 passes.

## Documentation index

| Document | Owns |
|---|---|
| [00 Product](docs/00-PRODUCT-OVERVIEW.md) | Scope, requirements and success |
| [01 Architecture](docs/01-ARCHITECTURE.md) | Boundaries and system diagrams |
| [02 Technical specification](docs/02-TECHNICAL-SPECIFICATION.md) | Modules, packages and conventions |
| [03 Implementation plan](docs/03-IMPLEMENTATION-PLAN.md) | Phases and dependency gates |
| [04 Data model](docs/04-DATA-MODEL.md) | Authoritative entities and ledger rules |
| [05 API contracts](docs/05-API-CONTRACTS.md) | Authoritative HTTP and wire contracts |
| [06 AI agent design](docs/06-AI-AGENT-DESIGN.md) | Rules, providers, tools and daily execution |
| [07 Security](docs/07-SECURITY.md) | Threats, authorization and privacy |
| [08 Offline sync](docs/08-OFFLINE-SYNC.md) | Authoritative synchronization protocol |
| [09 UI/UX](docs/09-UI-UX-DESIGN.md) | Screens, states and interactions |
| [10 Testing](docs/10-TESTING-STRATEGY.md) | Test matrix and release scenarios |
| [11 Observability](docs/11-OBSERVABILITY.md) | Activity, telemetry and operational response |
| [12 Deployment](docs/12-DEPLOYMENT.md) | Environments, quotas and release checklist |
| [13 Decisions](docs/13-DECISIONS.md) | ADRs, source reconciliation and risks |
| [14 Roadmap](docs/14-FUTURE-ROADMAP.md) | Deferred capabilities and adoption gates |

For disagreements, consult the document that owns the contract and record a decision before changing it. Product principles in AGENTS.md remain non-negotiable.
