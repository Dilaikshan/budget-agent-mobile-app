# 014 — Idempotent daily review agent

## Status

implemented — owner-only cron, fenced 90 s lease, work receipts, bounded items/attempts/time, insights publishing; tests pass. Live cron run pending configuration.

## Goal

Run bounded server-side review, pattern detection and consistency checks with idempotent visible outputs.

## Dependencies

- [013](./013-ai-categorization.md) must meet its definition of done.
- [015](./015-ai-activity.md) must meet its definition of done.

## Relevant docs

- [04-DATA-MODEL](../docs/04-DATA-MODEL.md)
- [05-API-CONTRACTS](../docs/05-API-CONTRACTS.md)
- [06-AI-AGENT-DESIGN](../docs/06-AI-AGENT-DESIGN.md)
- [07-SECURITY](../docs/07-SECURITY.md)
- [10-TESTING-STRATEGY](../docs/10-TESTING-STRATEGY.md)
- [11-OBSERVABILITY](../docs/11-OBSERVABILITY.md)
- [12-DEPLOYMENT](../docs/12-DEPLOYMENT.md)

## Implementation scope

Modules/files: backend/api/jobs/daily-agent, daily coordinator/leases/work receipts and cron configuration.

- Implement secret-header route, configured owner scope, business-date run key and fenced lease takeover.
- Process queued revisions rules-first with bounded providers/deadline, per-item atomic receipt/activity/proposal checkpoints.
- Detect recurring/category patterns and ledger inconsistencies deterministically; retain partial backlog and stale revision safety.

## Out of scope

Hourly Hobby schedules, external workflow/queue services, automatic payments and production cron activation without review.

## Acceptance criteria

- [ ] Duplicate/concurrent jobs publish one result per item revision; expired workers cannot publish.
- [ ] Daily execution never edits confirmed ledger fields or creates recurring transactions.
- [ ] Partial runs resume safely; transfer/opening consistency checks do not invoke category inference.

## Tests

**Automated:** Duplicate jobs, lease fencing, timeout checkpoints, edited/deleted target races, provider failures and detector threshold tests.

**Manual:** Invoke protected dev job twice/concurrently, force a partial run and inspect resumed counts/Activity; verify bad secret rejection.

## Documentation updates

Record schedule/deadline/lease limits and recovery instructions in AI/deployment/observability docs.

## Definition of done

All acceptance criteria and required tests pass; relevant analysis/typecheck checks pass; changes preserve AGENTS.md invariants; documentation matches implemented behavior; evidence below contains actual commands and results. Mark blocked only with a specific prerequisite and retain completed work. Do not claim live/deployment tests passed when only fakes ran.

## Completion evidence

Not yet implemented. On completion record changed modules, commands/results, manual environment/build, limitations and reviewer/release gates where applicable.

