# 018 — Security and privacy release gates

## Status

todo — specification ready; implementation not started.

## Goal

Verify implemented trust boundaries and remove release-blocking privacy/secret/abuse risks.

## Dependencies

- [017](./017-testing-hardening.md) must meet its definition of done.

## Relevant docs

- [05-API-CONTRACTS](../docs/05-API-CONTRACTS.md)
- [06-AI-AGENT-DESIGN](../docs/06-AI-AGENT-DESIGN.md)
- [07-SECURITY](../docs/07-SECURITY.md)
- [11-OBSERVABILITY](../docs/11-OBSERVABILITY.md)
- [12-DEPLOYMENT](../docs/12-DEPLOYMENT.md)
- [13-DECISIONS](../docs/13-DECISIONS.md)

## Implementation scope

Modules/files: backend guards/config/limits, Firebase rules/IAM setup, mobile release config and security test suites.

- Audit UID derivation/scoped Admin calls, owner/email/App Check enforcement and cron authorization.
- Verify release artifacts/secrets, least privilege, environment separation, provider eligibility and log redaction.
- Exercise replay, stale confirmation, prompt injection, budget exhaustion and revoked credentials; record findings/remediation.

## Out of scope

Public penetration-test certification, paid-service activation and changing confirmation boundaries to improve convenience.

## Acceptance criteria

- [ ] No cross-user/direct-client/admin-path bypass found; auth/attestation debug modes cannot ship.
- [ ] Model keys stay backend-only; provider routing/privacy review and opt-in states match actual config.
- [ ] No unresolved critical/high integrity or privacy finding remains; paid changes are separately approved.

## Tests

**Automated:** Negative authorization/App Check adapters/rules, request bounds/replay/budget races, dependency/secret/artifact scans.

**Manual:** Real release-device attestation, token revocation, environment/IAM review and privacy-copy review using synthetic data.

## Documentation updates

Record security evidence, residual risks and actual configuration requirements in security/deployment/decisions.

## Definition of done

All acceptance criteria and required tests pass; relevant analysis/typecheck checks pass; changes preserve AGENTS.md invariants; documentation matches implemented behavior; evidence below contains actual commands and results. Mark blocked only with a specific prerequisite and retain completed work. Do not claim live/deployment tests passed when only fakes ran.

## Completion evidence

Not yet implemented. On completion record changed modules, commands/results, manual environment/build, limitations and reviewer/release gates where applicable.

