# 013 — Categorization and explicit rule learning

## Status

todo — specification ready; implementation not started.

## Goal

Suggest categories efficiently and learn only explicitly accepted reusable mappings.

## Dependencies

- [012](./012-ai-transaction-parser.md) must meet its definition of done.

## Relevant docs

- [04-DATA-MODEL](../docs/04-DATA-MODEL.md)
- [05-API-CONTRACTS](../docs/05-API-CONTRACTS.md)
- [06-AI-AGENT-DESIGN](../docs/06-AI-AGENT-DESIGN.md)
- [08-OFFLINE-SYNC](../docs/08-OFFLINE-SYNC.md)
- [09-UI-UX-DESIGN](../docs/09-UI-UX-DESIGN.md)
- [10-TESTING-STRATEGY](../docs/10-TESTING-STRATEGY.md)

## Implementation scope

Modules/files: backend classification/rule engine, mobile rule management and category-proposal acceptance.

- Implement exact merchant, token keyword and bounded history precedence with ambiguity handling.
- Add classify endpoint bound to current transaction revision; persist proposals/review state.
- Offer separate Remember action after correction and explicit rule management; rules prefill only.

## Out of scope

Autonomous rule activation, retrospective bulk recategorization and unrestricted regex rules.

## Acceptance criteria

- [ ] High-confidence suggestions do not alter confirmed transactions automatically.
- [ ] No learning occurs from unaccepted model outputs or a correction without Remember confirmation.
- [ ] Stale proposal acceptance is rejected and conflicting rules ask for review.

## Tests

**Automated:** Rule priority/tie/token-boundary/history-threshold tests; stale revision, disabled rule and no-auto-mutation tests.

**Manual:** Correct a merchant category, opt in/out of Remember, repeat entry and inspect provenance; disable/edit rule offline.

## Documentation updates

Update rule examples/precedence and acceptance behavior in AI/data/UI specs.

## Definition of done

All acceptance criteria and required tests pass; relevant analysis/typecheck checks pass; changes preserve AGENTS.md invariants; documentation matches implemented behavior; evidence below contains actual commands and results. Mark blocked only with a specific prerequisite and retain completed work. Do not claim live/deployment tests passed when only fakes ran.

## Completion evidence

Not yet implemented. On completion record changed modules, commands/results, manual environment/build, limitations and reviewer/release gates where applicable.

