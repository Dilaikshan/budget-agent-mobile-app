# Product overview

## Problem and differentiator

Personal tracking fails when recording takes too long, cash becomes invisible, and transfers inflate spending reports. Budget Agent reduces entry effort using AI while keeping balances predictable, available offline and explainable. AI supplies proposals and evidence; deterministic code owns the ledger.

The primary persona is one individual in Sri Lanka managing bank accounts, savings and cash, with salary and occasional freelance income. A secondary usage pattern is the same person using another device with intermittent connectivity. Shared households, public signup and financial institutions are outside the MVP.

## Goals and success criteria

- Both entry flows save the same validated domain transaction. A trained user can complete category entry in four decisions: category, amount, account, Save.
- Local confirmation-to-display target is under 200 ms on the reference Android device with 10,000 transactions; verify, do not assume.
- Every displayed balance can be traced to ledger entries; repeat delivery has zero additional financial effect.
- Offline entry, edit and tombstone delete work after initial sign-in/onboarding. No model or network response is needed to save manually.
- AI proposals expose uncertainty, supporting transaction references and activity history. A failed daily job leaves ledger data unchanged.

## MVP requirements and coverage

| ID | Requirement | Tasks |
|---|---|---|
| F01 | Google/email-password auth, verification, isolation and settings | 002, 018 |
| F02 | Onboard accounts, transfers, sources, categories, opening balances and AI privacy | 004–006 |
| F03 | Income with source/category/destination; expense with funding account | 007 |
| F04 | Transfer, withdrawal and deposit with no income/expense effect | 008 |
| F05 | Offline entry/edit/delete, conflict review and eventual sync | 003, 009, 010 |
| F06 | Natural-language parse, account/source/category suggestion and confirmation | 011, 012 |
| F07 | Rules from explicitly accepted corrections; rule management | 013 |
| F08 | Daily review, pattern/recurring detection and consistency checks | 014 |
| F09 | AI Activity, run telemetry, low-confidence review queue | 015 |
| F10 | Deterministic monthly category budgets, spending insights and trends | 016 |
| F11 | Accessible light/dark UI, history filters, empty/error/offline states | 001, 004–009, 012, 015, 016 |
| F12 | Backup/export, recovery, security and release verification | 017–019 |

## AI-first experience

Quick entry is available from every main screen. A local rules pass supplies immediate candidate fields; online AI resolves ambiguity with a single combined call where needed. Users see editable proposals, field confidence and “why suggested.” Daily review appears as an unobtrusive card and review count, with an AI Activity trail. Pattern learning proposes reusable merchant/category mappings. Recurring detection suggests a pattern, never schedules automatic payments or creates ledger entries.

AI capability is visible even when unavailable: show “Offline suggestions” or “AI unavailable — enter details” and preserve the input. Categorization after saving remains a proposal until confirmed, including high-confidence suggestions. An uncategorized expense is a valid confirmed ledger transaction whose review state is separate from financial status.

## Domain vocabulary and scope

Account = where money exists; IncomeSource = where income originated; Category = purpose. A withdrawal is bank → cash; a deposit is cash/account → another account. These are transfers only when money moves between the user's own accounts; salary deposited by an employer is income. Ambiguous language requires clarification.

Opening balance is a signed opening transaction, excluded from income/expense. MVP supports asset accounts and one user-selected currency (default LKR) with a fixed exponent. Negative balances are allowed with a warning because recorded overdrafts must remain representable. Credit liabilities, FX, tax advice, investment recommendations, bank connectivity, arbitrary adjustment entries, splitting transactions and predictive chat are out of scope.

Monthly budgets have explicit month/category limits and no rollover. Insights summarize observed spending, not financial advice. Initial sign-in requires connectivity; ongoing use does not. Personal financial AI sharing is opt-in with provider eligibility checks; deterministic functionality is always available.

## Future scope

See [roadmap](14-FUTURE-ROADMAP.md) for encrypted bank PDF extraction, reconciliation, n8n, forecasting, richer recurring intelligence, optional NVIDIA, chat, paid infrastructure and a public release. None are MVP prerequisites.
