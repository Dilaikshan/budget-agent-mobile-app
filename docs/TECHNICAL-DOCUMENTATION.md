# Budget Agent — Technical Documentation (as implemented)

Audience: developers maintaining the code. Companion to [SYSTEM-DOCUMENTATION](SYSTEM-DOCUMENTATION.md). Contracts and invariants come from the numbered specs; this file maps them to the actual code. A navigable code graph is in `graphify-out/` (`graph.html`, `GRAPH_REPORT.md`; query with `graphify query "..."`).

---

## 1. Repository layout

```text
AGENTS.md, README.md, MANUAL_STEPS.md
docs/00-14-*.md            specifications (target design)
docs/SYSTEM-DOCUMENTATION.md, docs/TECHNICAL-DOCUMENTATION.md
docs/contracts/hash-vectors.json   canonical-JSON/SHA-256 vectors shared by Dart and TS tests
firebase.json, firestore.rules, firestore.indexes.json, .firebaserc
backend/                   Vercel TypeScript functions (deployed)
mobile/                    Flutter Android app
tasks/001-019              backlog with per-task status
graphify-out/              Graphify code knowledge graph
(root server.ts, src/, index.html, metadata.json, package.json: legacy web prototype, not deployed — see ADR-16)
```

## 2. Toolchain and dependencies

| Area | Version (pinned) |
|---|---|
| Flutter / Dart | 3.47.5 / 3.13.4 (`mobile/pubspec.lock` committed) |
| Riverpod / go_router / Drift | 3.4.3 / 18.0.2 / 2.35.0 (+ drift_flutter 0.3.1, sqlite3 3.x native assets) |
| Firebase (mobile) | firebase_core 4.15, firebase_auth 6.7, firebase_app_check 0.4.8, firebase_crashlytics 5.4, google_sign_in 7.2 |
| Node runtime | 22.x on Vercel (`engines`) |
| Backend libs | ai 7.0.122, @ai-sdk/google 4.0.85, @ai-sdk/provider 4.0.19, @openrouter/ai-sdk-provider 3.1.0, firebase-admin **13.10.0**, zod 4.6.5 |
| Backend tests | vitest 3.2.7, fast-check 3.23.2, typescript 5.9.3 |

firebase-admin is held at 13.x because 14.x pulls `jwks-rsa` 4 → ESM-only `jose`, which Vercel's loader cannot `require()` (verified `ERR_REQUIRE_ESM`).

## 3. Backend (`backend/`)

### 3.1 Layers

```mermaid
flowchart TB
  subgraph api [api/ — thin Vercel entry points]
    H[health.ts] 
    P[v1/sync/push.ts] 
    C[v1/sync/changes.ts]
    PA[v1/agent/parse-transaction.ts]
    CL[v1/agent/classify-transaction.ts]
    IN[v1/agent/insights.ts]
    J[jobs/daily-agent.ts]
  end
  subgraph http [src/http + routes]
    R[route(): method, content-type, size, deps, auth, envelope]
  end
  subgraph core [services]
    SY[sync/service.ts + validate.ts + change-log.ts]
    AG[agents/parse, classify, daily, insights, rules, context]
    AI[ai/router, providers, prompts, budget]
  end
  subgraph infra [infrastructure]
    AU[auth/guards + verifier]
    ST[store/scope → store/firestore | store/memory]
    CF[config/env]
    LG[observability/log]
    RL[limits/rate-limit]
  end
  api --> R --> AU
  R --> SY & AG
  AG --> AI
  SY & AG & RL --> ST
```

### 3.2 Request pipeline (`src/http/route.ts`)

1. `requestId` generated; optional `X-Client-Request-Id` (UUID) logged for correlation. `Cache-Control: no-store` on every response.
2. Method check (405), JSON content-type and `Content-Length` limit (64 KiB; push 256 KiB) **before** authentication.
3. `getDeps()` builds config/store/verifier once per warm instance; `ConfigError` → route's 503 code (`SYNC_UNAVAILABLE`/`AI_UNAVAILABLE`/`JOB_UNAVAILABLE`).
4. `authenticateUser()` (user routes): Bearer ID token → `verifyIdToken(token, checkRevoked=true)` + audience = project → `uid == OWNER_UID` (constant-time) → `email_verified` → App Check token verified and `appId ∈ ALLOWED_APP_IDS`. No environment bypass.
5. Body parsed; re-measured; query params must be single strings.
6. Handler result → `{data, requestId}`; `ApiError` → `{error:{code,message,retryable,fields}, requestId}` with fixed safe messages and `Retry-After` when relevant; unknown errors are logged by error name only and mapped to 503.

### 3.3 Endpoints

| Route | Handler | Notes |
|---|---|---|
| `GET /api/health` | `api/health.ts` | Static `{status:"ok",version:"1"}` |
| `POST /api/v1/sync/push` | `routes/sync.ts → SyncService.push` | Strict `PushRequestSchema`, whole-batch `validateBatch`, rate 30/min |
| `GET /api/v1/sync/changes` | `SyncService.changes` | `afterSeq`, optional `watermark`, `limit` 1..100, rate 60/min |
| `POST /api/v1/agent/parse-transaction` | `agents/parse.ts` | `Idempotency-Key` UUID, rate 10/min + 100/day |
| `POST /api/v1/agent/classify-transaction` | `agents/classify.ts` | `{transactionId, baseRevision}` |
| `GET /api/v1/agent/insights` | `routes/insights.ts` | `from`,`to` (≤366 days), HMAC-signed cursor, no model call |
| `GET /api/jobs/daily-agent` | `agents/daily.ts` | `Authorization: Bearer CRON_SECRET` only; no query params |

### 3.4 Configuration (`src/config/env.ts`)

Core (required for data routes): `APP_ENV`, `FIREBASE_PROJECT_ID`, `FIREBASE_CLIENT_EMAIL`, `FIREBASE_PRIVATE_KEY` (literal `\n` normalized), `OWNER_UID`, `ALLOWED_APP_IDS`. Emulator hosts are rejected outside development.

AI (`loadAiConfig`, independent — failure only disables AI): `AI_ENABLED`, `AI_PRIVACY_ELIGIBLE`, `AI_PRIVACY_POLICY_VERSION` (must equal the app's `kPrivacyPolicyVersion = pp-2026-09`), `GEMINI_API_KEY`, `GEMINI_MODEL` (no `latest` aliases), optional `FALLBACK_ENABLED` + `OPENROUTER_API_KEY` + `OPENROUTER_MODEL` + non-empty `OPENROUTER_ALLOWED_PROVIDERS`, `AI_DAILY_ATTEMPT_LIMIT`/`_INPUT_TOKEN_LIMIT`/`_OUTPUT_TOKEN_LIMIT` (100 / 100000 / 20000), `AI_FAKE_PROVIDER` (non-production only).

Jobs/insights: `CRON_SECRET` (≥43 chars), `CURSOR_SIGNING_KEY` (≥43 chars).

### 3.5 Storage abstraction (`src/store`)

- `DocStore` port: `get`, `query(QuerySpec)`, `runTransaction` (reads before writes). `FirestoreStore` (Admin SDK, `maxAttempts:5`) and `MemoryStore` (serialized transactions, buffered writes, read-after-write guard, `failNextCommit` fault injection) implement it.
- `UserScope` is the only path builder: `users/{verifiedUid}/{allowlisted collection}/{id}`. UID must come from a verified token or the configured cron owner. No method accepts arbitrary paths.
- Instants are stored as RFC3339 millisecond UTC strings (ADR-16).

Firestore layout under `users/{uid}/`:

| Collection | Content |
|---|---|
| `profiles/profile`, `app_settings/settings` | singletons |
| `accounts`, `income_sources`, `categories`, `transactions`, `categorization_rules`, `budgets` | user entities (canonical records) |
| `ai_proposals`, `ai_insights`, `ai_activity`, `agent_runs`, `review_states` | server-owned replicated records |
| `changes/{seq 12-digit}` | immutable `{seq, ledgerChanged, mutations[], committedAt}` |
| `operation_receipts/{opId}` | `{requestHash, seq, acceptedChanges[]}` |
| `sync_meta/state` | `{lastSeq, lastLedgerSeq, currencyLocked}` |
| `run_leases`, `work_receipts`, `rate_limits`, `ai_requests` | internal, never replicated |

Every canonical record has `id, schemaVersion:1, revision, createdAt, serverUpdatedAt, deletedAt` plus its payload. Composite indexes and index exemptions are in `firestore.indexes.json`.

### 3.6 Sync protocol (`src/sync`)

`validate.ts` (whole batch, before anything executes):
- Action/entity allowlist (e.g. accounts only via `createAccountWithOpening`; delete only transaction/rule/budget; `dismissInsight`/`rejectProposal` only on insights/proposals).
- Singleton IDs (`profile`, `settings`); new entities need UUIDs, `baseRevision 0`, no dependency.
- Exactly one of `baseRevision ≥1` or `dependsOnOpId`.
- Strict zod payload per entity (unknown/server fields rejected; NFC/trimmed text; money 1..10¹²; `effectiveDate` must equal `occurredAt`'s date in `entryTimeZone`; transfer accounts distinct; income needs category + source; clients can't create openings).
- Confirmation required except dismiss/reject; `payloadHash = sha256(canonical({action,entityType,entityId,baseRevision,dependsOnOpId,payload}))`; `predecessorOpId == dependsOnOpId`.

`service.ts` — one Firestore transaction per operation:
1. Receipt lookup **first**: same `requestHash` → replay original `Change` (`replayed:true`); different → `IDEMPOTENCY_KEY_REUSED`.
2. Expected revision = explicit `baseRevision` or the predecessor receipt's revision for the same entity (`DEPENDENCY_FAILED` otherwise).
3. CAS: create requires absent (tombstones block resurrection); update/delete require live record at the expected revision → else `conflict` with the caller's current record.
4. Reference checks via `ReferenceReader`: profile exists; currency equals profile; references exist (`MISSING_REFERENCE`); newly selected archived references → `ARCHIVED_REFERENCE` (retained ones allowed); category type matches; category depth ≤2; type/currency/parent immutable; budget parent/child overlap; profile currency locked after first opening; proposal binding (`STALE_PROPOSAL` unless pending, unexpired, right kind/target/revision).
5. Writes via `publishChange`: records + `ReviewState` (queued for income/expense/transfer, reviewed for openings or accepted categorised proposals) + accepted proposal status, one `Change` (≤64 KiB; records ≤16 KiB), `SyncState`, receipt.

`changes()` reads `sync_meta/state`, validates `afterSeq ≤ lastSeq` and `afterSeq ≤ watermark ≤ lastSeq`, then returns contiguous changes `(afterSeq, W]`.

### 3.7 AI layer (`src/ai`, `src/agents`)

- `providers.ts`: `ModelProvider.generateStructured` using AI SDK v7 `generateText` + `Output.object`, `maxRetries:0`, `temperature:0`, `maxOutputTokens 1500`, `AbortSignal.timeout`. Gemini via `createGoogle({apiKey})`; OpenRouter via `openrouter.chat(model, {provider:{only, allow_fallbacks:false, data_collection:'deny', require_parameters:true}})`. Errors classified into `timeout | rateLimited | unavailable | invalidOutput | authError | refused`.
- `router.ts`: primary then one fallback; fallback only for timeout/429/5xx/invalid output/auth; never for refusal; per-attempt ≤10 s within a 25 s request deadline; budget reserved before each attempt (`budget.ts`, Firestore `rate_limits/ai-budget-YYYYMMDD`) and reconciled with reported usage.
- `prompts.ts` (`parse-v1`, `classify-v1`): safety preamble, untrusted input in `<input>`, aliases `A1/C1/S1`, `redact()` replaces account/source names and removes emails, URLs, 9+ digit runs. Model schema returns aliases and the amount as decimal text.
- `rules.ts`: deterministic parser (amount with exact decimal parsing, intent keywords, account mentions/prepositions, cash-only-if-said, curated merchants/keywords, user rules by priority with tie → question, income-source inference, dates today/yesterday/ISO, ambiguous dd/mm refused). `isSufficient()` decides whether a model call is needed.
- `parse.ts`: consent check (`aiEnabled`, `providerConsentAt`, policy version) → idempotency lease (`ai_requests`, 24 h cache) → rules → history (≥3 matches, ≥90% agreement in 90 days) → optional model → alias/ID validation → merge (explicit text wins; confidence <0.6 leaves field empty + question) → one transaction writing `AIProposal`, `AgentRun`, `AIActivity` and the cached response. Both providers failing → `AI_UNAVAILABLE` + failed run record.
- `classify.ts`: revision-bound `categoryChange` proposal; shared `suggestCategory()` used by the daily agent.
- `daily.ts`: `runId = sha256(uid+businessDate+"daily-v1")`, lease with fence (90 s), queue of `review_states` (`state=queued`, id order, ≤50), per-item checkpoint transaction verifying fence/revision/receipt, `work_receipts` for idempotency, deterministic insights (`insights.ts`) published only if `lastLedgerSeq ≤ sourceWatermark`, bounded cleanup.

### 3.8 Logging

`observability/log.ts` emits JSON with an allowlist of fields (IDs, route, status, codes, durations, counts, provider/model). Raw input, prompts, amounts, names and tokens are never logged. Unexpected errors log only the error name/code.

## 4. Mobile (`mobile/`)

### 4.1 Structure

```text
lib/main.dart                 config validation → Firebase init (options from defines) → App Check → Crashlytics → app
lib/app/                      providers.dart (Riverpod wiring, SyncController), router.dart (guards + shell), theme.dart
lib/core/config/              app_config.dart (dart-defines), privacy.dart (policy version + disclosure)
lib/core/domain/              pure Dart: money, canonical_json, time (IANA), text (NFC limits), transaction (union + validator), ledger, result
lib/core/database/            tables.dart (Drift schema), app_database.dart (+ generated .g.dart)
lib/core/data/                codecs.dart (record ⇄ row), local_store.dart (atomic writes, outbox, apply/ack/conflicts)
lib/core/network/api_client.dart   Dio client, credential source, ApiFailure
lib/core/sync/sync_engine.dart     pull/push/pull, backoff, pause
lib/core/widgets/             MoneyText, SyncBadge, EmptyState, ErrorBanner, ConfirmationSheet, selectors
lib/features/<feature>/{data,domain,application,presentation}
test/                         core, onboarding, transactions, screens tests + fake server + harness
```

### 4.2 Configuration (build defines)

`flutter run|build --dart-define-from-file=env/<env>.json` with `APP_ENV`, `API_BASE_URL`, `FIREBASE_API_KEY`, `FIREBASE_APP_ID`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_PROJECT_ID`, `GOOGLE_SERVER_CLIENT_ID`, `APP_CHECK_DEBUG`, and temporarily `ALLOW_DEBUG_APP_CHECK_IN_RELEASE`. Missing/invalid values show a configuration-error screen instead of crashing. `env/*.json` is git-ignored; `*.example.json` are templates. No `google-services.json` is needed.

### 4.3 Local database (Drift, schema v1)

- One SQLite file per Firebase UID: `budget_agent_<sha256(uid)[0:16]>`. `PRAGMA foreign_keys=ON`.
- Replicated tables share `SyncMeta`: `(user_id,id)` PK, `revision` (last accepted), server timestamps, `local_version`, `sync_status` CHECK (`synced|pending|syncing|conflict|blocked`), local timestamps.
- Tables: profiles, settings_records, accounts, income_sources, categories, transactions, categorization_rules, budgets, ai_insights, ai_proposals, review_states, ai_activities, agent_runs; local-only outbox_ops, remote_shadows, sync_cursors, sync_conflicts, drafts.
- Constraints: CHECKs on enums/amounts, composite FKs to accounts/categories/sources, transfer-distinct and income-needs-category/source CHECKs, `json_valid` on JSON columns, partial unique index for live budgets per month/category, indexes per spec.
- Migrations: `onUpgrade` currently throws (only v1 exists); add numbered forward migrations, never drop and recreate.

### 4.4 Write path and confirmation binding

`Confirmation.ofDisplayed(payload)` (created only by `showConfirmationSheet`) stores the canonical hash of exactly what was shown. Repository methods call `LocalStore.upsert/delete/createAccountWithOpening`, which:
1. reject if the confirmation hash ≠ payload hash;
2. in one SQLite transaction: check existence/`expectedLocalVersion`, increment `local_version`, enqueue an immutable outbox op (dependency on the latest unacknowledged op for the same entity, otherwise explicit `baseRevision`; confirmation `payloadHash` computed with the same canonical JSON as the server), upsert the overlay row with `sync_status=pending`.
SQLite errors map to typed `AppError` (FK → missing reference, full → storage full).

Repositories (`features/*/data`): `ProfileRepository`, `AccountRepository` (balances via one SQL aggregate over transactions; create with opening; opening correction), `CategoryRepository` (+defaults), `IncomeSourceRepository`, `RuleRepository`, `LedgerRepository` (filters, month totals, `ReferenceSnapshot` for the validator), `BudgetRepository` (subtree spend SQL + overlap validation), `AgentRepository` (local quick parse, server parse/classify, insights/activity/proposals/review count).

### 4.5 Sync engine (`core/sync/sync_engine.dart`)

- `syncOnce()` is serialized; on first run `syncing` ops reset to `pending`.
- Pull: pages applied with `applyPage` (shadow first; visible row only if no outstanding op; cursor + `lastLedgerSeq` in the same transaction). Unknown entity type or schemaVersion → `UPGRADE_REQUIRED` pause, cursor not advanced.
- Push: ≤20 ready ops × ≤5 batches. 413 → halve; batch 422 → isolate one by one; auth failures → pause with code; transient failures → full-jitter backoff (1 s·2ⁿ, cap 5 min, `Retry-After` ≤1 h).
- Results: accepted → ack + materialize; conflict → `SyncConflict` (base/proposed/server JSON) and dependents blocked; rejected → blocked. Resolution: `keepRemote`, `applyMine` (new confirmed op at current revision), `discardBlocked`.
- Triggers (`SyncController` + `main.dart`): store open, resume, connectivity, outbox growth (2 s debounce), 5-minute foreground timer, manual.

### 4.6 UI architecture

Riverpod providers expose repositories and streams; widgets only call repositories/providers. `go_router` redirect: loading → `/splash`; signed out → `/sign-in`; unverified → `/verify-email`; no completed profile → `/onboarding`; otherwise shell (`/home`, `/transactions`, `/insights`, `/more`) with Add FABs. Entry sheet (`transactions/presentation/entry_sheet.dart`) implements quick/category/transfer/edit modes with the shared `buildPayload` validator; `transaction_actions.dart` holds confirmation rows, delete and proposal accept/reject logic (stale/unsynced checks).

### 4.7 Branding, splash and motion

- `lib/app/brand.dart`: product name (Surge Budget), tagline, colours; Android label in `AndroidManifest.xml`.
- Assets (`assets/splash/`): `surge_mark.svg` (vector logo), `robot_body.svg` + `robot_arm.svg` (mascot; arm pivots at the shoulder), `surge_mark_mascot.svg` and `splash.svg` (static composites), PNGs for the native splash generated by `dart run flutter_native_splash:create`.
- `lib/app/animated_splash.dart`: `SplashOverlay` wraps the router (2.8 s intro + 0.5 s hold + fade); `_Mascot` drops, waves and shows the \"Hi!\" bubble; `BrandedLoading` for the loading route.
- `lib/core/widgets/motion.dart`: `CountUpMoney` (integer tween, final value for screen readers) and `staggered()`/`StaggerIn`. All motion respects `MediaQuery.disableAnimations`.

### 4.8 Android packaging

`applicationId com.dilaxdigit.budget_agent`, minSdk 23, INTERNET/ACCESS_NETWORK_STATE permissions, `allowBackup=false` + data-extraction rules excluding all app data, release signing from `android/key.properties` + `app/upload-keystore.jks` (git-ignored; back them up), launcher icons generated by `flutter_launcher_icons` from `assets/icon/`.

## 5. Shared contracts

- Canonical JSON: sorted keys (UTF-16 order), no whitespace, standard escapes, safe integers only (no floats, −0 or >2⁵³−1). Implemented in `backend/src/contracts/canonical.ts` and `mobile/lib/core/domain/canonical_json.dart`; both tested against `docs/contracts/hash-vectors.json`.
- Opening transaction ID = `sha256("opening:"+accountId)`.
- Deterministic server IDs: `sha256(parts joined by U+001F)` for runs, proposals, activities, insights.

## 6. Testing

| Suite | Command | Count | Covers |
|---|---|---|---|
| Backend | `cd backend && npm test` | 154 | hash vectors, money, ledger properties (fast-check), schemas, sync CAS/replay/dependencies/references/budgets/isolation/fault injection, guards & config, route envelope, 52 parser goldens, redaction, router fallback matrix, budget exhaustion, parse/classify services, daily agent idempotency/leases/staleness |
| Mobile | `cd mobile && flutter test` | 40 | hash vectors, money, validator, LocalStore atomicity/confirmation/dependencies/FKs, sync engine vs fake server (ack, lost ack, conflicts, blocked, unknown schema, bootstrap, auth pause), onboarding, entry flows, screens |
| Static | `npm run typecheck`, `flutter analyze` | — | clean |

Not yet automated: Firestore emulator/rules tests, device integration, live model accuracy evaluation, CI.

## 7. Build, deploy, operate

```bash
# backend
cd backend && npm ci && npm run typecheck && npm test
vercel deploy --prod                     # project root = backend/
# firestore
firebase deploy --only firestore:rules,firestore:indexes --project budget-agent-app-a513e
# mobile
cd mobile && flutter pub get && flutter analyze && flutter test
dart run build_runner build              # after editing Drift tables
dart run flutter_launcher_icons          # after changing assets/icon/*
flutter build apk --release --dart-define-from-file=env/prod.json
adb install -r build/app/outputs/flutter-apk/app-release.apk
# code graph
graphify update .                        # refresh graphify-out/ after code changes
```

Production env vars live only in Vercel (team `dilax`, project `budget-agent-backend`). Kill switches: `AI_ENABLED=false` (AI only), `FALLBACK_ENABLED=false`. Rollback: redeploy a previous Vercel deployment; it does not revert data.

## 8. Known limitations and next steps

1. Export/restore (task 017) not implemented.
2. CI with secret/dependency scanning and Firestore emulator tests (task 018).
3. Play Store release with Play Integrity; remove `ALLOW_DEBUG_APP_CHECK_IN_RELEASE` and the registered debug token (task 019).
4. Server-side accumulated-balance overflow is not checked per commit (client reducers use checked sums).
5. Drift has only schema v1; add migration tests with the first schema change.
6. Gemini key is on the free tier and was shared in a chat; rotate and consider a billed project for real financial data.
