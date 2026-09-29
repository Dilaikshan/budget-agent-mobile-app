# Deployment and operations

This is a deployment specification. No cloud resource, secret, source project or release has been created by the documentation task. Implementation begins with task 001; production release requires the human review described in AGENTS.md.

## Environments

| Environment | Firebase | Vercel | AI/data |
|---|---|---|---|
| Local development | Auth and Firestore emulators; isolated dev project only for real auth/App Check tests | Local Node/Vercel development server | Fake adapters and synthetic fixtures by default |
| Preview | Dedicated development Firebase Spark project, never production | Preview deployment, backend root directory | Synthetic owner UID, fake adapters or capped dev keys; no cron schedule execution |
| Production personal | Separate production Firebase Spark project | Production deployment on a personal Hobby project | Configured owner UID, approved model IDs/privacy eligibility, capped inference |

Project names are operator-selected; suggested names `budget-agent-dev` and `budget-agent-prod` are not existing resources. Choose Firebase region once based on locality and service availability, then co-locate Vercel execution where supported and measure latency. Do not assume account-specific names/regions or link projects automatically. Android is the initial verified target; iOS requires macOS signing, Firebase config and real attestation testing before being advertised as supported.

## Configuration inventory

| Variable/config | Location | Requirement |
|---|---|---|
| APP_ENV | Backend + mobile public flavor | development, preview or production; reject ambiguous values |
| FIREBASE_PROJECT_ID | Backend | Explicit correct environment |
| FIREBASE_CLIENT_EMAIL, FIREBASE_PRIVATE_KEY | Backend secrets | Dedicated least-privilege service-account credentials; workload identity may replace when supported |
| OWNER_UID | Backend | Required allowlisted Firebase UID; never accepted from requests |
| ALLOWED_APP_IDS | Backend | Allowed App Check app IDs in the environment |
| GEMINI_API_KEY, GEMINI_MODEL | Backend secrets/config | Required for enabled primary inference; explicit reviewed model ID |
| OPENROUTER_API_KEY, OPENROUTER_MODEL | Backend secrets/config | Required when fallback enabled; explicit reviewed model/upstream allowlist |
| OPENROUTER_ALLOWED_PROVIDERS | Backend config | Approved upstream routing identities; fail if provider cannot enforce |
| AI_ENABLED, FALLBACK_ENABLED | Backend kill switches | Default false until credentials/privacy/smoke checks pass; user settings can further restrict |
| AI_PRIVACY_POLICY_VERSION, AI_PRIVACY_ELIGIBLE | Backend config | Recorded operator review plus per-user consent; no automatic eligibility assumption |
| AI_DAILY_ATTEMPT_LIMIT | Backend config | Default 100 shared attempts per UID/day |
| AI_DAILY_INPUT_TOKEN_LIMIT, AI_DAILY_OUTPUT_TOKEN_LIMIT | Backend config | Defaults 100000 and 20000; conservative reservations |
| CRON_SECRET | Backend secret | At least 32 random bytes; Authorization header only |
| CURSOR_SIGNING_KEY | Backend secret | At least 32 random bytes for insights pagination cursor integrity |
| FIRESTORE_EMULATOR_HOST, FIREBASE_AUTH_EMULATOR_HOST | Local/CI only | Must be absent in preview/production |
| Firebase platform config, API_BASE_URL | Mobile public flavor | No model/service-account/cron secrets; release URL must use HTTPS |
| App Check debug token | Development secret only | Never included in production artifacts/config |

NVIDIA_API_KEY is not required or provisioned for MVP. Runtime validation separates AI configuration from ledger/sync readiness. No production bypass flag for auth/App Check. Store placeholders only in .env.example, ignore actual local environment files and rotate leaked secrets immediately.

## Cron and execution budgets

Planned backend/vercel.json cron entry:

```json
{
  "crons": [{ "path": "/api/jobs/daily-agent", "schedule": "0 1 * * *" }]
}
```

Configure the function ceiling to 60 seconds using the syntax supported by the pinned Node runtime; application work stops at 45 seconds. The job uses a 90-second fenced lease and ≤50 items/20 provider attempts per invocation. No overnight resident process or queue dependency is required. Hobby cron is daily and has an hour-wide timing window; cron deliveries can repeat and function duration limits still apply. [Vercel cron management](https://vercel.com/docs/cron-jobs/manage-cron-jobs), [function limits](https://vercel.com/docs/functions/limitations).

Daily execution is best effort. Review partial runs/backlog and invoke the protected route manually for same-day recovery if needed. Preview does not execute production cron. Rolling back code does not automatically restore the previous cron configuration; inspect the active schedule after rollback. Do not use a secret query parameter or permit caching/redirects.

## Free-tier capacity

Firestore's published free allowance includes 1 GiB storage, 50,000 reads/day, 20,000 writes/day and 20,000 deletes/day; one free database per project. TTL, managed backups/PITR and restore features require billing. Recheck account quotas at release. [Firestore quotas](https://firebase.google.com/docs/firestore/quotas).

A transaction change writes canonical transaction, review state, operation receipt, Change and SyncState: approximately five writes before optional proposal/activity updates. At 100 financial changes/day this is roughly 500 base writes, plus agent and rate-limit metadata. Pull and rate counters also consume reads/writes. This is a planning estimate; measure actual emulator traces and console usage. Full-record change retention increases storage over time. Alert/review at 70% observed allowance; do not prune receipts/change history to recover space without a snapshot protocol.

Personal noncommercial use must remain eligible for Hobby; a commercial/public launch requires plan review. Model free tiers have separate limits and privacy terms; there is no zero-cost or availability guarantee. No Firebase Cloud Functions, Firebase Storage, managed Firestore backup, paid queue or n8n dependency is needed for MVP. If quotas exhaust, preserve pending Drift data and disable optional inference; do not silently enable billing.

## CI/CD and initial provisioning order

1. Pin toolchains/lockfiles, scaffold native Vercel Node functions and Flutter flavors, add ignored secret paths and synthetic fixtures.
2. Set up Auth/Firestore emulators and CI checks from testing strategy. Generate/validate shared schema fixtures. No cloud keys in pull-request logs.
3. Configure development Firebase auth providers, owner UID and app registrations; deploy deny-all client rules and required indexes before connecting app traffic.
4. Deploy backend preview with development credentials and fake provider mode. Verify health, authentication, sync CAS/replay and rate limits.
5. Configure real dev attestation and opt-in provider smoke tests. Record model/adapter versions and privacy approval evidence.
6. Build a signed release candidate against production public config, but release it only after task 018/019 gates and human review. Set separate production secrets in Vercel, never copy local .env blindly.
7. Deploy additive backend/rules/index changes before the mobile version that needs them; confirm indexes ready. Enable one cron schedule only after protected invocation and idempotency tests pass.

Planned CI gates: Dart formatting/analyze/unit/widget, backend typecheck/unit/contract, Drift migration fixtures, Firestore emulator/rules, secret/dependency scans and relevant device integration. PR previews use synthetic data. Production promotion is explicit, with build ID, schema/API versions and evidence recorded in release notes.

## Migrations and rollback

Drift uses numbered forward migrations tested against every supported database version, including outbox/shadow/cursor state. Create a user-approved recovery export before destructive changes; never delete/recreate a database as an upgrade shortcut. Firestore entity schema changes use additive fields/defaults first, compatible readers second, optional bounded backfill third. Backfills emit canonical revisions/Changes where user-visible state changes. Stop on incompatible data rather than advancing sync cursors.

Rollback backend to a previously tested contract-compatible deployment; pause AI with kill switches if the problem is inference-only. Older mobile builds must still understand current records or remain safely blocked from syncing. Never reverse ledger writes or restore old cloud state solely to match rolled-back code. A destructive schema change needs a separate reviewed recovery plan. Verify cron configuration independently after rollback.

## Backup and restore

Sync is not a backup. MVP supplies a local versioned export file containing UID, schemaVersion, export time, base currency, canonical records/shadows, pending operations/conflicts and lastAppliedSeq, plus SHA-256 integrity manifest. Exclude provider credentials, auth tokens and raw drafts. Use an explicit Save/Share flow; disclose that the file may be unencrypted and should be kept in a user-controlled protected location. Offer weekly export reminders in Settings without requiring a scheduler/service.

Restore first into a new isolated local database. Validate UID, schema, manifest, all references and ledger invariants; show record counts and balances for explicit confirmation before switching databases. Same-UID restore into an existing cloud namespace replays outbox opIds normally and pulls from its saved cursor; it never overwrites remote newer revisions. Existing operation receipts prevent duplicate effects. Rebuilding an entirely lost cloud namespace requires an operator-reviewed import with new sync epoch/snapshot design; MVP does not automate it. Keep the original export intact and rehearse same-UID local recovery before release.

## Release checklist

- All task dependencies and required automated/manual evidence pass; no financial/security invariant waived.
- Source contains no API keys; production app has no emulator/debug attestation configuration.
- Firebase verified-owner auth, real App Check and backend service-account access verified; direct Firestore client reads/writes fail.
- Offline save/restart, lost acknowledgement, conflicts, transfers and restore rehearsal pass on the reference device.
- Model IDs, provider terms, privacy eligibility, upstream routing and per-account quotas reviewed; opt-in/fallback behavior works.
- AI Activity and telemetry redact sensitive data; stale/partial insights are labeled.
- Cron secret/schedule/lease behavior verified; operator knows how to resume a partial run and check missed jobs.
- Export, migration, rollback and quota-outage instructions are usable; production human review is recorded.

Source links were consulted for architecture constraints; revalidate plan/account settings during task 019 because they can change independently of this specification.
