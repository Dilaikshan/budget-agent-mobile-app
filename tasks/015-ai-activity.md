# 015 — AI Activity and run observability

## Status

implemented — AgentRun/AIActivity records and Activity timeline UI.

## Goal

Establish durable, privacy-safe agent events and a local-first Activity/review UI before AI features depend on it.

## Dependencies

- [009](./009-offline-sync.md) must meet its definition of done.
- [010](./010-vercel-backend.md) must meet its definition of done.

## Relevant docs

- [04-DATA-MODEL](../docs/04-DATA-MODEL.md)
- [05-API-CONTRACTS](../docs/05-API-CONTRACTS.md)
- [06-AI-AGENT-DESIGN](../docs/06-AI-AGENT-DESIGN.md)
- [07-SECURITY](../docs/07-SECURITY.md)
- [09-UI-UX-DESIGN](../docs/09-UI-UX-DESIGN.md)
- [11-OBSERVABILITY](../docs/11-OBSERVABILITY.md)

## Implementation scope

Modules/files: backend observability/change-publisher, mobile/features/ai_activity, proposal/review storage and Crashlytics integration.

- Implement typed AgentRun/AIActivity/AIProposal/ReviewState persistence and replication with synthetic events first.
- Build timeline/filter/detail/proposal navigation, correlation identifiers and safe error mapping.
- Add redacted application/backend logging and sanitized Crashlytics configuration.

## Out of scope

External monitoring SaaS, raw prompt inspection and financial auto-acceptance.

## Acceptance criteria

- [ ] Activity distinguishes proposed, accepted, skipped and failed outcomes; rule-only runs show zero model calls.
- [ ] Duplicate events use stable IDs; client cannot forge server run/activity writes.
- [ ] Operational logs contain no amounts/descriptions/tokens/prompts; unknown usage remains null.

## Tests

**Automated:** Event schema/replay/replication tests, logger redaction snapshots with seeded sensitive inputs, Activity widget/empty/error cases.

**Manual:** Inspect synthetic success/fallback/failure/review timeline offline; verify expandable provenance and accessibility.

## Documentation updates

Update telemetry/event field examples, retention caveats and UI states in observability/data/UI docs.

## Definition of done

All acceptance criteria and required tests pass; relevant analysis/typecheck checks pass; changes preserve AGENTS.md invariants; documentation matches implemented behavior; evidence below contains actual commands and results. Mark blocked only with a specific prerequisite and retain completed work. Do not claim live/deployment tests passed when only fakes ran.

## Completion evidence

Not yet implemented. On completion record changed modules, commands/results, manual environment/build, limitations and reviewer/release gates where applicable.

