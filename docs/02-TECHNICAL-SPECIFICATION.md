# Technical specification

## Runtime and packages

Version policy: select mutually compatible stable releases at task 001, record exact Flutter/Dart and Node/npm versions in toolchain files, and commit pubspec.lock/package-lock.json. No source exists to justify claiming an exact installed version today. Require Node LTS supported by Vercel at deployment. Dependency upgrades are separate reviewed tasks with contract and migration tests.

| Layer | Selected packages | Responsibility |
|---|---|---|
| Mobile shell | flutter_riverpod, go_router | Injection, observable state, route guards |
| Local persistence | drift, drift_dev, sqlite3, path_provider, build_runner | SQLite executor, typed DAOs, migrations; choose platform native asset support compatible with pinned Drift |
| Identity | firebase_core, firebase_auth, google_sign_in | Auth lifecycle; no password persistence |
| Attestation/diagnostics | firebase_app_check, firebase_crashlytics | App verification and sanitized crash reporting |
| HTTP | dio | Token interceptors, cancellation and typed failures |
| Utilities | uuid, intl, timezone, flutter_secure_storage, connectivity_plus | IDs, formatting, IANA date conversion, sensitive preferences, connectivity hints |
| Presentation | fl_chart | Accessible budget/trend charts with textual equivalents |
| Backend | typescript, @vercel/node, firebase-admin, zod | HTTP runtime, scoped persistence, validation |
| AI | ai, @ai-sdk/google, @openrouter/ai-sdk-provider | Structured generation and adapters |
| Backend tests | vitest, fast-check, @firebase/rules-unit-testing | Unit/property/contract and emulator checks |

Do not add cloud_firestore to the mobile runtime for MVP: all replication uses the authenticated sync API. Firebase emulator rules tests may use a client SDK in the test harness. Pin AI SDK/provider peer-compatible versions and verify current APIs before implementation. Structured generation uses generateText with Output.object where supported by the pinned version; see [AI SDK output](https://ai-sdk.dev/docs/reference/ai-sdk-core/output) and [Google provider](https://ai-sdk.dev/providers/ai-sdk-providers/google-generative-ai).

## Module boundaries

```text
mobile/lib/
  core/{config,database,network,sync,theme,errors,time}
  features/{auth,onboarding,accounts,income_sources,categories,transactions,
            transfers,budgets,insights,ai_activity,settings}/
    {domain,application,data,presentation}/
backend/
  api/v1/{sync,agent}/                 Thin user HTTP functions
  api/jobs/daily-agent.ts             Cron-only function
  api/health.ts
  src/{auth,config,contracts,domain,sync,firestore,ai,agents,tools,observability}
  test/{unit,contracts,emulator,fixtures}
```

Widgets render state and intent only. Controllers expose immutable loading/data/error state. Use cases validate and transact; domain owns ledger arithmetic. Repository implementations combine local DAO writes with outbox enqueue. Sync owns remote shadows, receipts and cursors, not screen lifecycle. Backend guards create AuthContext; services receive that context, never a UID parsed from JSON. Firestore repositories require a scoped context and expose no arbitrary collection path methods.

## Repository contracts

Illustrative interfaces, to be implemented with the pinned language tools:

```text
LedgerRepository.watchAccountBalances() -> Stream<List<AccountBalance>>
LedgerRepository.watchTransactions(filter, page) -> Stream<TransactionPage>
LedgerRepository.confirmCreate(Draft, Confirmation) -> Result<TransactionId>
LedgerRepository.confirmUpdate(id, expectedLocalVersion, Draft, Confirmation) -> Result<void>
LedgerRepository.confirmDelete(id, expectedLocalVersion, Confirmation) -> Result<void>
AccountRepository.createWithOpening(AccountDraft, signedOpeningMinor, Confirmation) -> Result<AccountId>
RuleRepository.saveAcceptedRule(RuleDraft, Confirmation) -> Result<RuleId>
SyncRepository.syncOnce() -> Result<SyncSummary>
AgentRepository.parse(LocalDraft) -> Result<ParseResponse>
```

Queries are local and reactive. Accounts/sources/categories/budgets/settings have analogous watch/create/update/archive methods. Edits to archived reference names are allowed, but new financial references to archived entries are rejected. No hard delete of financial reference entities in MVP.

## Value and serialization conventions

- JSON UTF-8 camelCase; Drift snake_case. API v1 requires strict object schemas (reject unknown keys). Null is explicit for irrelevant fields; absent is allowed only for documented optional request properties.
- IDs: random UUID v4 generated locally; fixed singleton IDs profile/settings; seeded categories also use persisted UUIDs. Server output IDs use deterministic SHA-256 identifiers as specified in AI design. Treat IDs as opaque and prohibit path separators.
- Currency: profile baseCurrency ISO 4217, default LKR; currencyExponent=2 for LKR, immutable after first opening transaction. All accounts and transactions use it. Reject FX and silent currency conversion.
- amountMinor JSON number must be a safe integer 1..1,000,000,000,000. signedOpeningMinor permits the negative of that bound through positive bound, including zero. Parse decimal text with string arithmetic; reject excess fractional digits, ambiguous separators and nonfinite values. Dart int and SQLite INTEGER; backend checked integers/BigInt intermediates. Accumulated balances must remain inside ±9,007,199,254,740,991 or fail validation. Do not serialize BigInt directly.
- UTC instants use RFC3339 with exactly millisecond precision and Z. Drift stores epoch milliseconds INTEGER; Firestore stores Timestamp. occurredAt is user effective time; effectiveDate is YYYY-MM-DD derived in entryTimeZone. Preserve effectiveDate on timezone changes so old budget months do not move. Date-only input resolves to noon in the chosen IANA zone; ambiguous/invalid local times require explicit resolution.
- profile timeZone defaults Asia/Colombo, not a hardcoded offset. Business dates and reporting periods use it. serverUpdatedAt orders nothing; change sequence controls sync. Client timestamps are audit/display only.
- Text limits: names 80, merchant 120, description 500, rawInput 1000 Unicode characters; normalize Unicode NFC and trim; do not silently truncate financial input. User descriptions render as text, not HTML.

## Results and failures

Domain Result<T, DomainError> distinguishes validation, missingReference, archivedReference, conflict and overflow. Infrastructure mapping adds unauthenticated, forbidden, unavailable, rateLimited, storageFull, migrationFailed and incompatibleVersion. A backend error uses the envelope in [API contracts](05-API-CONTRACTS.md). Keep internal stack traces out of responses. Cancellation preserves the draft; a failed local atomic write must not show “saved.”

Refresh ID token once after an auth-expiry response; do not loop on revoked/disabled accounts. Retry safe GETs and idempotent operations only. An expired session blocks networking, not access to the previously authenticated local ledger. SQLite disk-full or migration failure enters recoverable read-only mode, with export if readable; never recreate the database silently.

## Configuration and environments

Validate backend environment at startup with a typed schema. AI-only misconfiguration disables AI routes but leaves sync available; broken Firebase credentials fail all data routes. Mobile dev/prod flavors carry public Firebase config and backend base URL via build defines; secrets remain server-side. Environment inventory and model release gates are in [deployment](12-DEPLOYMENT.md).

Use a single HTTP client per session; cancel requests and close the per-UID database on logout. Connectivity events are hints; test request outcomes. The domain never branches on provider name. Provider calls use explicit model IDs from environment, total request deadline and bounded output size. The direct Gemini/OpenRouter architecture does not require Vercel AI Gateway.

## Versioning

API major version is in /api/v1; each record has schemaVersion=1. Entity revision controls concurrency, not schemaVersion. Receipt requestHash uses recursively key-sorted canonical JSON of the complete immutable Operation, including confirmation but excluding transport tokens/requestId. confirmation.payloadHash hashes only the explicit command fields listed in the API contract. Arrays preserve order. Use UTF-8, no whitespace, canonical JSON string escapes and shortest safe integer representations; forbid negative zero and normalize strings before confirmation. Shared golden hash vectors must cover Unicode, nulls and dependency operations. Dart and TypeScript share golden JSON fixtures and rejection cases under docs/contracts during implementation; backend Zod schemas generate a versioned JSON Schema artifact, and CI runs identical fixtures against Dart validators. Generated contract files do not exist yet.

Additive responses are handled by explicit decoder compatibility rules; requests remain strict. New enum values require an API/schema capability update. Mobile encountering an unsupported record schema pauses sync without advancing the cursor and prompts upgrade. Drift migrations preserve outbox/shadows/cursors and are tested from every supported on-disk version. Backend supports the current and previous released API contract during mobile rollout.
