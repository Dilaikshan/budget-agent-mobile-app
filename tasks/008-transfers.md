# 008 — Transfers, withdrawals and deposits

## Status

implemented — single-row transfers, swap, distinct accounts enforced on client and server.

## Goal

Represent own-account money movement as one atomic transfer with zero net-worth/report distortion.

## Dependencies

- [007](./007-transactions.md) must meet its definition of done.

## Relevant docs

- [00-PRODUCT-OVERVIEW](../docs/00-PRODUCT-OVERVIEW.md)
- [04-DATA-MODEL](../docs/04-DATA-MODEL.md)
- [08-OFFLINE-SYNC](../docs/08-OFFLINE-SYNC.md)
- [09-UI-UX-DESIGN](../docs/09-UI-UX-DESIGN.md)
- [10-TESTING-STRATEGY](../docs/10-TESTING-STRATEGY.md)

## Implementation scope

Modules/files: mobile/features/transfers, shared ledger validator/projector and transfer confirmation UI.

- Implement source/destination selection, amount/date and explicit confirmation using Transaction type=transfer.
- Reuse the same transaction persistence/outbox path; support edit/delete as replacement/removal.
- Explain withdrawals/deposits versus incoming employer payments and separately confirmed fees.

## Out of scope

External payments, bank execution, FX transfers and automatically inferred fees.

## Acceptance criteria

- [ ] Source and destination are distinct same-currency accounts.
- [ ] Transfer reduces source and increases destination equally; income/expense remain unchanged.
- [ ] No half-transfer or independent duplicate transfer entity is persisted.

## Tests

**Automated:** Random transfer conservation tests, same-account/currency rejection, atomic failure/restart and edit/delete properties.

**Manual:** Bank→Cash withdrawal, Cash→Bank deposit, bank-to-bank transfer and reversal by edit/delete; compare all totals.

## Documentation updates

Update transfer UX examples and invariant test evidence in data/UI/testing docs.

## Definition of done

All acceptance criteria and required tests pass; relevant analysis/typecheck checks pass; changes preserve AGENTS.md invariants; documentation matches implemented behavior; evidence below contains actual commands and results. Mark blocked only with a specific prerequisite and retain completed work. Do not claim live/deployment tests passed when only fakes ran.

## Completion evidence

Not yet implemented. On completion record changed modules, commands/results, manual environment/build, limitations and reviewer/release gates where applicable.

