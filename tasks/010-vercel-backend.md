# 010 — Authenticated Vercel backend and sync gateway

## Status

implemented and deployed (https://budget-agent-backend.vercel.app) — guards, strict schemas, CAS/receipts/changes, rate limits; 154 vitest tests on an in-memory store. Firestore emulator tests NOT run (no Java/Firebase CLI locally); live data routes return 503 until Firebase secrets are configured.

## Goal

Implement secure user-scoped APIs and atomic canonical persistence before mobile sync integration.

## Dependencies

- [002](./002-authentication.md) must meet its definition of done.
- [003](./003-local-database.md) must meet its definition of done.

## Relevant docs

- [01-ARCHITECTURE](../docs/01-ARCHITECTURE.md)
- [02-TECHNICAL-SPECIFICATION](../docs/02-TECHNICAL-SPECIFICATION.md)
- [04-DATA-MODEL](../docs/04-DATA-MODEL.md)
- [05-API-CONTRACTS](../docs/05-API-CONTRACTS.md)
- [07-SECURITY](../docs/07-SECURITY.md)
- [08-OFFLINE-SYNC](../docs/08-OFFLINE-SYNC.md)
- [12-DEPLOYMENT](../docs/12-DEPLOYMENT.md)

## Implementation scope

Modules/files: backend/api/health, api/v1/sync, src/auth/contracts/domain/firestore/sync and Firebase rules/indexes.

- Implement Firebase ID-token/revocation/email/owner guards, custom App Check verification and typed error envelopes.
- Implement push CAS/reference validation, receipt/hash replay, compound account/opening, immutable Change and SyncState.
- Implement bounded change pull and explicit supported entity/action allowlists; deploy/test deny-all client rules in dev.

## Out of scope

Production deployment, model inference, arbitrary Admin CRUD and mobile direct cloud writes.

## Acceptance criteria

- [ ] No client UID or arbitrary path reaches repositories; invalid auth/attestation fails before data access.
- [ ] Receipt check precedes revision check; per-operation partial results match API contracts.
- [ ] All visible server writes can use the same atomic change-publishing service; no model call occurs in a Firestore transaction.

## Tests

**Automated:** Emulator competing CAS/replay/reference tests, direct client rule denial, cross-UID API negatives, schema/size/rate tests.

**Manual:** Run authenticated dev push/pull and inspect canonical data/receipts; verify health contains no sensitive readiness details.

## Documentation updates

Update actual route/config/index inventory in API, data, security and deployment specs.

## Definition of done

All acceptance criteria and required tests pass; relevant analysis/typecheck checks pass; changes preserve AGENTS.md invariants; documentation matches implemented behavior; evidence below contains actual commands and results. Mark blocked only with a specific prerequisite and retain completed work. Do not claim live/deployment tests passed when only fakes ran.

## Completion evidence

Not yet implemented. On completion record changed modules, commands/results, manual environment/build, limitations and reviewer/release gates where applicable.

