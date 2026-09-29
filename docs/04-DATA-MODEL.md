# Data model

This is the authoritative entity vocabulary. [API contracts](05-API-CONTRACTS.md) defines envelopes and [sync](08-OFFLINE-SYNC.md) defines replication. Entity payloads below use camelCase; persisted Drift columns use snake_case.

## Common types and ownership

Money is integer minor units with bounds in the technical specification. All references belong to the authenticated user's namespace. Domain models are immutable Dart values; Transaction is a discriminated union. Display balances and spending summaries are computed values, never writable entities.

Every replicated entity has: id:string, schemaVersion:1, revision:positive integer (remote; local new entity uses 0), createdAt:UTC instant, serverUpdatedAt:UTC instant, deletedAt:UTC instant|null. Server stamps times and revision. Each accepted change assigns a per-user sequence. Server fields are not accepted in client payloads. Local provisional timestamps are stored separately. Singleton profile/settings cannot be deleted.

Drift tables additionally contain user_id TEXT NOT NULL, local_version INTEGER, sync_status TEXT (synced|pending|syncing|conflict|blocked), local_created_at INTEGER and local_updated_at INTEGER. Primary key is (user_id,id); foreign keys include user_id. Per-UID databases are used in addition to this defense. All boolean columns are INTEGER constrained to 0/1. Enum columns have CHECK constraints. Required fields are NOT NULL; nullable fields are explicitly marked below.

## Entities

| Model / Drift table / Firestore collection | Payload fields beyond common metadata |
|---|---|
| UserProfile / user_profiles / profiles | id=profile; displayName:string; baseCurrency:string; currencyExponent:int; timeZone:IANA string; onboardingComplete:bool |
| Account / accounts / accounts | name:string; type:bank\|cash\|wallet\|savings; currency:string; archived:bool; sortOrder:int |
| IncomeSource / income_sources / income_sources | name:string; type:employer\|freelance\|business\|investment\|other; defaultAccountId:string|null; archived:bool |
| Category / categories / categories | name:string; type:income\|expense; parentId:string|null; icon:string|null; sortOrder:int; isSystem:bool; archived:bool |
| Transaction / transactions / transactions | Discriminated payload below |
| Transfer / derived view / no collection | Transaction where type=transfer; no independent persisted copy |
| CategorizationRule / categorization_rules / categorization_rules | matchKind:merchantExact\|keyword; normalizedPattern:string; transactionType:income\|expense; categoryId:string; suggestedAccountId:string|null; suggestedIncomeSourceId:string|null; priority:int; enabled:bool; origin:user\|acceptedSuggestion; evidenceTransactionIds:string[] (max 5) |
| Budget / budgets / budgets | month:YYYY-MM; categoryId:string; limitMinor:positive Money; currency:string |
| AIInsight / ai_insights / ai_insights | kind:dailySummary\|spendingTrend\|recurringPattern\|consistency; businessDate:date; title:string; summary:string; evidenceTransactionIds:string[] (max 20); facts:InsightFacts; sourceWatermark:int; status:active\|dismissed; agentRunId:string; stale:bool is computed locally/API, not a persisted payload field |
| AIActivity / ai_activity / ai_activity | agentRunId:string|null; agentType:AgentType; action:string; outcome:proposed\|applied\|skipped\|failed\|needsReview; summary:string; entityIds:string[] (max 20); proposalId:string|null; provider:string|null; model:string|null; correlationId:string |
| AgentRun / agent_runs / agent_runs | agentType:AgentType; businessDate:date|null; status:running\|partial\|succeeded\|failed\|skipped; startedAt:instant; endedAt:instant|null; attemptCount:int; transactionCount:int; ruleMatches:int; llmCalls:int; fallbackCount:int; manualReviewCount:int; inputTokens:int|null; outputTokens:int|null; latencyMs:int; errors:SafeError[]; providerAttempts:Attempt[] (max 20) |
| AppSettings / app_settings / app_settings | id=settings; theme:system\|light\|dark; aiEnabled:bool; dailyReviewEnabled:bool; learningEnabled:bool; fallbackEnabled:bool; privacyPolicyVersion:string|null; providerConsentAt:instant|null; defaultExpenseAccountId:string|null |

AgentType = transactionParsing|categorization|accountSuggestion|dailyReview|patternLearning|insight|recurringDetection|consistencyCheck. Logical roles may share one run and model call. No model identifiers/secrets are user-editable in settings. AgentRun errors and providerAttempts retain the latest 20 entries each; counters aggregate all attempts independently so resume never resets totals. Individual safe codes are at most 80 characters. Summaries are capped at 500 characters and names/titles at 80. Enforce the canonical record/change byte limits in the API contract for server outputs as well as client writes; split independent telemetry updates into separate Changes, never split financial compound operations.

InsightFacts = {periodStart:date,periodEndExclusive:date,currency:string,expenseMinor:int,incomeMinor:int,comparisonExpenseMinor:int|null,occurrenceCount:int|null,medianIntervalDays:int|null}. Numbers are computed from the ledger, not returned as authoritative LLM values. Unused fields are null. Summary/title caps are 500/80. SafeError={code:string,retryable:bool,attemptId:string|null}; no raw exception message. Attempt={attemptId:string,provider:string,model:string,status:success|failed|timeout|invalidOutput,latencyMs:int,inputTokens:int|null,outputTokens:int|null,errorCode:string|null,estimatedCostMicros:int|null}.

### Transaction payload

Shared fields: type:income|expense|transfer|opening, amountMinor:int, currency:string, accountId:string, destinationAccountId:string|null, incomeSourceId:string|null, categoryId:string|null, merchant:string|null, description:string, occurredAt:instant, effectiveDate:date, entryTimeZone:string, origin:manual|aiInput|opening, categorizationSource:manual|rule|ai|null, proposalId:string|null, openingDirection:credit|debit|null.

| Type | Rules |
|---|---|
| expense | amountMinor > 0; accountId funds expense; expense category or null; destinationAccountId/incomeSourceId/openingDirection null |
| income | amountMinor > 0; accountId is destination; income category and incomeSourceId required; destinationAccountId/openingDirection null |
| transfer | amountMinor > 0; accountId is source; destinationAccountId required and different; both same currency; categoryId/incomeSourceId/openingDirection null |
| opening | amountMinor >= 0; accountId required; openingDirection credit or debit; categoryId/incomeSourceId/destinationAccountId null; origin=opening |

Every stored Transaction is user-confirmed. Drafts/proposals are not Transaction rows. Review state is a separate AIProposal/ReviewState entity and never excludes a confirmed transaction from balances. Expense category null means uncategorized; income entry offers an explicit user-approved “Other income” category/source when unknown. `rawInput` stays in the local Draft only and is removed when the draft is discarded or 24 hours after save; it is never a Transaction field.

Exactly one opening Transaction per Account, including zero. ID is derived as SHA-256("opening:"+accountId). Account creation and opening are one operation group. Opening changes update that transaction with CAS and confirmation; arbitrary balance adjustments are deferred. Accounts are archived, not deleted; opening transactions cannot be deleted independently. Cash withdrawals/deposits produce one transfer row, not two expense/income rows. Transfer fees, if any, are separately confirmed expenses.

Category depth is at most two (root and child), same type across parent/child, no cycles. Expense may target root or child; reports roll descendants into parent once. Parent and child budgets may not coexist in the same month; enforce this uniqueness and nonoverlap transactionally. Category/source/account currency/type and category parent are immutable once referenced; archive/create new instead. Category name edits preserve historical references.

### Ledger mathematics

For non-tombstoned confirmed transactions T, let m(t)=amountMinor and d(t)=+1 for credit opening, -1 for debit opening:

```text
effect(t,a) = +m(t) if income and accountId=a
              -m(t) if expense and accountId=a
              -m(t) if transfer and accountId=a
              +m(t) if transfer and destinationAccountId=a
              d(t)*m(t) if opening and accountId=a
              0 otherwise
balance(a) = sum(effect(t,a), t in T)
netWorth = sum(balance(a), all accounts including archived)
income(period) = sum(m(t), income with effectiveDate in period)
expense(period) = sum(m(t), expense with effectiveDate in period)
budgetRemaining = limitMinor - expense(category subtree, month)
```

Opening transactions alter starting wealth but not income; transfers have sum(effect)=0. Deletion tombstones remove the original effect; editing replaces the old effect, never adds a second event. Remote immutable change history preserves prior versions for audit. Local pending/conflicted overlays affect the local balance once and are visibly marked; a conflict means the total may differ from the accepted remote replica until resolved.

## Supporting entities and metadata

| Record | Storage and fields |
|---|---|
| Draft | Local only: id, rawInput, candidateJson, createdAt, updatedAt, expiresAt |
| OutboxOperation | Local only: opId PK, entityType, entityId, action:create\|update\|delete\|createAccountWithOpening\|dismissInsight\|rejectProposal, baseRevision:int|null, payloadJson, requestHash, confirmationJson, localVersion, state, attempts, nextAttemptAt, dependsOnOpId:UUID|null, errorCode|null; dependency/revision exclusivity follows API contract |
| RemoteShadow | Local only: entityType+entityId key, revision, canonicalJson, deletedAt; pending overlays never overwrite this base |
| SyncCursor | Local only: lastAppliedSeq:int (initial 0), lastLedgerSeq:int (initial 0), pageWatermark:int|null, protocolVersion:1 |
| SyncConflict | Local only: opId, baseJson, proposedJson, serverJson, serverRevision, detectedAt; all retained until explicit resolution |
| AIProposal | Remote server-owned + local replica: kind:transaction\|categoryChange\|rule; candidateJson (validated union); targetId:null|string; targetRevision:null|int; confidence:number 0..1; fieldConfidence:map; questions:string[] max 5; evidenceIds:string[] max 5; status:pending\|accepted\|rejected\|stale; expiresAt:instant; agentRunId:string |
| ReviewState | Remote server-owned + local replica: id=transactionId; transactionRevision:int; state:queued\|reviewed\|needsReview; proposalId:string|null; reviewedAt:instant|null |
| OperationReceipt | Server only: opId, requestHash, acceptedChanges:[{entityType,id,revision,seq}], acceptedAt; permanent in MVP |
| Change | Server only: seq:int, ledgerChanged:bool, mutations:[{entityType,id,revision,record}], committedAt; immutable full canonical records including tombstones; one change per atomic group |
| SyncState | Server only: id=state, lastSeq:int, lastLedgerSeq:int; increment lastSeq in same transaction as Change; set lastLedgerSeq to that sequence only when confirmed ledger content changes |
| RunLease | Server only: id=runId, ownerAttemptId, fence:int, leaseUntil, cursor, sourceWatermark; no client writes |
| WorkReceipt | Server only: id=hash(transactionId,revision,agentPolicyVersion), status, proposalId|null, runId; same-transaction checkpoint |
| RateLimit | Server only: keyed UID+route+UTC window, count/reservedTokens; bounded app-level limits |
| AIRequest | Server only: UID+idempotencyKey, requestHash, state, responseJson|null, leaseUntil, expiresAt; replay cache for 24 hours |

CandidateJson uses the ParseCandidate in API contracts for transaction proposals; categoryChange={transactionId,baseRevision,categoryId:string|null}; a null category requires manual selection before acceptance. Rule candidate is the CategorizationRule payload. Local JSON columns for bounded structured metadata use TEXT with json_valid checks. Entity indexes, not arbitrary JSON search, support UI filters.

Rule suggestions can alternatively be reviewed and saved manually with evidenceTransactionIds, followed by rejecting the superseded suggestion; MVP uses this manual-copy flow rather than introducing an extra rule-accept API field. Therefore no rule proposalId is sent in sync Operation or CategorizationRule payload. Only Transaction payload carries proposalId for atomic financial proposal acceptance.

Primitive storage mapping: string/ID/date/enum → Drift TEXT and Firestore string; integer money/revision/count → Drift INTEGER and Firestore integer; boolean → constrained Drift INTEGER and Firestore boolean; UTC instant → Drift INTEGER milliseconds and Firestore Timestamp; bounded object/list → Drift JSON TEXT and Firestore map/array. Local-only columns never serialize. Computed values (balances, stale) do not persist remotely. Enable SQLite foreign_keys; apply owner-aware FKs to canonical reference columns, but proposal/evidence references may be historical or tombstoned and are validated by application services rather than cascading deletes.

Initialize SyncState with lastSeq=0,lastLedgerSeq=0 on the first accepted owner operation. A first pull against an uninitialized namespace returns an empty watermark-0 page. Create profile then settings then accepted seed/reference operations; missing required profile fails later financial writes with MISSING_REFERENCE. Onboarding can proceed locally with this same dependency order. Effective profile currency is locked by the first canonical opening transaction, checked under the per-user commit transaction.

## Firestore paths and indexes

All data is beneath `/users/{verifiedUid}/`. Collections use the names in the entity table plus `ai_proposals`, `review_states`, `operation_receipts`, `changes`, `sync_meta`, `run_leases`, `work_receipts`, `rate_limits`, `ai_requests`. Singleton paths are profiles/profile, app_settings/settings, sync_meta/state. Internal collections never enter the mobile change stream; AgentRun public snapshots omit lease/internal fields.

Remote user edits are supported for profile/account/source/category/transaction/rule/budget/settings only; insight dismissal and proposal rejection are narrow actions defined in API contracts. Agent writes go through a separate server service that emits changes too. Each ordinary accepted transaction create/update sets ReviewState queued atomically (except opening, which is reviewed without classification), making edits eligible for re-review. Confirmed category-proposal acceptance sets the new revision reviewed in the same commit to avoid suggesting it again immediately. Deleting a transaction tombstones its ReviewState in the same commit. Pending proposals are treated as stale if their target is deleted or their targetRevision differs, even before background cleanup updates their stored status.

Insight freshness is computed as any pending/conflicted local ledger operation OR lastLedgerSeq > insight.sourceWatermark; remote API uses the canonical lastLedgerSeq without local pending data. This conservative policy may mark an unaffected older period stale, but never labels outdated data current. Apply ledgerChanged Changes to update the local lastLedgerSeq atomically with the sync cursor. Metadata-only activity/dismissal/run Changes do not invalidate financial facts. Regenerating a stable-ID insight preserves an existing dismissed status.

| Query | Index |
|---|---|
| changes after sequence up to watermark | seq ascending |
| transactions in period | deletedAt ascending, effectiveDate ascending, document ID ascending |
| similar merchant transactions | merchant ascending, deletedAt ascending, effectiveDate descending |
| work queue | state ascending, reviewedAt ascending, document ID ascending on review_states; queued rows reviewedAt=null |
| rules enabled | enabled ascending, priority descending |
| activity/history | createdAt descending, document ID descending |
| agent runs by date | businessDate descending, startedAt descending |
| insights by business date/kind | businessDate descending, kind ascending |

Implement only indexes used by actual queries and store in firestore.indexes.json. Disable indexing raw payload maps, summaries, changes.mutations, responseJson and telemetry arrays. No unbounded collection-group scan is needed: cron uses configured owner UID. Drift indexes: transactions(effective_date,id), transactions(account_id,effective_date), transactions(destination_account_id,effective_date), transactions(category_id,effective_date), outbox(state,next_attempt_at), ai_activity(created_at,id); unique budget month/category and opening account ID constraints.

## Retention and recovery

Retain financial records, tombstones, operation receipts and immutable changes throughout MVP. This permits replay from sequence 0 and duplicate prevention after long offline periods. AI run/activity records retain 90 days, proposals 30 days after terminal state; daily bounded cleanup emits tombstones for replicated entities. Detailed prompts are not retained. Server-only short-lived cache/rate documents are explicitly deleted by bounded cleanup; no Spark TTL dependency. Future compaction requires snapshot/bootstrap protocol and a new ADR before pruning changes. See deployment for quota monitoring and backup.
