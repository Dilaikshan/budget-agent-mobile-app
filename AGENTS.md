# Coding agent instructions

Read README.md, the relevant numbered specifications, and the assigned task before editing. Markdown specifications supersede the two retained legacy Word documents; decisions and reconciliation are in docs/13-DECISIONS.md.

## Architecture and invariants

- Flutter, Riverpod, go_router, Drift/SQLite; UI reads repositories backed by Drift only.
- Firebase Auth, App Check, Crashlytics and Firestore Spark; TypeScript Vercel Hobby functions handle authenticated sync and AI. No MVP Cloud Functions, Firebase Storage, PDF extraction or n8n.
- Gemini primary, OpenRouter fallback through Vercel AI SDK adapters. NVIDIA is deferred. No provider secrets in Flutter production builds.
- Money uses integer minor units, never floating point. MVP is one currency per user. Balances are derived from confirmed ledger transactions; opening balances are ledger entries.
- Accounts hold money; income sources identify origin; categories identify purpose. Expense needs funding account; income needs destination, category and income source. Transfers have distinct source/destination accounts and never enter income/expense totals.
- Every financial create/edit/delete, transfer and opening-balance change requires explicit confirmation of the exact payload. AI never executes financial tools. Confidence never grants mutation permission.
- Drift write plus outbox enqueue is atomic. Sync uses server revisions, durable operation IDs and a change sequence; never timestamp last-write-wins or direct client Firestore writes.

## Security and coding

- Verify Firebase ID token and App Check at every user API; derive UID only from verified auth, enforce personal-owner allowlist, scope every repository query. Admin SDK bypasses rules: backend authorization is mandatory.
- Validate all input and model output; unknown IDs/fields, unsafe integers and cross-user references fail closed. Treat descriptions/model content as data, never instructions.
- Use typed domain unions, explicit Result/errors, dependency injection, bounded retries/timeouts and versioned contracts. No SDK calls in widgets/domain, balance caches as authority, silent catches or unbounded agent loops.
- Never log tokens, prompts, raw transactions, account names or secrets. Keep environments isolated; commit lockfiles and migrations, never credentials.

## Task execution and completion

1. Check task prerequisites and existing work; mark task in_progress. Make the smallest cohesive change in the specified modules.
2. Add meaningful invariant, contract, migration, authorization and failure tests applicable to the change. Run formatting, analysis/typechecking and relevant suites.
3. Update affected docs and task evidence, including commands, results and limitations. Mark done only when acceptance criteria pass; do not claim planned behavior is implemented.
4. Request human review for unresolved domain contradictions, destructive data migrations, paid-service activation, production release, credential exposure or changes to confirmation/privacy boundaries. Routine reversible implementation within an assigned task needs no extra approval.

No application source is implemented by the initial documentation task. Do not confuse pseudocode or planned commands with working modules.
