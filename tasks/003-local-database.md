# 003 — Local database and domain foundations

## Status

todo — specification ready; implementation not started.

## Goal

Build typed domain values and a durable Drift database with transactional outbox, shadows and migrations.

## Dependencies

- [001](./001-project-bootstrap.md) must meet its definition of done.

## Relevant docs

- [02-TECHNICAL-SPECIFICATION](../docs/02-TECHNICAL-SPECIFICATION.md)
- [04-DATA-MODEL](../docs/04-DATA-MODEL.md)
- [08-OFFLINE-SYNC](../docs/08-OFFLINE-SYNC.md)
- [10-TESTING-STRATEGY](../docs/10-TESTING-STRATEGY.md)

## Implementation scope

Modules/files: mobile/core/database, core/sync storage, shared domain values and repository interfaces.

- Implement every MVP entity table and supporting local record in data model, with keys/checks/indexes.
- Add integer-money/date/ID serialization, transaction union validators and cross-language golden fixture seeds.
- Implement atomic local command/outbox foundation, per-UID database lifecycle and versioned migration harness.

## Out of scope

Cloud sync transport, polished feature screens, model calls and production data migration.

## Acceptance criteria

- [ ] SQLite rejects invalid references/amount shapes and survives restart without losing pending operations.
- [ ] No REAL monetary column or writable Account balance exists.
- [ ] A failed atomic commit produces neither a partial ledger row nor an orphan outbox operation.

## Tests

**Automated:** Drift file-backed restart/rollback/migration tests, money/date boundary tests and independent reducer fixtures.

**Manual:** Inspect a synthetic database with accounts/opening/transfer fixtures; simulate disk/storage failure and verify no false Save success.

## Documentation updates

Update schema/index/migration details in data model and technical specification; document chosen SQLite native runtime.

## Definition of done

All acceptance criteria and required tests pass; relevant analysis/typecheck checks pass; changes preserve AGENTS.md invariants; documentation matches implemented behavior; evidence below contains actual commands and results. Mark blocked only with a specific prerequisite and retain completed work. Do not claim live/deployment tests passed when only fakes ran.

## Completion evidence

Not yet implemented. On completion record changed modules, commands/results, manual environment/build, limitations and reviewer/release gates where applicable.

