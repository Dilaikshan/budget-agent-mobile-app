# 009 — Mobile offline synchronization

## Status

implemented — pull/push/pull engine, receipt replay, conflicts keep/apply, blocked discard, cursor pause on unknown schema; tested against an in-test fake server. Two-real-device test pending.

## Goal

Connect durable local operations to the revision-checked backend without lost edits or duplicate effects.

## Dependencies

- [008](./008-transfers.md) must meet its definition of done.
- [010](./010-vercel-backend.md) must meet its definition of done.

## Relevant docs

- [02-TECHNICAL-SPECIFICATION](../docs/02-TECHNICAL-SPECIFICATION.md)
- [04-DATA-MODEL](../docs/04-DATA-MODEL.md)
- [05-API-CONTRACTS](../docs/05-API-CONTRACTS.md)
- [08-OFFLINE-SYNC](../docs/08-OFFLINE-SYNC.md)
- [09-UI-UX-DESIGN](../docs/09-UI-UX-DESIGN.md)
- [10-TESTING-STRATEGY](../docs/10-TESTING-STRATEGY.md)

## Implementation scope

Modules/files: mobile/core/sync, authenticated network client, remote shadows/cursors and conflict UI.

- Implement serialized pull-push-pull cycles, fixed-watermark pagination and dependency-ordered pushes.
- Handle receipts, later local overlays, tombstones, retries, UID/session changes and bootstrap from sequence zero.
- Implement conflict comparison and explicit keep-remote/reconfirm-local resolution; unknown schema blocks cursor.

## Out of scope

Direct Firestore mobile SDK persistence, timestamp LWW, change-log compaction and exact background scheduling.

## Acceptance criteria

- [ ] Lost acknowledgement/repeated pages never duplicate financial effect.
- [ ] Concurrent edits are retained as conflicts and never silently field-merged.
- [ ] Connectivity/background/auth failures preserve outbox; account/opening and transfer changes apply atomically.

## Tests

**Automated:** Complete sync fault matrix including process-kill boundaries, concurrent edits, stale deletes, dependent ops and token refresh.

**Manual:** Two devices plus airplane mode/restart, force conflict, resolve and converge; demonstrate backend/quota outage recovery.

## Documentation updates

Record implemented retry limits, wire examples and conflict flow in sync/API/UI docs.

## Definition of done

All acceptance criteria and required tests pass; relevant analysis/typecheck checks pass; changes preserve AGENTS.md invariants; documentation matches implemented behavior; evidence below contains actual commands and results. Mark blocked only with a specific prerequisite and retain completed work. Do not claim live/deployment tests passed when only fakes ran.

## Completion evidence

Not yet implemented. On completion record changed modules, commands/results, manual environment/build, limitations and reviewer/release gates where applicable.

