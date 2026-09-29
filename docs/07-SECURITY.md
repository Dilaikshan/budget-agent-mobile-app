# Security specification

## Trust model

Assets are ledger integrity, financial privacy, credentials and provider budget. Threats include another Firebase user, stolen tokens/device, modified mobile client, replayed requests, malicious input/model output, leaked backend credentials and excessive traffic. Rooted devices and a compromised administrator cannot be fully contained by application code; keep their scope explicit.

The MVP is restricted to a configured OWNER_UID. A valid Firebase account alone does not grant access. Backend services derive UID from verified Firebase auth; request bodies never select user paths. Admin SDK access bypasses Firestore security rules, so every backend repository method requires an authenticated scoped context. Cron uses only the configured owner scope after secret verification.

## Authentication and session handling

Enable Google and email/password providers only. Email/password users verify email before server data/AI routes are available. Reload user and refresh token after verification; do not trust a client boolean. Verify ID token signature, issuer, audience, expiry and revocation/disabled-user status using Firebase Admin for user APIs. Google login still uses Firebase ID tokens for backend calls, not Google OAuth access tokens. Enforce decoded email_verified and owner UID. [Firebase token verification](https://firebase.google.com/docs/auth/admin/verify-id-tokens) documents the verification boundary and the separate revocation check.

First sign-in requires connectivity. Firebase SDK owns refresh-token storage; never copy passwords/refresh tokens into Drift or logs. Custom secure preferences use Keychain/Keystore through flutter_secure_storage. Session expiry disables network access while the previously authenticated local database remains usable offline. Logout/account switching behavior is in sync specification. Account deletion is a deliberate operator workflow after export, never an AI tool.

## App Check

Use supported production Android Play Integrity and iOS App Attest/DeviceCheck configuration; verify real-device build distribution compatibility before enforcing. The mobile client sends X-Firebase-AppCheck to Vercel, and Firebase Admin verifies it against the intended project and allowed app IDs. Identity and attestation checks are both required. App Check verification is not automatically applied to custom Vercel routes. See [custom backend verification](https://firebase.google.com/docs/app-check/custom-resource-backend).

Debug tokens are allowed only in isolated development/CI, never in release builds or production environment. Standard attestation is not a one-time replay defense: combine it with operation receipts, auth, bounded rate limits and strict authorization. Optional limited-use token consumption can be evaluated later; MVP does not claim tokens are un-replayable.

## Firestore security rules

All client SDK reads and writes are denied because the chosen replication API is the sole mobile transport. This is intentionally stricter than owner-only rules and consistent with the architecture. Proposed complete baseline:

```text
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

Emulator tests must prove anonymous, owner and other-user SDK reads/writes fail, including internal activity/run/receipt paths. Separate backend tests prove the authorized Admin path succeeds only within the owner scope. Rules alone cannot validate Admin financial writes. No wildcard owner-write permission, even for apparently harmless settings.

## Authorization, validation and replay

Middleware order: size/content-type guard → ID token verification → owner/email check → App Check → request schema → rate reserve → scoped service. Validate integer money, currency, enum values, timestamps, lengths, reference ownership and archive state again in the committing service. Backend reads canonical references; client-supplied account inventories are not trusted.

Financial confirmation is enforced by mobile use cases and bound to exact action/payload/revision. The server verifies operation consistency and proposal state but cannot prove a physical human tap from a signed-in modified client. Safety against autonomous AI is enforced by excluding financial tools and sync credentials from model execution, not by trusting `confirmed:true` from a model.

Durable opId+requestHash receipts make repeated requests effect-idempotent. Reusing opId for a different payload is rejected. Revision CAS prevents lost updates, tombstones prevent resurrection, fenced leases prevent stale cron workers publishing. TLS protects transport; client timestamps cannot decide winners. A stolen valid bearer token remains usable until expiration/revocation; app attestation, owner restriction and monitoring reduce exposure but do not eliminate it.

## Secrets and least privilege

**LLM API keys must never be embedded in production Flutter builds.** Gemini/OpenRouter credentials, Firebase Admin private key, CRON_SECRET and cursor-signing key exist only in backend environment secret storage. Public Firebase client config is not a substitute for authorization. No secrets in git, .env examples, logs, URLs, screenshots or CI artifacts.

Use dedicated environment-specific service accounts with only Firestore data access and required Auth/App Check verification permissions; do not grant project Owner/Editor. Admin SDK generally has project-wide data authority, so this is not row-level IAM. Prefer short-lived workload identity where practical; initial Vercel deployment may use a scoped service-account key stored as a secret, rotated on compromise and regularly reviewed. Normalize private-key newlines at config load without logging it. Restrict Vercel/Firebase console membership and enable account MFA.

Cron secret is a high-entropy random value (at least 32 random bytes), passed in Authorization and compared safely. Reject query secrets and arbitrary UID/date overrides. Cron never redirects and disables caching. Production Vercel Cron only; preview must not run production jobs.

## Financial privacy and provider gate

Minimize prompts using sanitized merchant tokens, neutral account aliases and allowed category labels. Do not send bank numbers, identity/contact information, full ledger exports, sensitive notes or raw financial documents. Raw quick-input text passes backend redaction before a model call; unknown sensitive text stays local/manual. Retain no raw prompts/responses in production logs, Crashlytics or AI Activity.

Free API access is not a privacy guarantee. Google's unpaid-service terms caution against submitting sensitive/confidential/personal information and describe different data treatment from paid services. Read the terms for the actual billing account and region before using private data. [Gemini API terms](https://ai.google.dev/gemini-api/terms). OpenRouter upstream retention policies vary; restrict routing to approved providers and record the reviewed policy version. [OpenRouter provider logging](https://openrouter.ai/docs/guides/privacy/provider-logging).

Product policy: production personal-data AI is disabled until the operator documents that the selected provider terms permit the minimized payload. Consent alone does not override provider restrictions. If unpaid Gemini is unsuitable, either use only non-sensitive sanitized/synthetic context or configure an eligible paid Gemini project separately from Firebase Spark; changing Firebase to Blaze is not required solely to change model billing. If neither is acceptable, keep deterministic suggestions and manual entry. Fallback must pass its own gate; never send data to a less restrictive unknown provider to improve availability.

Settings explain what leaves the device, which providers may receive it, and how to disable AI/fallback/learning/daily review independently. Disabling AI prevents new external inference, not viewing past activity. Daily deterministic consistency/budget calculations may continue; daily external calls require aiEnabled and dailyReviewEnabled.

## Local protection, logging and recovery

Store each UID's SQLite file in app-private storage; exclude it, drafts and credentials from uncontrolled device cloud backups. Standard SQLite is not application-level encrypted; device OS encryption/sandboxing is the MVP boundary. Rooted/unlocked device access remains a risk. Optional database encryption and biometric lock need a later key-loss/migration decision, not a false claim of encryption today.

Use a redacted structured logger and Crashlytics breadcrumbs containing only action codes, opaque correlation IDs and counts. Do not attach raw HTTP requests or full exception objects from providers. Scrub provider messages into allowlisted error codes. User-facing activity may reference that user's transaction IDs but omits sensitive descriptions by default.

Provide a user-triggered local export with schema version, canonical records, outbox and integrity hashes. Treat the export as sensitive; explicit share/save action warns that the selected location may be unencrypted. Recovery validates schema, UID, hashes and ledger invariants before replacing any database. No managed Firestore backups/PITR/TTL dependence on Spark. Detail in deployment.

## Abuse, dependencies and environment gates

Persist rate/token reservations; bound request size, dates, rows, prompt size and execution time. Fail closed for AI if reservation storage is unavailable. Local entry continues if quotas/backend fail. CORS allows known web origins only if a web client is later added; mobile bearer auth is not protected by CORS. Health reveals no secrets or dependency readiness.

CI scans secrets/dependencies, pins lockfiles, tests negative authorization and verifies release artifacts contain no model keys/debug flags. Preview credentials point only to development Firebase, with synthetic data and fake providers by default. Security fixes must document migration/compatibility impacts. Before release, test stolen/expired token behavior, cross-UID attempts, direct SDK denial, prompt injection, stale confirmations, replay and cron secret handling.
