# 019 — Release preparation and operator handoff

## Status

todo — release preparation and human production review not started.

## Goal

Prepare a reproducible personal MVP release candidate and concrete human-review package.

## Dependencies

- [018](./018-security-hardening.md) must meet its definition of done.

## Relevant docs

- [00-PRODUCT-OVERVIEW](../docs/00-PRODUCT-OVERVIEW.md)
- [03-IMPLEMENTATION-PLAN](../docs/03-IMPLEMENTATION-PLAN.md)
- [10-TESTING-STRATEGY](../docs/10-TESTING-STRATEGY.md)
- [11-OBSERVABILITY](../docs/11-OBSERVABILITY.md)
- [12-DEPLOYMENT](../docs/12-DEPLOYMENT.md)
- [13-DECISIONS](../docs/13-DECISIONS.md)

## Implementation scope

Modules/files: release artifacts/config, CI/CD gates, deployment/rollback/export runbooks and task evidence.

- Run clean-checkout build and all release gates; record versions, fixture/model evaluation and device evidence.
- Verify production-intended config/secrets/project separation without silently deploying or enabling billing.
- Rehearse backup/restore/rollback and protected daily-job recovery; assemble release checklist and known limitations.

## Out of scope

Automatic production publishing, billing activation, public/multi-user release and deferred PDF/n8n features.

## Acceptance criteria

- [ ] Every prerequisite is done with evidence and no unsupported feature is advertised.
- [ ] Release artifact/config/rollback instructions are concrete and ready for human production approval.
- [ ] Quota/provider/privacy/cron/operator checks are documented; source docs distinguish implemented from deferred behavior.

## Tests

**Automated:** Full CI/typecheck/analysis/property/emulator/security/contract/migration suites and artifact secret scan on exact candidate.

**Manual:** Complete release E2E checklist, restore/rollback rehearsal, operator handoff and production smoke only after explicit approval.

## Documentation updates

Update README status, deployed versions only when actually released, final checklist/evidence and remaining roadmap.

## Definition of done

All acceptance criteria and required tests pass; relevant analysis/typecheck checks pass; changes preserve AGENTS.md invariants; documentation matches implemented behavior; evidence below contains actual commands and results. Mark blocked only with a specific prerequisite and retain completed work. Do not claim live/deployment tests passed when only fakes ran.

## Completion evidence

Not yet implemented. On completion record changed modules, commands/results, manual environment/build, limitations and reviewer/release gates where applicable.

