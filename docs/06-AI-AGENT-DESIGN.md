# AI agent design

## Responsibilities and orchestration

AI is a set of bounded responsibilities behind typed services. Transaction Parsing extracts candidate fields; Categorization and Account Suggestion enrich the same candidate. Daily Review coordinates pending work. Pattern Learning, Insight, Recurring Detection and Consistency Check mostly use deterministic analysis. These are logical roles, not eight separate prompts or deployments.

Interactive parsing uses at most one successful structured generation, with a second provider attempt only on eligible failure. Classification of a saved transaction never reparses or changes its amount/account. Daily analysis can summarize multiple findings in one call. Chat is a future read/proposal-only tool-loop consumer; it is not part of MVP endpoints.

## Rules before models

1. Normalize Unicode, whitespace and merchant spelling; parse explicit amounts/currency/date/account tokens deterministically. Do not infer decimal separators when ambiguous.
2. Apply enabled exact user merchant rules (descending priority, then stable ID) for matching transaction type. If equally ranked rules disagree, ask the user; do not choose arbitrarily.
3. Apply curated merchant/keyword mappings with token boundaries; exclude ambiguous transfer words unless accounts are resolved.
4. Inspect at most 20 recent same-type transactions from the last 90 days with matching normalized merchant. Require at least three confirmed matches and ≥90% category agreement for a history suggestion. Account history is only a suggestion, never a funding assumption that bypasses confirmation.
5. If required candidate fields are complete and unambiguous, return the proposal without an LLM call. Otherwise call the provider router when privacy, credentials and budgets permit.

Explicit text overrides learned suggestions for the current draft, but never silently creates new account/source/category IDs. An income with unknown source asks for selection or creation. “Deposit” without origin does not automatically mean transfer. Never infer that a purchase was paid from cash simply because no bank is named.

## Provider abstraction and selection

```text
ModelProvider.generateStructured(context, schema, limits)
  -> Result<{output,usage,provider,model,latencyMs}, ProviderError>
ProviderError = timeout|rateLimited|unavailable|invalidOutput|authError|refused
```

Gemini uses @ai-sdk/google and GEMINI_MODEL. OpenRouter uses its maintained AI SDK adapter and OPENROUTER_MODEL with an approved upstream provider allowlist; do not permit uncontrolled fallback to a different privacy policy. Pin adapter peer compatibility. Optional NVIDIA is an unimplemented future adapter behind this same interface, disabled and without a required key.

Select an explicit stable low-cost model supporting structured JSON and the required language, measured against golden cases. Model IDs and quotas must be checked against the operator's actual provider account during task 011; do not embed the legacy 15 RPM/250k TPM/500 RPD assumptions. No “latest” aliases or free-model availability guarantee. Gemini remains primary; OpenRouter is attempted only when permitted and necessary. [Gemini rate limits](https://ai.google.dev/gemini-api/docs/rate-limits) vary by model/tier; [OpenRouter adapter](https://github.com/OpenRouterTeam/ai-sdk-provider) supplies the SDK integration.

Request budget: interactive total 25 seconds; Gemini attempt ≤10 seconds, OpenRouter attempt ≤10 seconds, remaining time reserved for validation/persistence. Disable SDK automatic retries (maxRetries=0 where supported) to avoid hidden multiplication. Retry policy is one primary attempt and one eligible fallback, not a nested retry loop. Timeout/network/429/5xx/invalid structured output may fall back; validation errors in client input, explicit model safety refusals and privacy ineligibility do not. A primary auth misconfiguration records an operational error; an independently valid eligible fallback may serve the request. If fallback also fails, preserve manual flow.

Every call has an AbortSignal/deadline and output cap 1500 tokens. Minimized prompt target ≤4000 input tokens (use provider tokenizer where available or conservative estimator); no full-ledger prompts. Per-UID daily reserved token budget defaults 100,000 input + 20,000 output tokens and 100 provider attempts, shared across routes/jobs. Reserve worst-case tokens before call and reconcile known actual usage after; missing usage retains the reservation conservatively. If reservation fails, do not call. Provider dashboard spend caps remain necessary because timeout charges and token estimates are imperfect.

## Structured output and confidence

Use the API ParseCandidate and category-change schemas as the output contract; unknown values must be null. Runtime schema validation follows model output even when provider structured mode succeeds. Check integer bounds, valid currency/date, allowed UID-scoped IDs, type/category compatibility and distinct transfer accounts. Financial domain validation happens again on user confirmation.

fieldConfidence and overall confidence are advisory, not calibrated probabilities. Clamp nothing silently: out-of-range values invalidate output. Thresholds: ≥0.90 can preselect a suggested field; 0.60–0.89 highlight uncertainty; <0.60 leaves ambiguous selectors unset and adds questions. Missing mandatory fields always block Save until supplied. High confidence never authorizes a mutation, including category changes to existing transactions.

Prompt versioning: `parse-v1`, `classify-v1`, `daily-summary-v1`, plus agentPolicyVersion governing deterministic rules. Record prompt version, schema version and model ID per attempt; commit prompts with golden tests. A prompt contains role/task, immutable safety constraints, delimited untrusted input, allowed enum/ID vocabulary and null/ambiguity examples. User text or merchant names that say “ignore instructions” remain untrusted data.

Do not expose chain-of-thought. Store a short validated explanation based on rule/evidence identifiers. Context uses neutral account aliases (A1/A2), category labels and sanitized merchant tokens; map aliases back server-side. Remove names, account numbers, email, addresses and free-form sensitive notes. Reject/redact sensitive input before external inference; see the privacy gate in [security](07-SECURITY.md).

## Tool registry and safety levels

Tools receive server-created AuthContext; input schemas never contain UID. Query limits are hardcoded, no SQL/path parameters, no arbitrary URL/network/filesystem tools. Tool output is bounded typed data. Calculations use the domain ledger service.

| Level | Tool | Input → output and restrictions |
|---|---|---|
| Read | getAccounts | {} → active account IDs/aliases/currency; maximum 50 |
| Read | getAccountBalance | accountId → integer balance + watermark |
| Read | getCategories | type → valid category tree; max 200 |
| Read | getIncomeSources | {} → source IDs/aliases; max 100 |
| Read | getRecentTransactions | from,to,limit≤20 → minimized rows; period≤90 days |
| Read | getMonthlySummary | month → deterministic income/expense/opening-excluded totals |
| Read | getCategorySpending | categoryId,month → subtree expense total without double count |
| Read | findSimilarTransactions | merchantToken,type,limit≤20 → confirmed examples |
| Proposal | proposeExpense | candidate expense → AIProposal; no ledger row |
| Proposal | proposeIncome | candidate income → AIProposal; no ledger row |
| Proposal | proposeTransfer | source/destination candidate → AIProposal; no ledger row |
| Proposal | proposeCategoryChange | transactionId,revision,categoryId → bound AIProposal |
| Proposal | createInsight | validated facts+summary → AIInsight; fact values originate in code |
| Proposal | createAIActivity | validated action/evidence → AIActivity; no arbitrary metadata blobs |
| Mutation | createTransaction | confirmed normalized payload → local ledger/outbox |
| Mutation | updateTransaction | id,version,confirmed payload → local ledger/outbox |
| Mutation | deleteTransaction | id,version,confirmation → local tombstone/outbox |
| Mutation | executeTransfer | confirmed transfer → same transaction create service |
| Mutation | changeOpeningBalance | opening ID,version,confirmed amount → update service |

MVP model calls do not need a free-running tool loop: services gather context and validate output. Read/proposal tools are reusable typed application functions; only future chat may bind them to a bounded ToolLoopAgent after SDK verification. Financial mutation tools are mobile application commands, **never registered with a model**. Sync backend commits authenticated confirmed commands deterministically. Naming them “tools” does not grant the model access.

Safe exceptions without per-action confirmation: create/update AI proposals, AI Activity, AgentRun, ReviewState and computed insights; update server telemetry/work receipts. None changes a confirmed transaction or balance. Learned rules are activated only after the user taps “Remember this mapping”; even active rules merely prefill future proposals. There are no automatic financial mutation exceptions.

## Learned categorization

After a user corrects and saves a category, offer a separate “Remember merchant → category” action. Confirmation saves an exact merchant rule with transaction type and evidence ID. Account/source suggestions are opt-in fields. Pattern Learning can propose the same mapping after three consistent confirmed examples; it cannot activate it. No rule is learned from unaccepted AI output. Users can inspect, disable, edit and delete rules offline; syncing follows normal revisions. A contradictory correction offers rule revision rather than secretly changing it.

Merchant normalization uses lowercase Unicode NFC, whitespace collapse and explicit user aliases; do not erase all digits indiscriminately. Keyword rules match complete tokens; more general patterns have lower priority. Usage counters, if added, belong in server analytics rather than mutating the user rule on every read.

## Daily agent algorithm

One Vercel Cron GET per day, schedule `0 1 * * *` UTC (roughly morning in Asia/Colombo). Hobby execution may occur within the scheduled hour; never promise exact local delivery. Use the profile timezone to derive businessDate from server time. Target configured OWNER_UID only, no public user enumeration. Run key=SHA256(uid+businessDate+"daily-v1"). Policy changes do not automatically create a second daily run.

The job is bounded to 50 queued ReviewState items, 20 provider attempts, 45 seconds of application work and a 60-second configured function ceiling. Stop starting new model calls when insufficient deadline remains. A RunLease expires after 90 seconds and carries a monotonically increasing fence on takeover. Every checkpoint verifies ownerAttemptId/fence; a slow expired worker cannot publish outputs after a successor acquires the lease. LLM calls may be duplicated after a crash, but financial effects and published item results must not duplicate.

```text
verifyCronSecret()
uid = configuredOwnerUid
if !settings.dailyReviewEnabled: return skipped
runId = hash(uid, businessDate, "daily-v1")
lease = transaction(acquireOrResume(runId))
if runSucceeded or activeOtherLease: return storedStatus
while withinDeadlineAndBudget:
  item = nextQueuedItem(limitRemaining) // deterministic document-ID order
  tx = loadCurrentConfirmedTransaction(item.id)
  key = hash(tx.id, tx.revision, agentPolicyVersion)
  if workReceiptExists(key): reconcileReviewStateAndContinue
  candidate = deterministicRules(tx)
  if needsModel(candidate) and privacyEligible: candidate = boundedRouter(tx)
  transaction:
    verifyLeaseFence(lease)
    verify transaction revision still equals tx.revision
    if changed: leave queued for new revision; discard stale candidate
    else:
      create proposal if useful; otherwise mark reviewed/needsReview
      create one AIActivity and WorkReceipt(key)
      update ReviewState and run counters
      publish one Change for all visible records
  checkpointCursor()
derive bounded pattern and summary facts from accepted ledger
publish deterministic-key insights with sourceWatermark
complete run if no work remains, else mark partial with remaining=true
```

Queue cursor is a checkpoint hint, not permission to skip new lower-ID rows. Each invocation scans queued items from the beginning in stable ID order; processed items leave queued state atomically. needsReview items are not retried daily without a new transaction revision or user-requested classification. Failed provider work becomes needsReview with an error activity; invalid/new revisions remain queued. Next day's run drains remaining queued work; an operator may resume a partial run on the same date. No automatic cron retry guarantee or external scheduler dependency.

Opening/transfer entries receive deterministic consistency review only, never category classification. Check referenced accounts/currency and derived transfer effects; inconsistencies create alerts and do not repair balances. Recurring detection groups same normalized merchant and type over the last 90 days, requires ≥3 occurrences, median interval in weekly 5–9 or monthly 25–35 days and amounts within ±10% of median; produces a suggestion with examples, never automatic transactions. Period-based spending comparison uses complete periods only and states coverage; insufficient data yields no trend claim.

Daily summaries derive from up to 10,000 current transactions for the personal MVP in bounded pages. If the deadline/data cap prevents a complete calculation, publish no partial total as complete: mark run partial and show “summary unavailable.” Local summaries still work. Capture sourceWatermark=SyncState.lastSeq before reading and verify in the publishing transaction that lastLedgerSeq has not advanced beyond sourceWatermark. Concurrent ledger writes cause retry next run; unrelated telemetry does not. Later changes make insights stale by comparing ledger watermarks at read time, without unbounded fan-out writes. Insight ID=hash(kind,businessDate,scopeId,policyVersion); regeneration preserves dismissal. WorkReceipt IDs prevent duplicate per-transaction proposals. Summary narration, when used, may describe deterministic facts but cannot supply new amounts.

```mermaid
sequenceDiagram
  participant Cron
  participant Coordinator
  participant Firestore
  participant Router
  participant App
  Cron->>Coordinator: Authorized daily GET
  Coordinator->>Firestore: Acquire fenced run lease
  Coordinator->>Firestore: Load queued revision and scoped context
  Coordinator->>Router: Rules then optional structured generation
  Router-->>Coordinator: Valid proposal or failure
  Coordinator->>Firestore: Verify revision and fence; checkpoint once
  Note over App,Firestore: No direct access; App receives proposals through Vercel sync
  App->>App: User reviews and confirms local command
```

## Observability and failure behavior

Create AgentRun for every interactive request that reaches agent processing and every daily run; rule-only runs have zero LLM calls. Successful output and associated AI Activity persist atomically before returning success. If activity persistence fails, return unavailable and keep manual entry enabled. Authentication failures log redacted backend events, not user AI Activity.

Track counts, per-attempt provider/model, fallback, usage when available, latency, safe errors and manual-review count. Null usage is unknown, not zero. Record attempt reservations before model calls; crash-recovered usage may remain unknown. Idempotent HTTP request leases/cache prevent normal duplicate model calls; they cannot guarantee exactly-once provider billing after transport loss. See [observability](11-OBSERVABILITY.md).

Future chat must cap turns/tool steps, use the same read/proposal registry, include watermark/coverage with answers and persist separate user confirmations. No chat implementation or LLM-controlled sync credential exists in MVP.
