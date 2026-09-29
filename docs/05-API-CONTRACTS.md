# API contracts

Contract version 1. These are implementation specifications, not deployed endpoints. Canonical entity payloads are in [data model](04-DATA-MODEL.md); schemas must implement their conditional constraints. All times/integers/IDs follow [technical conventions](02-TECHNICAL-SPECIFICATION.md).

## Transport, authentication and errors

HTTPS JSON, `Content-Type: application/json`, `Cache-Control: no-store`. Every /api/v1 route requires `Authorization: Bearer <Firebase ID token>` and `X-Firebase-AppCheck: <token>`, verified email, configured owner UID and correct project/audience. Never accept userId/uid anywhere in user request bodies. Agent routes additionally require aiEnabled and eligible provider consent. Job auth and health are separate below.

Success: `{ "data": <route payload>, "requestId": "opaque-id" }`.
Error: `{ "error": { "code": "VALIDATION_ERROR", "message": "Safe summary", "retryable": false, "fields": [{"path":"amountMinor","code":"INTEGER_REQUIRED"}] }, "requestId": "opaque-id" }`. fields may be empty. Request ID is server-generated, optionally correlated to a validated X-Client-Request-Id UUID. Never echo input in messages.

| HTTP | Codes | Client behavior |
|---|---|---|
| 400 | INVALID_JSON, UNKNOWN_FIELD, INVALID_CURSOR | Correct request; no automatic retry |
| 401 | UNAUTHENTICATED | Refresh once, then sign-in required |
| 403 | FORBIDDEN, EMAIL_UNVERIFIED, APP_CHECK_FAILED, AI_DISABLED, PRIVACY_NOT_ELIGIBLE | Resolve policy; manual ledger remains available |
| 404 | NOT_FOUND | Do not reveal other users' entities |
| 409 | REVISION_CONFLICT, IDEMPOTENCY_KEY_REUSED, REQUEST_IN_PROGRESS | Resolve conflict or retry same in-progress key after delay |
| 413 | PAYLOAD_TOO_LARGE | Reduce batch/input |
| 422 | VALIDATION_ERROR, MISSING_REFERENCE, ARCHIVED_REFERENCE, STALE_PROPOSAL, AMBIGUOUS_INPUT | Edit/confirm fields; do not guess |
| 429 | RATE_LIMITED, AI_BUDGET_EXHAUSTED | Respect Retry-After |
| 503 | SYNC_UNAVAILABLE, AI_UNAVAILABLE, JOB_UNAVAILABLE | Preserve local state and retry where appropriate |

Reject bodies >64 KiB except sync push ≤256 KiB. One canonical record is ≤16 KiB; change payload ≤64 KiB. UUIDs are opaque; examples below use labels for readability and fixtures must substitute valid UUIDs.

Rate limits are application defaults, not provider allowances: sync push 30 requests/minute/UID, pull 60/minute/UID, parse+classify combined 10/minute and 100/day/UID, insights 30/minute/UID. Reserve counters atomically in Firestore after auth and before model use. Duplicate accepted sync operations do not consume financial capacity; duplicate AI keys return cached output without another provider call. Request-rate limits may still apply. No process-memory-only limiter. Daily provider attempts share a 100/day/UID attempt budget with interactive calls, with at most 20 attempts reserved for a daily invocation; lower limits may be configured. See AI token budget.

## Endpoint inventory

| Method and path | Authentication | Request | Success data | Idempotency |
|---|---|---|---|---|
| POST /api/v1/sync/push | User headers | PushRequest | PushResponse | Required per-operation opId |
| GET /api/v1/sync/changes | User headers | afterSeq, watermark?, limit? | ChangePage | Read-only, immutable pages |
| POST /api/v1/agent/parse-transaction | User headers + AI eligibility | ParseRequest | ParseResponse | Idempotency-Key UUID required, 24h |
| POST /api/v1/agent/classify-transaction | User headers + AI eligibility | ClassifyRequest | ClassifyResponse | Idempotency-Key UUID required, 24h |
| GET /api/v1/agent/insights | User headers; reads allowed with AI off | from, to, cursor?, limit? | InsightPage | Read-only |
| GET /api/jobs/daily-agent | CRON_SECRET Bearer only | No body/query | JobResult | UID/date run + item receipts |
| GET /api/health | Public | None | {status:"ok",version:"1"} | Read-only |

No separate HTTP mutation tool endpoints: confirmed financial changes use sync push. No MVP chat route. Reserve POST /api/v2/agent/chat for future design; do not deploy a stub that claims functionality. Activity, proposals, run summaries, settings and budgets arrive through sync changes, avoiding duplicate CRUD routes.

### POST /api/v1/sync/push

```text
PushRequest = {operations: Operation[1..20]}
Operation = {
  opId: UUID, entityType: EntityType, entityId: ID,
  action: create|update|delete|createAccountWithOpening|dismissInsight|rejectProposal,
  baseRevision: integer>=0|null, dependsOnOpId:UUID|null, payload: EntityPayload|null,
  confirmation: Confirmation|null
}
Confirmation = {
  confirmedAt: UTC instant, payloadHash: SHA256 hex,
  expectedLocalVersion: integer>=1, predecessorOpId: UUID|null
}
PushResponse = {results: OperationResult[1..20]}
OperationResult =
  {opId,status:"accepted",changes:CanonicalMutation[],seq:int,replayed:bool}
  | {opId,status:"conflict",code:"REVISION_CONFLICT",current:CanonicalRecord|null}
  | {opId,status:"rejected",code:string,retryable:bool}
```

Process in order, with an individual Firestore transaction per operation; top-level HTTP 200 can contain partial failure. Whole-request guard failure uses standard error status. A same-entity dependent operation has dependsOnOpId set and baseRevision=null; the server resolves its expected revision from the predecessor receipt's acceptedChanges for that entity. Missing/unaccepted predecessor returns DEPENDENCY_FAILED. No dependency means baseRevision is an explicit integer. The resolved revision must still match the current entity. Dependency chains are bounded to the submitted/persisted receipts, cannot be cyclic and never select a different UID. A receipt is created only on success. Receipt replay returns original canonical records from its immutable Change at seq, never the entity's newer current version. Revision conflicts include only the caller's current record. Validate all schemas before processing a batch so malformed input does not partly execute.

EntityType = profile|account|incomeSource|category|transaction|categorizationRule|budget|appSettings|aiInsight|aiProposal. create/update allowed for user-owned types through appSettings only, except Account create must use createAccountWithOpening and opening Transaction create is internal to that compound action. delete only non-opening transaction, categorizationRule and budget. Reference entities archive via update. AIInsight supports dismissInsight only ({status:"dismissed"}); AIProposal supports rejectProposal only ({status:"rejected"}). Server metadata cannot be supplied. Full replacement payload for update; no implicit null/merge semantics. Ordinary delete payload is null; compound/new entities require baseRevision=0 and dependsOnOpId=null.

createAccountWithOpening: entityType=account, entityId=account UUID, baseRevision=0, payload={account:AccountPayload, opening:{signedOpeningMinor:int,occurredAt:instant,effectiveDate:date,entryTimeZone:string}}. Server derives opening ID/direction/amount and atomically returns both records. No other multi-entity client operation is supported.

Confirmation is required for transaction/createAccountWithOpening and any action affecting an existing transaction, including category changes. Metadata Save actions also carry confirmation for audit consistency; dismiss/reject may omit it because they have no ledger effect. confirmation.payloadHash is SHA-256 of canonical JSON containing exactly {action,entityType,entityId,baseRevision,dependsOnOpId,payload}; confirmation.predecessorOpId must equal dependsOnOpId. Separately, the receipt requestHash hashes the complete immutable Operation including confirmation. Neither hash includes transport headers/requestId; there is no self-referential hash field in Operation. This proves payload consistency, **not cryptographic proof of a human gesture**; the trusted mobile flow owns gesture enforcement. Model tools never get an authenticated sync dispatcher. The backend verifies shape/hash, authorization, revisions, references and any proposal binding independently.

Transaction proposal acceptance sends the exact normalized transaction with proposalId. Server checks proposal belongs to UID, is pending/unexpired and targetRevision still matches; updates proposal status and review state atomically. If user edited the proposed fields, treat as manual correction and still record proposal reference/evidence; do not require matching the original suggested values. For expired/offline proposals the user can explicitly reconfirm as manual with proposalId=null. Confirmation cannot be silently replaced by a model-generated boolean.

Example abbreviated payload for an expense (wrap in an operation and include all null fields):

```json
{
  "type":"expense","amountMinor":250000,"currency":"LKR",
  "accountId":"cash-account-uuid","destinationAccountId":null,
  "incomeSourceId":null,"categoryId":"restaurant-category-uuid",
  "merchant":"KFC","description":"Lunch",
  "occurredAt":"2026-09-09T06:30:00.000Z","effectiveDate":"2026-09-09",
  "entryTimeZone":"Asia/Colombo","origin":"aiInput",
  "categorizationSource":"ai","proposalId":"proposal-id","openingDirection":null
}
```

### GET /api/v1/sync/changes

Query afterSeq integer≥0 required; limit default 100, range 1..100; watermark optional integer≥afterSeq. Reject watermark greater than current lastSeq. First page reads lastSeq as W. Return `{changes:Change[],nextAfterSeq:int,watermark:int,hasMore:bool}`. Change schema is in data model. Empty complete page sets nextAfterSeq=W. Sequence is not derived from timestamps. Example: `?afterSeq=120&watermark=180&limit=100`. Response includes only mobile-replicated records, including tombstones; internal changes are not assigned stream sequences by themselves.

### POST /api/v1/agent/parse-transaction

```text
ParseRequest = {
  draftId:UUID, rawInput:string(1..1000), referenceNow:instant,
  timeZone:IANA string, currency:ISO code
}
ParseCandidate = {
  intent:income|expense|transfer|unknown, amountMinor:int|null,
  currency:string, merchant:string|null, description:string,
  accountId:ID|null, destinationAccountId:ID|null,
  categoryId:ID|null, incomeSourceId:ID|null,
  occurredAt:instant|null,effectiveDate:date|null,entryTimeZone:string
}
ParseResponse = {
  proposalId:ID|null,candidate:ParseCandidate,
  confidence:number[0..1],fieldConfidence:map<string,number[0..1]>,
  questions:string[0..5],requiresConfirmation:true,
  source:rule|history|gemini|openrouter|manual,
  agentRunId:ID,sourceWatermark:int,expiresAt:instant|null
}
```

Server loads allowed references from UID-scoped canonical data; clients do not submit account/category lists. Input references not yet synced are resolved locally or require manual selection after parsing; no AI request waits on sync to enable manual Save. referenceNow interprets “today” only; it grants no write timestamp authority. Both date fields are validated for timezone consistency.

Example request: `{ "draftId":"draft-uuid", "rawInput":"lunch kfc 2500 cash", "referenceNow":"2026-09-09T08:00:00.000Z", "timeZone":"Asia/Colombo", "currency":"LKR" }`. Candidate amountMinor=250000, intent=expense; cash/category IDs resolve only if unambiguous. Unknown fields are null with questions. If all eligible providers fail, return 503 AI_UNAVAILABLE; retain draft and use local/manual entry. No fabricated partial success. Deterministic partial parse may return 200/source=manual with null fields and no proposalId.

### POST /api/v1/agent/classify-transaction

Request `{transactionId:ID,baseRevision:positive integer}`. Server loads canonical transaction; only income/expense accepted. Stale revision returns 409; missing/deleted target returns 404. Response `{proposalId:ID,candidate:{transactionId,baseRevision,categoryId:ID|null},confidence:number,questions:string[],requiresConfirmation:true,source:rule|history|gemini|openrouter|manual,agentRunId:ID,sourceWatermark:int,expiresAt:instant}`. Unknown category creates a review proposal with categoryId=null; acceptance requires user selection. Existing financial fields are never edited by classification.

Example request `{ "transactionId":"transaction-uuid", "baseRevision":3 }`; accepted suggestion references revision 3. If device edits to revision 4 before Save, proposal acceptance returns STALE_PROPOSAL and requests a fresh comparison.

### GET /api/v1/agent/insights

Query from/to dates (inclusive/exclusive), maximum span 366 days; limit 1..50 default 20; opaque cursor binds UID, range and last businessDate/id, signed by backend. Response `{items:AIInsight[],nextCursor:string|null,sourceWatermark:int}`. No LLM call is made by this read endpoint. Example `?from=2026-09-01&to=2026-10-01&limit=20`. UI normally uses Drift copies; this endpoint supports explicit remote refresh and diagnostics. Merge fetched items through the same revision-aware repository, never render a competing network-only list.

### GET /api/jobs/daily-agent

Authorization must equal Bearer CRON_SECRET, compared safely. No secret in query strings, no user token substitute. Targets configured OWNER_UID only and checks enabled settings. Rate: at most one active leased execution per UID, with same-day replay returning stored result. Response `{businessDate:date,runId:ID,status:running|partial|succeeded|failed|skipped,processed:int,remaining:bool,replayed:bool}`. Wrong secret 401; unavailable persistence 503; partial bounded progress 200. No guarantee Vercel retries failures. Operator may manually invoke the same route with secret; no extra retry service.

### GET /api/health

200 static status/version if process responds, no external calls or secrets/provider names. Platform/IP rate controls protect abuse; application target 60/minute/IP where supported without persisting IP addresses. This is liveness, not readiness; authenticated smoke tests establish Firebase/AI readiness separately.
