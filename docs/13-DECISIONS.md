# Architecture decisions and reconciliation

Status: accepted documentation baseline, completed 2026-09-29. Accepted means the implementation target is decided, not that it is implemented or deployed. Nonblocking operator choices are listed below. This document records why the original Word guidance was changed.

## Inputs inspected

The initial project contained only `budget_ai_agent_architecture_document.docx` and `budget_ai_agent_technical_document.docx`. Their paragraph/table text was extracted and read in full, including available supporting Word text parts. No application source or existing coding instructions were present initially. Both Word files remain unchanged as historical references. The user's pasted architecture/documentation request takes precedence over those inputs.

## ADR-01 — Flutter, Riverpod and go_router

**Context:** mobile entry needs shared UI behavior, testable state and route guards. **Decision:** Flutter with Riverpod dependency injection/state and go_router navigation. **Consequences:** Android first for verified MVP; iOS needs its own build/attestation validation. Domain logic stays pure Dart, separate from widgets and SDKs. Native double-entry banking integrations are outside scope.

## ADR-02 — Drift is the application-facing database

**Context:** financial recording must survive offline use and process death. **Decision:** Drift/SQLite repositories serve every screen; local writes and outbox are one transaction. **Consequences:** local projections/shadows/outbox require migrations and fault tests. Firestore cache is not a parallel ledger. Balance projections are disposable calculations, never authoritative writable values.

## ADR-03 — Firebase Spark with Vercel Hobby

**Context:** personal use should avoid unnecessary infrastructure/billing. **Decision:** Firebase Auth, Firestore, App Check and Crashlytics; Vercel TypeScript functions for sync/AI and daily cron. No required Cloud Functions or Firebase Storage. **Consequences:** quotas, best-effort cron timing and lack of managed free backups must be visible. Public/commercial scale triggers plan review; no free-tier guarantee.

## ADR-04 — Gemini primary, OpenRouter fallback

**Context:** primary availability must not define whether users can record transactions. **Decision:** direct provider adapters through Vercel AI SDK; configurable verified model IDs; rule-first routing and bounded eligible fallback. **Consequences:** provider terms and upstream capabilities must be reviewed, SDK versions pinned and failure paths tested. NVIDIA remains an optional future adapter. No Vercel AI Gateway requirement is introduced.

## ADR-05 — Integer money and one currency

**Context:** legacy schema stores REAL amounts/opening balances. **Decision:** integer minor units, strict bounds and one base currency per user, initially default LKR. **Consequences:** exact decimal parsing and cross-language fixtures required; FX/liabilities deferred. Account balances derive entirely from confirmed ledger entries. Opening balances are signed opening transactions, not an Account field. Zero opening is valid and unique per account.

## ADR-06 — AI proposals require financial confirmation

**Context:** legacy architecture permits automatic high-confidence categories/account suggestions and learning after any correction. **Decision:** all ledger changes, including category edits, require user confirmation; model registry excludes mutation commands. Rules activate only through an explicit “Remember” action. **Consequences:** daily jobs create proposals/review state/insights only. High confidence may preselect fields but cannot authorize writes. UI confirmation evidence is not proof against a malicious authenticated client.

## ADR-07 — Vercel-mediated revision sync

**Context:** legacy timestamp last-write-wins can lose financial edits; broad owner-write rules let clients spoof agent records. **Decision:** Drift → Sync Engine → Vercel → Firestore with CAS revisions, durable operation receipts and a per-user immutable change sequence. Direct Firestore SDK access denied. **Consequences:** Vercel availability affects sync, never local recording; backend scope validation is critical because Admin bypasses rules. Personal-user sequence serialization is intentionally simple and must be revisited for scale.

## ADR-08 — Atomic transfer and conflict semantics

**Context:** withdrawals/deposits must not inflate income or spending. **Decision:** one transfer Transaction with source/destination effects; first accepted server revision wins remote acceptance while competing local changes are retained for review. **Consequences:** no automatic financial field merge, timestamp winner or stale resurrection. Account/opening create is a compound commit. Deposited salary is income, not an own-account transfer.

## ADR-09 — Separate proposals, review state and ledger

**Context:** legacy Transaction.status combines suggested, needs_review and confirmed, risking exclusion of real expenses from balances. **Decision:** persisted Transactions are always confirmed; Draft/AIProposal/ReviewState are separate. **Consequences:** an uncategorized expense still affects balance. Income requires both category and IncomeSource; user can explicitly create/select “Other income.” General adjustments are deferred in favor of editing the original transaction or opening entry.

## ADR-10 — Bounded daily execution

**Context:** daily serverless work can repeat, overlap or time out. **Decision:** one protected GET `/api/jobs/daily-agent`, configured owner only, date run key, fenced lease, revision-bound item receipts and bounded work. Secret only in Authorization. **Consequences:** job may be partial; next day or operator invocation resumes work. Exactly-once model billing is not promised, but results/effects are idempotent. Hobby scheduling is not an exact local-time alarm.

## ADR-11 — Privacy gate and no client secrets

**Context:** personal financial data and unpaid model-provider terms may be incompatible. **Decision:** server-side keys only, minimized sanitized context, per-provider eligibility review and opt-in consent. **Consequences:** production AI stays disabled if terms do not permit the payload. A separately billed eligible Gemini project may be chosen without making Firebase Blaze an MVP dependency. Consent does not override provider restrictions; free fallback is not guaranteed.

## ADR-12 — Repository and contracts

**Context:** legacy tree uses apps/mobile and services/agent-api with unversioned endpoints. **Decision:** requested root mobile/backend/docs/tasks layout; native Node functions, versioned `/api/v1` user APIs and JSON fixtures shared across Dart/TypeScript. **Consequences:** no Next.js framework is required solely for APIs. Dependency versions are selected and pinned during bootstrap rather than invented in a source-free repository. Canonical schemas live in data/API docs until generated contracts exist.

## ADR-13 — Budgets and limited recurring intelligence

**Context:** source documents vary between MVP and future budgets/recurring detection. **Decision:** monthly category budgets and deterministic recurring-pattern suggestions are MVP; forecasting, rollover, automatic scheduled ledger creation and chat are deferred. **Consequences:** task 016 implements budgets explicitly, task 014 detects patterns, and neither changes balances automatically.

## ADR-14 — PDF, n8n and infrastructure expansion deferred

**Context:** source architecture mentions statement extraction and additional services. **Decision:** no PDF ingestion, storage, extraction endpoint, n8n or bank reconciliation dependency in MVP. **Consequences:** future encrypted ingestion uses the same normalized transaction/proposal boundary after a new security/storage ADR. No placeholder implementation or service provisioning now.

## ADR-15 — Retained history and local recovery

**Context:** long-offline devices require tombstones/receipts, and Spark lacks a free managed recovery path. **Decision:** retain immutable financial change history and receipts in MVP; provide explicit local export/restore. **Consequences:** storage grows and active AI-record retention is not complete erasure from historical Changes. Do not claim automatic encrypted backups or full cloud disaster recovery. Future compaction needs snapshots, sync epochs and an erasure policy.

## Conflict resolution register

| Legacy location | Conflict | Resolution / owning specification |
|---|---|---|
| Technical §2 | apps/mobile + services/agent-api layout | Root mobile/backend; technical specification |
| Technical §5, §10 | REAL money + mutable opening_balance | Integer amounts + opening Transaction; data model |
| Technical §7 | Recursive owner read/write permissions | Deny direct client access; security |
| Technical §8 | Latest updated_at wins; stale delete wins | CAS with preserved conflicts and durable sequence; sync |
| Architecture §10 | High-confidence auto category changes | Always confirm ledger changes; AI design |
| Technical §18 | `?secret=...` cron URL | Authorization Bearer secret; API/security |
| Architecture §7/§8 and Technical §11/§18 | Three daily route variants | GET /api/jobs/daily-agent; API |
| Architecture §14 | Fixed Gemini free quota assumption | Account/model verification and app budgets; deployment |
| Technical §16 | Client-submitted allowed reference lists | Server scoped canonical context; API |
| Technical §5/§21 | Suggested/review flags inside ledger status | Separate proposals/review state; data model |
| Technical §21 | Income source merely optional | Required source and category; data model |
| Technical §25 | Arbitrary adjustment in MVP | Opening correction/original transaction edit; product/data |
| Architecture §15 / Technical §24 | Recurring/budgets timing unclear | Limited detection + monthly budgets MVP; roadmap |
| Technical §11 | Next.js-shaped route tree | Native Node function routes; architecture/technical |

## Assumptions, risks and follow-up gates

| Item | Accepted baseline / mitigation | Revisit |
|---|---|---|
| Personal owner | One configured UID; same user may use multiple devices | Before public signup |
| Currency/timezone | User-confirmed LKR / Asia/Colombo defaults, currency fixed after opening | Before FX support |
| Offline identity | Initial online login; offline previously authenticated local use allowed | Before stricter shared-device policy |
| Device privacy | OS sandbox/encryption; SQLite not independently encrypted | Before high-risk device deployment |
| AI privacy/free availability | Eligibility gate, sanitized data and deterministic fallback | Task 011 and release |
| Sync gateway outage | Outbox preserves data; no forced cloud save | Pilot outage drills |
| Storage growth | Retained Changes/receipts, usage monitoring | 70% quota or long replay time |
| Cron misses/partial runs | In-app freshness and operator checks; no independent alert service | Need for reliable notifications |
| Exact runtime/model versions | Pin compatible stable versions with tests | Task 001/011 |
| Recovery limits | Same-UID local restore; full cloud rebuild is operator-designed | Before cloud disaster recovery automation |

No unanswered question blocks implementation of task 001. Actual project IDs, credentials, eligible model IDs and release device are operator configuration gates, not missing domain decisions. Paid activation and production deployment still require explicit human review.

## Documentation validation record

Validation completed 2026-09-29: 36 Markdown files comprise README, AGENTS.md, all 15 numbered specifications and 19 implementation tasks. All local Markdown links resolve, code fences are balanced, embedded JSON examples parse, every task contains the required sections and the dependency graph is acyclic with the documented execution order satisfying prerequisites. Mermaid blocks were structurally reviewed, not rendered by a Mermaid engine.

Cross-document review reconciled terminology, route names, task coverage, safe exceptions, schema ownership and deferred dependencies. Corrections made during review: immutable dependent offline operations now bind predecessor IDs without rewriting confirmed revisions; confirmation and receipt hashes have distinct explicit inputs; receipt replay uses original immutable Changes; insights derive staleness from ledger sequence rather than unbounded fan-out updates; opening creation is restricted to the atomic account operation; deletion/accepted-category review-state behavior is explicit. The full MVP requirement table maps to implementation tasks, including budgets, recovery and AI observability.

Application tests and deployed-platform verification remain implementation work; this documentation does not claim they have passed. The two original Word documents are retained and no application source was implemented. Platform documentation links support the design constraints; exact credentials/models/runtime compatibility remain release-time checks.
