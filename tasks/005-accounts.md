# 005 — Accounts and opening balances

## Status

todo — specification ready; implementation not started.

## Goal

Implement asset-account management with ledger-derived balances and atomic opening entries.

## Dependencies

- [003](./003-local-database.md) must meet its definition of done.

## Relevant docs

- [04-DATA-MODEL](../docs/04-DATA-MODEL.md)
- [08-OFFLINE-SYNC](../docs/08-OFFLINE-SYNC.md)
- [09-UI-UX-DESIGN](../docs/09-UI-UX-DESIGN.md)
- [10-TESTING-STRATEGY](../docs/10-TESTING-STRATEGY.md)

## Implementation scope

Modules/files: mobile/features/accounts, ledger opening use cases and account DAOs.

- Create bank/cash/wallet/savings accounts with one derived-ID opening transaction, including zero.
- Implement signed opening editor and exact confirmation; account plus opening enqueue as one compound operation.
- Add rename/sort/archive and derived balance views; preserve archived accounts in total wealth.

## Out of scope

Credit liabilities, FX, mutable balance caches and deleting accounts with history.

## Acceptance criteria

- [ ] Exactly one opening exists per account and opening never enters income/expense reports.
- [ ] Opening changes replace the old effect with fresh confirmation and local-version checks.
- [ ] Archived accounts cannot fund new entries; negative balance warning does not block valid recording.

## Tests

**Automated:** Compound commit rollback, opening uniqueness/sign/zero cases, archive reference checks and balance query tests.

**Manual:** Create Bank/Cash, edit opening, archive account and verify total recorded balance remains correct.

## Documentation updates

Update account/opening UI and constraints in data model/UI docs when implementation details are settled.

## Definition of done

All acceptance criteria and required tests pass; relevant analysis/typecheck checks pass; changes preserve AGENTS.md invariants; documentation matches implemented behavior; evidence below contains actual commands and results. Mark blocked only with a specific prerequisite and retain completed work. Do not claim live/deployment tests passed when only fakes ran.

## Completion evidence

Not yet implemented. On completion record changed modules, commands/results, manual environment/build, limitations and reviewer/release gates where applicable.

