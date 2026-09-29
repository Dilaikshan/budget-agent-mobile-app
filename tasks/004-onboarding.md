# 004 — Guided onboarding

## Status

implemented — resumable six-step onboarding with confirmations; widget tests pass. Manual device run pending.

## Goal

Guide the user through accounts, sources, categories, transfers, opening balances and informed AI preferences.

## Dependencies

- [002](./002-authentication.md) must meet its definition of done.
- [003](./003-local-database.md) must meet its definition of done.
- [005](./005-accounts.md) must meet its definition of done.
- [006](./006-categories-income-sources.md) must meet its definition of done.

## Relevant docs

- [00-PRODUCT-OVERVIEW](../docs/00-PRODUCT-OVERVIEW.md)
- [04-DATA-MODEL](../docs/04-DATA-MODEL.md)
- [07-SECURITY](../docs/07-SECURITY.md)
- [09-UI-UX-DESIGN](../docs/09-UI-UX-DESIGN.md)

## Implementation scope

Modules/files: mobile/features/onboarding, profile/settings repositories and route completion guards.

- Implement concept explanations and user-confirmed currency/timezone selection.
- Reuse account/opening and category/source use cases; seed defaults idempotently only after acceptance.
- Provide independent AI/fallback/daily/learning opt-ins and privacy eligibility explanation; persist resumable progress.

## Out of scope

Bank linking/import, provider-key entry in mobile and automatic category/source inference.

## Acceptance criteria

- [ ] Onboarding resumes after process death without duplicate accounts/default categories.
- [ ] Completion requires an initial account/opening, accepted defaults and valid profile; source may wait until first income.
- [ ] No AI consent or balance is silently enabled/created; offline continuation works after initial sign-in.

## Tests

**Automated:** Onboarding state/resume tests, seed idempotency, profile currency lock and widget validation/accessibility tests.

**Manual:** Complete with zero/negative openings, skip source, decline AI, restart mid-flow and inspect large-text/dark modes.

## Documentation updates

Record final onboarding screens, default seeds and consent copy in product/UI/security docs.

## Definition of done

All acceptance criteria and required tests pass; relevant analysis/typecheck checks pass; changes preserve AGENTS.md invariants; documentation matches implemented behavior; evidence below contains actual commands and results. Mark blocked only with a specific prerequisite and retain completed work. Do not claim live/deployment tests passed when only fakes ran.

## Completion evidence

Not yet implemented. On completion record changed modules, commands/results, manual environment/build, limitations and reviewer/release gates where applicable.

