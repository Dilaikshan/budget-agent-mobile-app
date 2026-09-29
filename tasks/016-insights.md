# 016 — Budgets and evidence-based insights

## Status

implemented — monthly budgets with subtree spend and overlap rules, deterministic summaries/trends/recurring insights with staleness.

## Goal

Deliver monthly category budgets and explainable spending/recurring insights backed by deterministic facts.

## Dependencies

- [014](./014-daily-agent.md) must meet its definition of done.

## Relevant docs

- [00-PRODUCT-OVERVIEW](../docs/00-PRODUCT-OVERVIEW.md)
- [04-DATA-MODEL](../docs/04-DATA-MODEL.md)
- [05-API-CONTRACTS](../docs/05-API-CONTRACTS.md)
- [06-AI-AGENT-DESIGN](../docs/06-AI-AGENT-DESIGN.md)
- [09-UI-UX-DESIGN](../docs/09-UI-UX-DESIGN.md)
- [10-TESTING-STRATEGY](../docs/10-TESTING-STRATEGY.md)
- [11-OBSERVABILITY](../docs/11-OBSERVABILITY.md)

## Implementation scope

Modules/files: mobile/features/budgets/insights/dashboard, backend insight facts/persistence and GET insights route.

- Implement budget CRUD, nonoverlapping parent/child constraints and local monthly spend/remaining queries.
- Generate bounded complete-period facts and stable-ID insight summaries from daily analysis.
- Implement revision-aware insight refresh, dismissal, coverage/staleness and evidence navigation.

## Out of scope

Forecasting, budget rollover, automatic recurring entries and investment/tax advice.

## Acceptance criteria

- [ ] Transfers/openings never consume budget; category descendants are counted once.
- [ ] Incomplete or concurrently invalidated remote summaries never appear as complete/current facts.
- [ ] Recurring insights remain suggestions and every number is traceable to ledger computation.

## Tests

**Automated:** Budget uniqueness/hierarchy/concurrency tests, independent period totals, watermark/stale behavior, pagination and dismissal tests.

**Manual:** Create/edit/delete monthly budgets, cross month boundary, inspect pending/stale data and recurring evidence.

## Documentation updates

Update exact fact/coverage presentation and budget behavior in product/data/API/UI docs.

## Definition of done

All acceptance criteria and required tests pass; relevant analysis/typecheck checks pass; changes preserve AGENTS.md invariants; documentation matches implemented behavior; evidence below contains actual commands and results. Mark blocked only with a specific prerequisite and retain completed work. Do not claim live/deployment tests passed when only fakes ran.

## Completion evidence

Not yet implemented. On completion record changed modules, commands/results, manual environment/build, limitations and reviewer/release gates where applicable.

