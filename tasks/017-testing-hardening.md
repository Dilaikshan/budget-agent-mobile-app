# 017 — Regression, performance and recovery hardening

## Status

partial — unit/property/widget suites pass; export/restore NOT implemented (Settings shows 'Not available yet'); device accessibility/performance checks pending.

## Goal

Prove complete financial/sync behavior and implement safe versioned local export/restore.

## Dependencies

- [016](./016-insights.md) must meet its definition of done.

## Relevant docs

- [04-DATA-MODEL](../docs/04-DATA-MODEL.md)
- [07-SECURITY](../docs/07-SECURITY.md)
- [08-OFFLINE-SYNC](../docs/08-OFFLINE-SYNC.md)
- [09-UI-UX-DESIGN](../docs/09-UI-UX-DESIGN.md)
- [10-TESTING-STRATEGY](../docs/10-TESTING-STRATEGY.md)
- [12-DEPLOYMENT](../docs/12-DEPLOYMENT.md)

## Implementation scope

Modules/files: mobile export/restore/settings, mobile/backend integration/property suites and CI release checks.

- Implement sensitive-data export manifest and isolated same-UID restore validation without credentials/raw drafts.
- Complete crash-boundary/property/emulator/device scenarios; measure reference-device save/query latency.
- Fix accessibility, large-text, offline/error states and migration failures revealed by end-to-end tests.

## Out of scope

Managed cloud backup/PITR, full cloud namespace disaster recovery, database encryption and public load scaling.

## Acceptance criteria

- [ ] Restored balances/outbox/cursor match export and re-sync cannot duplicate accepted effects.
- [ ] All financial properties and full end-to-end scenarios pass; no test masks errors by deleting user data.
- [ ] Recorded device performance and accessibility evidence meets targets or documents a reviewed corrective action.

## Tests

**Automated:** Export corruption/UID/schema/reference rejection, migration matrix, randomized sync fault suite and complete CI regression.

**Manual:** Restore into an isolated database; airplane-mode restart, TalkBack/dark/200% text, low-storage and two-device conflict drills.

## Documentation updates

Record commands/results/device details and actual recovery steps in testing/deployment/UI docs.

## Definition of done

All acceptance criteria and required tests pass; relevant analysis/typecheck checks pass; changes preserve AGENTS.md invariants; documentation matches implemented behavior; evidence below contains actual commands and results. Mark blocked only with a specific prerequisite and retain completed work. Do not claim live/deployment tests passed when only fakes ran.

## Completion evidence

Not yet implemented. On completion record changed modules, commands/results, manual environment/build, limitations and reviewer/release gates where applicable.

