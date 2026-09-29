# 012 — Natural-language transaction proposals

## Status

implemented — rules-first parse, 52 deterministic goldens, alias/redaction, idempotent replay cache, proposals/run/activity persisted atomically. Live model accuracy gate (>=90%) not yet measured.

## Goal

Turn quick input into a validated editable proposal while preserving instant manual entry.

## Dependencies

- [007](./007-transactions.md) must meet its definition of done.
- [009](./009-offline-sync.md) must meet its definition of done.
- [011](./011-ai-provider-layer.md) must meet its definition of done.
- [015](./015-ai-activity.md) must meet its definition of done.

## Relevant docs

- [04-DATA-MODEL](../docs/04-DATA-MODEL.md)
- [05-API-CONTRACTS](../docs/05-API-CONTRACTS.md)
- [06-AI-AGENT-DESIGN](../docs/06-AI-AGENT-DESIGN.md)
- [07-SECURITY](../docs/07-SECURITY.md)
- [09-UI-UX-DESIGN](../docs/09-UI-UX-DESIGN.md)
- [10-TESTING-STRATEGY](../docs/10-TESTING-STRATEGY.md)

## Implementation scope

Modules/files: backend/api/v1/agent/parse-transaction, parsing service/prompts, mobile Draft/quick-input/confirmation.

- Implement rule-first local/backend preprocessing, scoped canonical context and one combined parse/enrichment call.
- Persist versioned proposal/run/activity, API idempotency lease/cache and ambiguity questions.
- Preserve user edits against late results; map confirmation to the existing normalized transaction command.

## Out of scope

Automatic ledger commits, general chat and unreviewed creation of new references.

## Acceptance criteria

- [ ] Golden inputs resolve only known IDs and integer amounts; missing fields remain null/questions.
- [ ] Every financial Save requires confirmation, regardless of confidence.
- [ ] Both provider failures, unsynced references and AI-disabled/offline state still allow manual completion.

## Tests

**Automated:** ≥50 golden cases, schema/invented-ID/injection cases, request replay, late response and equivalent-entry serialization tests.

**Manual:** Enter lunch/salary/withdrawal examples, edit suggestions, disable network/providers and confirm no draft loss.

## Documentation updates

Record prompt/schema versions, parsing coverage and final quick-input states in AI/API/UI/testing docs.

## Definition of done

All acceptance criteria and required tests pass; relevant analysis/typecheck checks pass; changes preserve AGENTS.md invariants; documentation matches implemented behavior; evidence below contains actual commands and results. Mark blocked only with a specific prerequisite and retain completed work. Do not claim live/deployment tests passed when only fakes ran.

## Completion evidence

Not yet implemented. On completion record changed modules, commands/results, manual environment/build, limitations and reviewer/release gates where applicable.

