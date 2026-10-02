<!-- converted from budget_ai_agent_architecture_document.docx -->

Budget AI Agent Mobile App
Architecture Document - Flutter + Firebase Spark + Vercel + Gemini/OpenRouter
Version 1.0 | Prepared for personal portfolio build | September 2026

# 1. Executive Summary
This document defines the target architecture for an AI-native personal finance mobile app. The app uses Flutter for the mobile client, Drift/SQLite for offline-first local storage, Firebase Authentication and Cloud Firestore on the Spark plan for identity and synchronization, and Vercel Hobby for secure AI-agent execution, scheduled jobs, and LLM provider abstraction.
The differentiator is not simply expense tracking. The core experience is an AI finance agent that assists at every step: parsing raw entries, classifying income and expenses, suggesting accounts, detecting transfers, creating daily reviews, learning user rules, and producing transparent AI Activity logs.
# 2. Architecture Goals
- Provide an offline-first ledger that works without internet.
- Keep financial calculations deterministic and auditable.
- Make AI visible and useful in transaction entry, categorization, insights, and daily review.
- Avoid Firebase Blaze in V1 by using Vercel for secure backend functions and cron.
- Keep Gemini API keys and OpenRouter keys off the Flutter client.
- Support future bank-statement PDF extraction without redesigning the core ledger.
# 3. Key Architectural Decisions
| Area | Decision | Reason |
| --- | --- | --- |
| Mobile app | Flutter | Single codebase for Android/iOS with strong UI control. |
| State management | Riverpod | Testable dependency injection and predictable state. |
| Local database | Drift + SQLite | Reliable offline ledger, SQL reporting, sync metadata. |
| Authentication | Firebase Auth | Google sign-in and email/password verification. |
| Cloud database | Cloud Firestore Spark | Free tier is enough for personal sync. |
| Agent backend | Vercel Hobby + TypeScript | Free serverless APIs, cron, and AI SDK integration. |
| Primary LLM | Gemini API | Enough rate limits for single-user AI features. |
| Fallback LLM | OpenRouter free models | Backup provider and experimentation path. |
| Optional lab provider | NVIDIA models | Experimental model connector behind provider abstraction. |
| PDF statement extraction | Future phase | Avoids Firebase Storage/Blaze dependency in V1. |
# 4. Platform Capability Fit
| Capability | Firebase Spark | Vercel Hobby | Selected Design |
| --- | --- | --- | --- |
| Auth | Supported | Not needed | Firebase Auth is the identity source. |
| Firestore sync | Supported with free quotas | Can access via Admin SDK/API | Firestore stores cloud data and agent state. |
| Cloud Functions | Not available on Spark | Supported as Functions | Use Vercel APIs instead. |
| Scheduled jobs | Not available without Functions/Blaze | Daily cron supported on Hobby | Use Vercel Cron for daily agent. |
| File storage | Cloud Storage requires Blaze | Can receive small payloads but not primary storage | Defer PDFs to future phase. |
| LLM API secrets | Not a backend on Spark | Environment variables supported | Store model keys in Vercel. |
# 5. High-Level System Context
User
  |
  v
Flutter Mobile App
  |-- Drift/SQLite local ledger
  |-- Firebase Auth session
  |-- Firestore sync
  |
  | Firebase ID token
  v
Vercel Agent Backend
  |-- Firebase token verification
  |-- Finance tools
  |-- AI SDK provider abstraction
  |-- Daily cron agent
  |
  |-- Gemini primary model
  |-- OpenRouter fallback model
  |-- NVIDIA optional provider
  v
Firestore agent state, insights, AI activity, synced transactions
# 6. Domain Model Overview
The finance model separates where money is stored, where income originates, what money is for, and whether a movement is a transfer. This prevents common budget-app errors such as treating withdrawals as income or bank-to-bank moves as expenses.
| Concept | Meaning | Examples |
| --- | --- | --- |
| Account | Where money currently exists. | Commercial Bank, Sampath Bank, Cash Wallet, Savings Account. |
| Income Source | Where income originates. | Employer, freelance client, refund, investment. |
| Category | Purpose of transaction. | Salary, groceries, restaurant, transport, bills. |
| Transaction | Income, expense, transfer, or adjustment event. | Lunch Rs 850, salary Rs 250,000, transfer bank to cash. |
| Transfer | Movement between accounts without changing total wealth. | ATM withdrawal, bank-to-bank transfer. |
| AI Activity | Auditable record of agent decisions. | Gemini classified 3 entries, 2 need review. |
# 7. Component Architecture
Flutter App
  Presentation Layer
    - Onboarding
    - Dashboard
    - Quick Input
    - Category Input
    - Transactions
    - Accounts
    - AI Activity
    - Settings
  Application Layer
    - Use cases
    - Agent coordinator client
    - Sync coordinator
  Domain Layer
    - Account
    - Transaction
    - Category
    - Income Source
    - Budget
    - AI Insight
  Data Layer
    - Drift DAOs
    - Firestore remote data sources
    - Vercel Agent API client

Vercel Agent Backend
  API Routes
    - /api/agent/parse-transaction
    - /api/agent/classify-transaction
    - /api/agent/daily-review
    - /api/agent/chat
  Agent Services
    - Rule engine
    - LLM router
    - Tool registry
    - Activity logger
    - Provider fallback
  Integrations
    - Firebase Admin SDK
    - Gemini API
    - OpenRouter API
    - NVIDIA provider adapter
# 8. Core Workflows
## 8.1 Onboarding
- User signs in through Google or email/password.
- App explains three concepts: Accounts, Income Sources, and Categories.
- User creates initial accounts and opening balances.
- User creates income sources such as salary employer or freelance clients.
- Default categories are installed and can be edited.
- Agent preferences are enabled: learning, classification, and daily review.
## 8.2 Agent-Powered Quick Entry
User types: "lunch kfc 2500 cash"
  -> Flutter writes local draft
  -> Vercel Agent API parses intent
  -> Agent returns structured proposal
  -> UI shows confirmed fields
  -> User taps Save
  -> Drift creates transaction
  -> Firestore sync queues upload
## 8.3 Expense Entry with Account Source
Every expense requires an account. The agent can suggest the account based on text, defaults, and history, but the app must confirm the source before saving if confidence is low.
## 8.4 Transfer Handling
User input: "withdraw 20000 from commercial"
  -> Agent detects transfer intent
  -> From Account = Commercial Bank
  -> To Account = Cash Wallet
  -> Amount = 20,000
  -> Ledger records one transfer event
  -> Balance decreases in bank and increases in cash
  -> Monthly income/expense totals remain unchanged
## 8.5 Daily Agent
Vercel Cron -> /api/agent/daily-review
  -> Verify job secret
  -> Select users with daily agent enabled
  -> Load uncategorized and low-confidence transactions
  -> Apply learned rules first
  -> Use Gemini only when rules are insufficient
  -> Fallback to OpenRouter if Gemini fails
  -> Mark uncertain results as needs_review
  -> Create AI Activity records
  -> Update daily insight summary
# 9. AI Design Principles
- AI proposes; deterministic code commits financial mutations.
- AI calls should return strict JSON rather than free-form prose.
- Rules and history run before LLM calls to reduce cost and improve consistency.
- Low-confidence AI results require user review.
- Every AI action is logged into AI Activity.
- The app should work when AI is unavailable.
# 10. Agent Capabilities
| Capability | Real-time | Daily Agent | Requires confirmation? |
| --- | --- | --- | --- |
| Parse raw transaction input | Yes | No | Yes before saving. |
| Categorize transaction | Yes | Yes | No if confidence is high; otherwise review. |
| Suggest account/source | Yes | Yes | Yes if uncertain. |
| Detect transfer intent | Yes | Yes for cleanup | Yes before mutation. |
| Create daily insight | No | Yes | No, insight only. |
| Learn rule from correction | Yes | Yes | No after explicit user correction. |
| Change old balances | No | No | Always user controlled. |
# 11. Security Architecture
Flutter
  - Firebase Auth session
  - App Check for Firebase services
  - No LLM secrets in app
  - Secure Storage for local sensitive preferences only

Vercel
  - Environment variables for GEMINI_API_KEY and OPENROUTER_API_KEY
  - Firebase Admin verifies ID tokens
  - Each request derives uid from verified token
  - Cron endpoint protected by CRON_SECRET

Firestore
  - Security rules enforce request.auth.uid
  - User data stored under /users/{uid}/...
# 12. Data Privacy Boundaries
- Do not send the full ledger to an LLM for simple classification.
- Send only the transaction description, type, amount, allowed categories, account names if needed, and recent similar examples.
- Mask account numbers and sensitive identifiers.
- Store model request/response metadata, but avoid storing full prompts when they contain private details unless debugging is explicitly enabled.
# 13. Deployment Architecture
| Environment | Firebase Project | Vercel Project | LLM Keys |
| --- | --- | --- | --- |
| Development | budget-agent-dev | budget-agent-agent-dev | Gemini dev key, OpenRouter dev key. |
| Production personal | budget-agent-prod | budget-agent-agent-prod | Gemini prod key, OpenRouter prod key. |
# 14. Cost-Control Strategy
- Use Firebase Spark for Auth and Firestore only.
- Avoid Cloud Functions and Cloud Storage in V1.
- Use Vercel Hobby for serverless agent endpoints and daily cron.
- Use Gemini as primary model within the user-provided free tier: 15 RPM, 250k TPM, and 500 RPD.
- Use OpenRouter free models only as fallback, not as the primary quota source.
- Cache learned rules locally and in Firestore to minimize LLM calls.
# 15. Future Architecture Extensions
- Bank statement PDF extraction through n8n or Azure Document Intelligence.
- Firebase Blaze migration for Cloud Storage and Cloud Functions if the app becomes multi-user or needs deeper Firebase-native backend integration.
- Monthly report generator after statement reconciliation.
- Chat-based finance assistant using tool-calling and deterministic query tools.
- Budget forecasting and recurring payment detection.
# References
- Firebase Pricing / Spark plan: https://firebase.google.com/pricing
- Cloud Firestore quotas and pricing: https://firebase.google.com/docs/firestore/quotas
- Cloud Storage for Firebase billing changes: https://firebase.google.com/docs/storage/faqs-storage-changes-announced-sept-2024
- Vercel Hobby plan: https://vercel.com/docs/plans/hobby
- Vercel Functions limits: https://vercel.com/docs/functions/limitations
- Vercel Cron Jobs usage/pricing: https://vercel.com/docs/cron-jobs/usage-and-pricing
- Vercel AI SDK: https://vercel.com/ai-sdk
- Gemini API rate limits: https://ai.google.dev/gemini-api/docs/rate-limits
- OpenRouter pricing/free plan: https://openrouter.ai/pricing
- OpenRouter provider for Vercel AI SDK: https://openrouter.ai/docs/guides/community/vercel-ai-sdk