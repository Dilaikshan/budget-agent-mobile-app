# 011 — AI provider routing and budgets

## Status

implemented — Gemini primary (@ai-sdk/google 4), OpenRouter fallback with upstream allowlist, maxRetries 0, deadlines, persisted token/attempt budgets. Live provider smoke test blocked: no API keys provided; AI_ENABLED=false in production.

## Goal

Implement Gemini primary and OpenRouter fallback with strict structured validation, privacy checks and bounded usage.

## Dependencies

- [010](./010-vercel-backend.md) must meet its definition of done.

## Relevant docs

- [02-TECHNICAL-SPECIFICATION](../docs/02-TECHNICAL-SPECIFICATION.md)
- [05-API-CONTRACTS](../docs/05-API-CONTRACTS.md)
- [06-AI-AGENT-DESIGN](../docs/06-AI-AGENT-DESIGN.md)
- [07-SECURITY](../docs/07-SECURITY.md)
- [11-OBSERVABILITY](../docs/11-OBSERVABILITY.md)
- [12-DEPLOYMENT](../docs/12-DEPLOYMENT.md)

## Implementation scope

Modules/files: backend/src/ai/providers/router, config, token reservations and provider fixtures.

- Select explicit eligible model IDs and compatible AI SDK/provider versions; record capability/privacy review.
- Implement one primary attempt plus eligible fallback, AbortSignal deadlines, no hidden retries and typed ProviderError.
- Persist shared attempt/token reservations; validate structured output and redact telemetry; expose fake adapters for CI.

## Out of scope

NVIDIA adapter, general chat, unconstrained provider routing and paid activation without approval.

## Acceptance criteria

- [ ] Timeout/429/unavailable/invalid output can fall back; refusal/ineligible privacy cannot.
- [ ] Budget/credential/provider failure returns typed AI unavailability without impacting sync or manual ledger.
- [ ] No API/model secret or provider endpoint credential is shipped in Flutter.

## Tests

**Automated:** Provider routing matrix, bounded retries/deadlines, token reservation races, unknown usage handling and malformed output tests.

**Manual:** Opt-in sanitized live smoke test for both configured models, or record live test blocked while fake tests pass; do not invent credentials.

## Documentation updates

Record verified model IDs/versions, account-specific quotas and privacy eligibility in deployment/AI decisions.

## Definition of done

All acceptance criteria and required tests pass; relevant analysis/typecheck checks pass; changes preserve AGENTS.md invariants; documentation matches implemented behavior; evidence below contains actual commands and results. Mark blocked only with a specific prerequisite and retain completed work. Do not claim live/deployment tests passed when only fakes ran.

## Completion evidence

Not yet implemented. On completion record changed modules, commands/results, manual environment/build, limitations and reviewer/release gates where applicable.

