# System architecture

## Responsibilities

One Flutter application and one modular TypeScript backend; no microservices or queue service. Drift stores the local confirmed ledger plus pending overlays. Firestore stores the accepted remote replica and server outputs. Vercel is the authenticated synchronization gateway and agent host. Firebase Auth owns identity; App Check attests app requests; Crashlytics receives redacted diagnostics. Gemini/OpenRouter see only minimized inference context and cannot reach the database.

The required path is Flutter UI → Repository → Drift → Sync Engine → Firestore, with **Vercel inserted between Sync Engine and Firestore** to enforce revision checks, authorization, references and idempotency atomically. Direct Flutter Firestore access is disabled; no second persistence queue exists. This is a deliberate refinement of the legacy design, recorded in ADR-07.

## System context

```mermaid
flowchart LR
  U[Personal user] --> M[Flutter app]
  M --> A[Firebase Authentication]
  M --> C[Firebase App Check]
  M --> V[Vercel API]
  M --> X[Crashlytics]
  V --> F[(Firestore Spark)]
  V --> G[Gemini API]
  V --> O[OpenRouter]
  CR[Vercel Cron] --> V
```

## Containers and components

```mermaid
flowchart TB
  subgraph Mobile
    UI[Riverpod screens] --> UC[Use cases]
    UC --> R[Repository interfaces]
    R --> D[(Drift SQLite)]
    S[Sync coordinator] <--> D
    UC --> AI[Agent client]
  end
  subgraph Backend
    API[HTTP handlers] --> AUTH[Auth and validation]
    AUTH --> SY[Sync service]
    AUTH --> AG[Agent services]
    SY --> FR[Scoped Firestore repositories]
    AG --> FR
    AG --> PR[Provider router]
  end
  S <--> API
  AI <--> API
  FR --> FS[(Firestore)]
```

## Flutter architecture

```mermaid
flowchart LR
  W[Widgets and go_router] --> P[Riverpod controllers]
  P --> U[Application use cases]
  U --> DOM[Pure Dart domain]
  U --> RI[Repository interfaces]
  DI[Drift implementations] -. implements .-> RI
  DI --> SQL[(SQLite)]
  SY[Sync engine] --> DI
  SY --> HTTP[Authenticated API client]
```

Feature folders contain presentation/application/domain/data where needed. Domain has no Flutter, Firebase, SQL or HTTP imports. Riverpod wires implementations and streams; routers handle session/onboarding guards. Controllers never calculate balances independently.

## Backend architecture

```mermaid
flowchart LR
  H[Node HTTP handlers] --> G[Auth App Check limits schema]
  G --> S[Sync application service]
  G --> A[Parsing classification insights]
  J[Cron secret guard] --> D[Daily coordinator]
  D --> A
  A --> T[Read and proposal tools]
  A --> R[Rules and model router]
  S --> DB[UID-scoped repositories]
  T --> DB
  D --> DB
  R --> OBS[Redacted telemetry]
```

Use native Vercel Node functions under backend/api; no Next.js UI/framework requirement. Initialize Firebase Admin once per warm instance. Never invoke providers inside Firestore transaction callbacks, which may rerun.

## AI provider flow

```mermaid
flowchart TD
  I[Validated input] --> R[Rules merchant keywords history]
  R --> Q{Sufficient candidate?}
  Q -- Yes --> P[Validated proposal]
  Q -- No --> E{Privacy and budget eligible?}
  E -- No --> M[Manual completion]
  E -- Yes --> G[Gemini bounded attempt]
  G --> V{Valid output?}
  V -- Yes --> P
  V -- Eligible failure --> O[OpenRouter bounded fallback]
  O --> P
  O -- Failure --> M
  P --> C[User confirmation]
```

## Transaction creation

```mermaid
sequenceDiagram
  actor User
  participant UI
  participant Agent
  participant Domain
  participant Drift
  participant Sync
  User->>UI: Natural language or category entry
  opt Online AI permitted
    UI->>Agent: Parse minimized draft
    Agent-->>UI: Proposal, questions and evidence
  end
  UI-->>User: Exact amount, type, accounts, category, date
  User->>UI: Save confirmed payload
  UI->>Domain: Validate normalized transaction
  Domain->>Drift: Atomic transaction + outbox operation
  Drift-->>UI: Reactive balance including pending record
  Sync->>Drift: Read outbox for later delivery
```

## Offline sync

```mermaid
sequenceDiagram
  participant Drift
  participant Sync
  participant API
  participant Firestore
  Sync->>API: Pull after durable sequence cursor
  API->>Firestore: Read immutable changes up to watermark
  API-->>Sync: Changes and next cursor
  Sync->>Drift: Atomic merge and cursor checkpoint
  Sync->>API: Push opId + baseRevision + confirmed payload
  API->>Firestore: Atomic CAS + receipt + change sequence
  API-->>Sync: Accepted or conflict
  Sync->>Drift: Acknowledge matching op or preserve conflict
```

## Daily execution

```mermaid
flowchart TD
  C[Daily UTC cron] --> A[Verify CRON_SECRET]
  A --> L[Lease run by UID and business date]
  L --> Q[Bounded work page]
  Q --> R[Rules then eligible model calls]
  R --> P[Revision-bound proposals and insights]
  P --> F[Atomic item checkpoint and activity]
  F --> D{Deadline or item cap?}
  D -- No --> Q
  D -- Yes --> E[Complete or partial run]
```

## Authentication

```mermaid
sequenceDiagram
  participant App
  participant Auth as Firebase Auth
  participant Check as App Check
  participant API as Vercel
  App->>Auth: Google or verified email login
  Auth-->>App: SDK-managed session
  App->>Auth: Get Firebase ID token
  App->>Check: Get attestation token
  App->>API: Bearer ID token + X-Firebase-AppCheck
  API->>Auth: Admin verification and revocation check
  API->>Check: Admin token verification
  API->>API: Derive UID, owner allowlist, scoped validation
  API-->>App: Typed response or auth error
```

These diagrams are logical boundaries, not evidence of deployed infrastructure. Protocol detail belongs to [sync](08-OFFLINE-SYNC.md), [API](05-API-CONTRACTS.md) and [AI](06-AI-AGENT-DESIGN.md).
