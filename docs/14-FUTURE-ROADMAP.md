# Future roadmap

Future work must preserve integer ledger arithmetic, explicit confirmation, local-first repositories and provider isolation. No item below is an MVP dependency or authorization to provision a service.

| Capability | Trigger and prerequisites | Approach and acceptance gate |
|---|---|---|
| Encrypted bank PDF extraction | MVP stable; reviewed storage/retention/key-management design | User-selected upload, encryption, malware/size checks, bounded extractor and deletion policy; parsed rows become proposals, never direct ledger writes |
| Bank statement reconciliation | Reliable ingestion and normalized reference identifiers | Match existing transactions with explainable confidence; handle duplicates, reversals, fees and statement periods; confirm every financial difference |
| n8n orchestration | A concrete integration needs orchestration beyond the current backend | Authenticate webhooks, scope credentials, idempotency and audit; do not make local entry depend on workflow uptime |
| Richer forecasting | Enough verified history and agreed evaluation metrics | Separate predictions from actual ledger; intervals, backtesting and coverage disclosures; no forecast-derived balance mutation |
| Recurring payment intelligence | Basic suggestion detector validated | User-managed recurrence templates and reminders; generated entries remain drafts until confirmed; handle skips/amount changes |
| General finance chat | Read/proposal tools and reliable factual evidence mature | Bounded tool loop, watermark/coverage, prompt-injection evaluation and no model-bound financial mutations |
| Additional providers including NVIDIA | A measured quality, cost or availability benefit | Implement existing adapter contract, schema/fallback/privacy tests, explicit operator enablement; no uncontrolled routing |
| Production billing migration | Sustained quotas, commercial use or stronger SLA needed | Measure costs first; add hard application budgets, operational alerts and approved paid plan; keep graceful offline failure |
| Firebase Blaze | Storage, managed recovery or Firebase-native functions genuinely justified | New cost/security ADR, budgets/alerts and rollback plan; not required just because Gemini billing changes |
| Multi-user/public release | Personal MVP proven and business/privacy requirements defined | Remove owner allowlist only after tenant authorization, abuse/load tests, privacy/deletion, support, region/consent and commercial-plan review |
| Multi-currency/liabilities | Concrete user need and domain redesign reviewed | Explicit FX legs/rates, currency-specific balances and liability semantics; never add unlike currencies into one total |
| Split transactions and adjustments | Proven need beyond original-entry correction | Versioned domain contracts, balanced splits and explicit reasons/confirmation; property tests before migration |
| Encrypted local database/biometric gate | Higher device threat model | Keychain/Keystore lifecycle, key loss/export recovery and migration rehearsal; disclose limitations |
| Change-log compaction and full erasure | Storage/replay growth or privacy requirements | Snapshot at a sequence watermark, sync epochs, cursor expiry/bootstrap and stale-op dedupe; never prune before protocol exists |
| Full cloud disaster recovery | Required recovery-time/data-loss target | Independently protected backups, verified restore into isolated project and sync-epoch handling; prove duplicate prevention before reconnecting old clients |

## Suggested progression

First stabilize personal usage and measure sync/model quality. Next choose one evidence-backed improvement: richer recurring review or forecasting if user value dominates, or backup/encryption if recovery risk dominates. Statement ingestion comes only after security/storage/duplicate reconciliation design. Public release is a distinct product phase with tenant and operations work, not merely removing OWNER_UID.

For every future feature, add an ADR, amend schemas/contracts and create implementation tasks before code. The initial 19-task backlog intentionally contains no PDF, n8n, NVIDIA, bank integration or general chat implementation.
