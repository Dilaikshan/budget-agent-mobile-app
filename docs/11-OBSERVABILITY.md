# Observability

## Three audiences

Mobile diagnostics explain crashes and local persistence/sync problems. Backend logs explain request and provider failures. AI Activity explains to the user what the agent proposed or did. These are distinct outputs with a shared correlation scheme, not raw prompt dumps.

All fields are allowlisted and redacted. Production logs exclude raw input, prompts/responses, account/source/merchant names, transaction descriptions, amounts, email, tokens and credentials. User-owned insight facts can contain amounts inside the protected database; they are never copied into operational logs.

## Correlation and events

Use requestId for HTTP, opId for durable sync, agentRunId for logical agent execution, attemptId for each provider call and proposalId for review. UID in infrastructure logs is a salted keyed hash, not the raw Firebase UID; do not use per-user high-cardinality labels in metric dimensions. A trace context may link these IDs without exposing financial content.

Mobile log events: local_save_started/committed/failed, migration_started/failed, sync_cycle_started/completed, outbox_retry, conflict_detected/resolved, auth_refresh_failed and draft_restored. Capture action code, duration, error code, schema/app version and pending count. Crashlytics receives sanitized fatal/nonfatal exceptions and breadcrumbs. Never attach SQLite files or full API payloads automatically.

Backend events: request_completed, authorization_denied, sync_operation_accepted/replayed/conflicted, provider_attempt_completed, daily_checkpoint, lease_takeover and quota_reservation_failed. Log duration/status/route/provider/model, schema/prompt version and safe error code. Store no authorization headers; sanitize exceptions at the adapter boundary.

## AgentRun and AI Activity

AgentRun fields in the data model are mandatory: agent type, start/end, status, transactions processed, rule matches, LLM calls, fallback count, providers/models, input/output tokens where known, latency, safe errors and manual review count. attemptCount counts job/request resumes; llmCalls counts actual attempted provider calls, including failures. FallbackCount counts OpenRouter attempts. Count each item once using WorkReceipt; record provider reservations separately so a crash does not incorrectly imply zero use.

Unknown tokens/cost are null, never zero. A run aggregate is null if any relevant attempt is unknown; detailed known attempts remain inspectable. estimatedCostMicros uses a dated model-price configuration and is an estimate, not an invoice. Application deadlines and possible provider charges after cancellation are reflected in safe errors.

AI Activity examples: “Category suggested; review required,” “Merchant rule supplied a suggestion,” “Daily review paused after provider failure,” “User accepted category proposal.” Only the last is applied to ledger metadata after explicit confirmation. Normal retries reuse deterministic activity IDs. Rule-only runs record llmCalls=0 and provider/model=null.

Public run snapshots replicate through the change feed. Private lease/counter/cache records stay server-only. If persistence of a required agent result/activity fails, do not report agent success; keep deterministic entry functional and record a backend failure if possible.

## Metrics and operating targets

| Metric | Initial action threshold |
|---|---|
| Local save latency p95 | >200 ms on reference device: inspect SQL/streams |
| Oldest pending sync age | >24h while device has foreground connectivity: show action banner |
| Conflict count | Any: expose resolution; repeated conflicts trigger protocol review |
| Sync 5xx | >5% of ≥20 requests over 15 min: inspect service/quota health |
| Interactive AI latency p95 | >20s: review provider/deadlines/context size |
| Fallback rate | >20% of ≥10 attempts/day: inspect Gemini availability/config |
| Structured-output rejection | >5% of ≥20 attempts: roll back prompt/model |
| Daily last successful completion | >36h: inspect cron and partial backlog |
| Provider budget reserve | ≥80%: reduce optional inference; at 100% skip calls |
| Firestore usage | ≥70% observed free allowance: investigate change-log and query growth |

These are design targets, not measured SLAs. Do not add a monitoring SaaS requirement: use Vercel logs/dashboard, Firebase usage/Crashlytics and an in-app diagnostics screen. Operator checks cron completion and quota dashboards daily during pilot; lack of an independent scheduler means a missing cron cannot reliably alert by itself. Automated external notification is a future operational choice, not an unimplemented guarantee.

## Retention and incident response

Keep detailed agent runs/activity 90 days, terminal proposals 30 days; immutable financial change audit and receipts remain throughout MVP. Use bounded explicit cleanup, no Firestore TTL dependency. Retained changes may contain prior versions of AI records after their current record is tombstoned; therefore 90 days is the active-record policy, not complete erasure. Full erasure/compaction needs a future snapshot protocol or explicit account-wide deletion. Inform the user in privacy/export documentation.

Incident procedure: identify request/run/op ID → inspect redacted logs and deployment/model versions → disable AI or pause sync if integrity is uncertain → preserve local outbox and export → reproduce with synthetic data → fix/review → verify invariant tests → resume. Never “repair” balances using an LLM or delete receipts to retry a job. Rotate credentials on exposure, revoke sessions as appropriate and document impact without copying private data into an issue.
