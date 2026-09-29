# 002 — Authentication and session boundaries

## Status

implemented — Google + email/password, verification, reset, route guards; automated guard tests pass. Manual device sign-in pending (needs Firebase project).

## Goal

Implement Google and email/password authentication, verification and safe per-user session lifecycle.

## Dependencies

- [001](./001-project-bootstrap.md) must meet its definition of done.

## Relevant docs

- [02-TECHNICAL-SPECIFICATION](../docs/02-TECHNICAL-SPECIFICATION.md)
- [07-SECURITY](../docs/07-SECURITY.md)
- [08-OFFLINE-SYNC](../docs/08-OFFLINE-SYNC.md)
- [09-UI-UX-DESIGN](../docs/09-UI-UX-DESIGN.md)
- [12-DEPLOYMENT](../docs/12-DEPLOYMENT.md)

## Implementation scope

Modules/files: mobile/features/auth, core/firebase/config, router guards and secure session integration.

- Implement Firebase SDK auth adapter, Google sign-in, email verification/resend and password reset.
- Define signed-out/unverified/onboarding/ready routing and session events for database/sync integration.
- Require initial online sign-in; retain previously authenticated offline access and explicit sign-out handling.

## Out of scope

Server guard implementation (task 010), anonymous/public signup, custom identity provider and biometric locking.

## Acceptance criteria

- [ ] Verified-owner remote access prerequisites are represented correctly; a client boolean cannot assert verification.
- [ ] Sign-out cancels in-flight requests; account switches cannot reuse another UID's data context.
- [ ] Passwords/tokens are not written to application logs or Drift.

## Tests

**Automated:** Auth adapter and route-guard tests for expired/unverified/revoked/signed-out states; UID switch/cancellation tests using fakes.

**Manual:** Use dev Google/email sign-in, verify email, reset password, sign out and restart offline after prior login; record real-device limitations.

## Documentation updates

Document actual auth configuration, route/session behavior and real-device setup in security, UI and deployment.

## Definition of done

All acceptance criteria and required tests pass; relevant analysis/typecheck checks pass; changes preserve AGENTS.md invariants; documentation matches implemented behavior; evidence below contains actual commands and results. Mark blocked only with a specific prerequisite and retain completed work. Do not claim live/deployment tests passed when only fakes ran.

## Completion evidence

Not yet implemented. On completion record changed modules, commands/results, manual environment/build, limitations and reviewer/release gates where applicable.

