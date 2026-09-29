# 007 — Confirmed income and expense ledger

## Status

todo — specification ready; implementation not started.

## Goal

Deliver complete offline category-driven income/expense entry, history and deterministic reporting.

## Dependencies

- [004](./004-onboarding.md) must meet its definition of done.
- [005](./005-accounts.md) must meet its definition of done.
- [006](./006-categories-income-sources.md) must meet its definition of done.

## Relevant docs

- [02-TECHNICAL-SPECIFICATION](../docs/02-TECHNICAL-SPECIFICATION.md)
- [04-DATA-MODEL](../docs/04-DATA-MODEL.md)
- [08-OFFLINE-SYNC](../docs/08-OFFLINE-SYNC.md)
- [09-UI-UX-DESIGN](../docs/09-UI-UX-DESIGN.md)
- [10-TESTING-STRATEGY](../docs/10-TESTING-STRATEGY.md)

## Implementation scope

Modules/files: mobile/features/transactions, dashboard, confirmation components and ledger repositories.

- Implement shared normalized Draft/confirmation/command path with mandatory account and income category/source.
- Support uncategorized confirmed expenses, edits/tombstones and history filters.
- Calculate balances/month totals from ledger entries; enqueue immutable operations atomically and protect double-save.

## Out of scope

Provider integration, auto financial mutation, split/FX/general adjustment transactions.

## Acceptance criteria

- [ ] Expense affects exactly one funding account; income exactly one destination with required source/category.
- [ ] Create/edit/delete works offline and survives restart; every financial command requires exact confirmation.
- [ ] Reports exclude openings/transfers and do not exclude expenses awaiting categorization.

## Tests

**Automated:** Ledger reducer/property tests, typed payload fixtures, edit/delete effects, atomic outbox and double-submit widget tests.

**Manual:** Record salary and cash lunch, edit amount/account/date, delete and compare hand totals; repeat in airplane mode.

## Documentation updates

Update entry/history behavior and any clarified validation in data/UI/testing specs.

## Definition of done

All acceptance criteria and required tests pass; relevant analysis/typecheck checks pass; changes preserve AGENTS.md invariants; documentation matches implemented behavior; evidence below contains actual commands and results. Mark blocked only with a specific prerequisite and retain completed work. Do not claim live/deployment tests passed when only fakes ran.

## Completion evidence

Not yet implemented. On completion record changed modules, commands/results, manual environment/build, limitations and reviewer/release gates where applicable.

