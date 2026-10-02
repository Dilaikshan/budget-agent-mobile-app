<!-- converted from budget_ai_agent_technical_document.docx -->

Budget AI Agent Mobile App
Technical Specification - Implementation Blueprint
Version 1.0 | Prepared for personal portfolio build | September 2026

# 1. Scope
This technical specification converts the architecture into implementation-ready guidance for Flutter, Firebase, Vercel, Gemini, and OpenRouter. It prioritizes the V1 app: offline ledger, authentication, synchronization, AI-powered transaction entry, AI categorization, AI Activity, and daily agent execution. Bank statement PDF extraction is deliberately excluded from V1.
# 2. Monorepo Structure
budget-agent/
  apps/
    mobile/                 # Flutter app
      lib/
      test/
      integration_test/
  services/
    agent-api/              # Vercel TypeScript backend
      app/api/
      src/
      test/
      vercel.json
  docs/
    product/
    architecture/
    technical/
  packages/
    shared-contracts/       # Optional JSON schemas/types
# 3. Flutter App Structure
lib/
  main.dart
  app.dart
  core/
    config/
    database/
    firebase/
    network/
    sync/
    theme/
    utils/
  features/
    auth/
    onboarding/
    dashboard/
    accounts/
    income_sources/
    categories/
    transactions/
    budgets/
    insights/
    ai_activity/
    settings/
# 4. Suggested Flutter Packages
| Purpose | Package |
| --- | --- |
| State management | flutter_riverpod |
| Navigation | go_router |
| Local database | drift, sqlite3_flutter_libs, path_provider |
| Firebase core/auth/firestore | firebase_core, firebase_auth, cloud_firestore |
| Google sign-in | google_sign_in |
| App Check | firebase_app_check |
| Secure local storage | flutter_secure_storage |
| Network client | dio or http |
| UUIDs | uuid |
| Date/time | intl |
| Charts | fl_chart or graphic |
# 5. Local Database Schema
Drift/SQLite is the local source of truth for UI and offline behavior. Firestore is the cloud sync target. All records include sync metadata.
accounts
  id TEXT PRIMARY KEY
  user_id TEXT
  name TEXT
  type TEXT            -- bank, cash, wallet, savings, card
  currency TEXT
  opening_balance REAL
  is_archived INTEGER
  created_at TEXT
  updated_at TEXT
  deleted_at TEXT NULL
  sync_status TEXT     -- pending, synced, failed

income_sources
  id TEXT PRIMARY KEY
  user_id TEXT
  name TEXT
  type TEXT            -- salary, freelance, business, refund, investment
  default_account_id TEXT NULL
  is_archived INTEGER
  created_at TEXT
  updated_at TEXT
  deleted_at TEXT NULL
  sync_status TEXT

categories
  id TEXT PRIMARY KEY
  user_id TEXT
  name TEXT
  type TEXT            -- income, expense
  parent_id TEXT NULL
  icon TEXT NULL
  sort_order INTEGER
  is_system INTEGER
  is_archived INTEGER
  sync_status TEXT

transactions
  id TEXT PRIMARY KEY
  user_id TEXT
  type TEXT            -- income, expense, transfer, adjustment
  amount REAL
  currency TEXT
  account_id TEXT NULL
  destination_account_id TEXT NULL
  income_source_id TEXT NULL
  category_id TEXT NULL
  description TEXT
  raw_input TEXT NULL
  transaction_date TEXT
  status TEXT          -- confirmed, suggested, needs_review
  categorization_source TEXT -- manual, rule, ai
  ai_confidence REAL NULL
  origin TEXT          -- manual, ai_input, recurring, import_future
  created_at TEXT
  updated_at TEXT
  deleted_at TEXT NULL
  sync_status TEXT

categorization_rules
  id TEXT PRIMARY KEY
  user_id TEXT
  pattern TEXT
  category_id TEXT
  account_id TEXT NULL
  income_source_id TEXT NULL
  confidence REAL
  source TEXT          -- user_correction, agent, system
  usage_count INTEGER
  last_used_at TEXT NULL
  sync_status TEXT

ai_activity
  id TEXT PRIMARY KEY
  user_id TEXT
  agent_type TEXT
  title TEXT
  summary TEXT
  metadata_json TEXT
  created_at TEXT
  sync_status TEXT
# 6. Firestore Collections
/users/{uid}
  /profile/settings
  /accounts/{accountId}
  /income_sources/{sourceId}
  /categories/{categoryId}
  /transactions/{transactionId}
  /categorization_rules/{ruleId}
  /ai_activity/{activityId}
  /agent_runs/{runId}
  /daily_summaries/{yyyyMMdd}
  /budgets/{budgetId}
# 7. Firestore Security Rule Shape
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null
                         && request.auth.uid == userId;
    }
  }
}
# 8. Sync Engine
The sync engine operates independently from UI screens. UI reads from Drift. Sync pushes pending local changes to Firestore and pulls remote changes into Drift.
Local write flow:
  use case -> Drift transaction -> sync_status=pending -> UI updates

Push flow:
  find pending rows -> write to Firestore -> mark synced

Pull flow:
  read Firestore changes since lastSyncAt -> upsert Drift rows

Conflict rule V1:
  latest updated_at wins, except deleted_at wins over stale updates.

Recommended improvement:
  store change logs for transaction-critical changes.
# 9. Ledger Rules
| Transaction Type | Account Effect | Report Effect |
| --- | --- | --- |
| Income | + amount to account_id | Counts as income. |
| Expense | - amount from account_id | Counts as expense. |
| Transfer | - from account_id, + to destination_account_id | Does not count as income or expense. |
| Adjustment | +/- amount to account_id | Shown separately; used for corrections. |
# 10. Account Balance Calculation
balance(account) = opening_balance
  + sum(income where account_id = account)
  - sum(expense where account_id = account)
  - sum(transfer where account_id = account)
  + sum(transfer where destination_account_id = account)
  + sum(adjustment where account_id = account)
# 11. Vercel Agent API Structure
services/agent-api/
  app/api/agent/parse-transaction/route.ts
  app/api/agent/classify-transaction/route.ts
  app/api/agent/chat/route.ts
  app/api/jobs/daily-review/route.ts
  src/auth/firebaseAdmin.ts
  src/ai/providers/geminiProvider.ts
  src/ai/providers/openRouterProvider.ts
  src/ai/llmRouter.ts
  src/agent/financeAgent.ts
  src/agent/tools.ts
  src/agent/ruleEngine.ts
  src/firestore/repositories.ts
  src/schemas/transactionSchemas.ts
  src/logging/aiActivityLogger.ts
# 12. Vercel Environment Variables
| Variable | Purpose |
| --- | --- |
| FIREBASE_PROJECT_ID | Firebase project ID. |
| FIREBASE_CLIENT_EMAIL | Service account email for Admin SDK. |
| FIREBASE_PRIVATE_KEY | Service account private key. Store only in Vercel environment variables. |
| GEMINI_API_KEY | Primary model provider key. |
| OPENROUTER_API_KEY | Fallback provider key. |
| NVIDIA_API_KEY | Optional provider key. |
| CRON_SECRET | Secret used to protect scheduled job route. |
| APP_ENV | dev or prod. |
# 13. Authentication Flow for Agent Calls
Flutter:
  token = await FirebaseAuth.instance.currentUser!.getIdToken()
  POST /api/agent/parse-transaction
  Authorization: Bearer <token>

Vercel:
  verifyIdToken(token)
  uid = decoded.uid
  never trust uid from request body
  read/write only /users/{uid}/...
# 14. Agent Tool Design
| Tool | Type | Purpose | Mutation? |
| --- | --- | --- | --- |
| getAccounts | Read | Return accounts and default preferences. | No |
| getCategories | Read | Return allowed category tree. | No |
| findSimilarTransactions | Read | Use history to classify recurring merchants. | No |
| getMonthSummary | Read | Return deterministic monthly totals. | No |
| proposeTransaction | Proposal | Create structured transaction draft. | No ledger mutation |
| classifyTransaction | Proposal | Suggest category/subcategory/account. | No ledger mutation |
| createAiActivity | Write | Log visible agent activity. | Yes, non-financial |
| createTransaction | Financial write | Save transaction after user confirmation. | Yes, user confirmation required |
# 15. LLM Routing Policy
classifyTransaction(input):
  1. Run exact learned rules
  2. Run keyword/merchant rules
  3. Run similarity against recent transactions
  4. If confidence >= 0.90, return rule result
  5. Else call Gemini
  6. If Gemini fails or quota exceeded, call OpenRouter
  7. If fallback fails, mark needs_review
# 16. Structured AI Contracts
ParseTransactionRequest
{
  rawInput: string,
  currency: string,
  accounts: [{ id, name, type }],
  categories: [{ id, name, type, parentId }],
  incomeSources: [{ id, name, type }]
}

ParseTransactionResponse
{
  intent: 'income' | 'expense' | 'transfer' | 'adjustment' | 'unknown',
  amount: number | null,
  currency: string,
  description: string,
  merchant: string | null,
  accountId: string | null,
  destinationAccountId: string | null,
  categoryId: string | null,
  incomeSourceId: string | null,
  confidence: number,
  needsUserConfirmation: boolean,
  questions: string[]
}
# 17. Real-Time Transaction Flow
Quick Input Screen
  -> User enters text
  -> Local draft state created
  -> Call /api/agent/parse-transaction
  -> Agent returns structured proposal
  -> UI shows editable confirmation screen
  -> User confirms
  -> TransactionUseCase validates required fields
  -> Drift transaction saved
  -> Sync status pending
  -> Firestore sync runs when online
  -> AI Activity logged
# 18. Daily Agent Flow
Vercel Cron once per day
  -> GET /api/jobs/daily-review?secret=...
  -> Determine Sri Lanka business date
  -> Read enabled users
  -> For each user:
       read uncategorized/needs_review transactions
       apply rule engine
       call Gemini only for unresolved items
       fallback to OpenRouter if needed
       write ai_activity
       write agent_run summary
       write daily_summary
  -> Return 200 with aggregate metrics
# 19. AI Activity Schema
ai_activity record
{
  id: string,
  userId: string,
  agentType: 'realtime_parse' | 'daily_review' | 'rule_learning' | 'insight',
  title: string,
  summary: string,
  metadata: {
    model?: string,
    provider?: string,
    inputTokens?: number,
    outputTokens?: number,
    ruleMatches?: number,
    llmCalls?: number,
    confidence?: number,
    transactionIds?: string[]
  },
  createdAt: timestamp
}
# 20. UI Screens
| Screen | Purpose |
| --- | --- |
| Auth | Google and email/password sign-in. |
| Onboarding | Create accounts, opening balances, income sources, categories, AI preferences. |
| Dashboard | Total balance, account balances, monthly income/expense/savings, AI insight. |
| Quick Input | Agent-powered raw text transaction entry. |
| Category Entry | Manual category-first entry. |
| Transactions | History, filters, needs-review list. |
| Accounts | Accounts/wallets and balances. |
| AI Activity | Visible log of agent actions, model calls, confidence and review items. |
| Settings | Theme, AI preferences, providers, sync status. |
# 21. Required Validation Rules
- Expense must have account_id.
- Income must have account_id and should have income_source_id when available.
- Transfer must have account_id, destination_account_id, and different source/destination accounts.
- Amount must be positive; direction is controlled by transaction type.
- Category type must match transaction type except transfer.
- Low-confidence AI results must be saved as suggested or needs_review, not silently confirmed.
# 22. Testing Strategy
| Layer | Tests |
| --- | --- |
| Domain | Balance calculations, transfer logic, transaction validation. |
| Local DB | DAO insert/update/delete, sync status, migrations. |
| Repository | Offline create, pending sync, conflict resolution. |
| Agent backend | Schema validation, Firebase token verification, provider fallback. |
| AI contracts | Golden tests for raw input examples and JSON responses. |
| UI | Onboarding, quick entry, category entry, AI review. |
# 23. Sample Golden Test Inputs
| Input | Expected Intent | Expected Key Fields |
| --- | --- | --- |
| salary 250000 commercial | income | category=salary, account=Commercial Bank |
| lunch kfc 2500 cash | expense | category=restaurant, account=Cash Wallet |
| withdraw 20000 from commercial | transfer | from=Commercial Bank, to=Cash Wallet |
| paid dialog bill 4900 sampath | expense | category=bills/mobile or internet, account=Sampath |
| freelance client x 75000 to boc | income | incomeSource=Client X, account=BOC |
# 24. Implementation Phases
| Phase | Deliverable |
| --- | --- |
| 1 | Flutter shell, routing, theme, Firebase Auth. |
| 2 | Drift schema, accounts, income sources, categories. |
| 3 | Income/expense/transfer ledger with deterministic balance calculations. |
| 4 | Firestore sync engine with pending/synced/failed states. |
| 5 | Vercel Agent API with Firebase token verification. |
| 6 | Gemini primary provider, OpenRouter fallback provider. |
| 7 | Quick input agent and confirmation UI. |
| 8 | Rule learning from user corrections. |
| 9 | AI Activity screen and agent_run logging. |
| 10 | Vercel Cron daily review agent. |
| 11 | Budgets and insights. |
| 12 | Future: bank statement extraction and monthly reports. |
# 25. Definition of Done for V1
- User can authenticate with Google or email/password.
- User can use the app offline and view accurate balances.
- User can add income, expense, transfer, and adjustment transactions.
- Every expense requires a payment account.
- Agent can parse raw input and return a structured proposal.
- Gemini is used as primary LLM and OpenRouter as fallback.
- Vercel cron runs the daily review agent.
- AI Activity displays all significant agent decisions.
- Firestore sync works without Cloud Functions or Cloud Storage.
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