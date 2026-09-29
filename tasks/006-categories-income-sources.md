# 006 — Categories and income sources

## Status

implemented — two-level categories, default tree on acceptance, income sources, rules management.

## Goal

Keep money origin and spending purpose distinct through validated offline reference management.

## Dependencies

- [003](./003-local-database.md) must meet its definition of done.

## Relevant docs

- [00-PRODUCT-OVERVIEW](../docs/00-PRODUCT-OVERVIEW.md)
- [04-DATA-MODEL](../docs/04-DATA-MODEL.md)
- [09-UI-UX-DESIGN](../docs/09-UI-UX-DESIGN.md)
- [10-TESTING-STRATEGY](../docs/10-TESTING-STRATEGY.md)

## Implementation scope

Modules/files: mobile/features/categories, mobile/features/income_sources and local repositories.

- Implement two-level same-type category trees, accepted default seeds and category selectors.
- Implement sources with optional default-account suggestion, create/rename/archive and offline persistence.
- Enforce immutable referenced type/parent, no cycles and archived-reference restrictions.

## Out of scope

LLM auto-creation of references, arbitrary category depth and destructive reference deletion.

## Acceptance criteria

- [ ] IncomeSource never acts as an account or balance container.
- [ ] Category trees reject invalid depth/cycles/type mismatch; accepted seeds do not duplicate.
- [ ] Archived names remain readable in history but are excluded from new selection.

## Tests

**Automated:** Hierarchy/ownership/default-seed tests, archive/referenced-field validation and selector widget cases.

**Manual:** Create Employer and Freelance client separately from Salary/Freelance categories; rename/archive and inspect selectors.

## Documentation updates

Document default category/source behavior and reference lifecycle in data/UI specifications.

## Definition of done

All acceptance criteria and required tests pass; relevant analysis/typecheck checks pass; changes preserve AGENTS.md invariants; documentation matches implemented behavior; evidence below contains actual commands and results. Mark blocked only with a specific prerequisite and retain completed work. Do not claim live/deployment tests passed when only fakes ran.

## Completion evidence

Not yet implemented. On completion record changed modules, commands/results, manual environment/build, limitations and reviewer/release gates where applicable.

