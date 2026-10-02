# Graph Report - budgent-agent-system  (2026-10-02)

## Corpus Check
- 181 files · ~224,659 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 23 file(s) not represented in the graph (top: .xml 9, (none) 7, .example 2)

## Summary
- 2837 nodes · 4996 edges · 132 communities (122 shown, 10 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 56 edges (avg confidence: 0.81)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `706dd9b6`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- app_database.dart
- tables.dart
- entities.ts
- _
- entry_sheet.dart
- transactions_screen.dart
- onboarding_screen.dart
- rules.ts
- profileProvider
- parse.ts
- agent_repository.dart
- agent.ts
- transaction_detail_screen.dart
- DataClass
- shared.dart
- quick_parser.dart
- daily.ts
- transaction.dart
- providers.ts
- budgets_screen.dart
- service.ts
- ledger_repository.dart
- package.json
- sign_in_screen.dart
- transaction_actions.dart
- agents.test.ts
- api_client.dart
- money.dart
- providers.dart
- router.dart
- agents/insights.ts
- CanonicalRecord
- auth_repository.dart
- budget_ai_agent_technical_document_bd08a242.md
- deps.ts
- DocStore
- core_test.dart
- sync_engine.dart
- router.ts
- account_repository.dart
- http.test.ts
- codecs.dart
- Table
- app_config.dart
- result.dart
- confirmation_sheet.dart
- categories_screen.dart
- budget_ai_agent_architecture_document_716bf834.md
- src/ledger.ts
- accounts_screen.dart
- Architecture decisions and reconciliation
- transactions_test.dart
- main.dart
- category_repository.dart
- env.ts
- fake_server.dart
- App.tsx
- common.dart
- selectors.dart
- helpers.dart
- budget_repository.dart
- profile_repository.dart
- time.dart
- TransactionParserModal.tsx
- compilerOptions
- StatelessWidget
- compilerOptions
- syncControllerProvider
- screens_test.dart
- Budget Agent — manual setup, step by step
- ledger.dart
- text.dart
- src/types.ts
- canonical_json.dart
- 001 — Project bootstrap
- 002 — Authentication and session boundaries
- 003 — Local database and domain foundations
- 004 — Guided onboarding
- 005 — Accounts and opening balances
- 006 — Categories and income sources
- 007 — Confirmed income and expense ledger
- 008 — Transfers, withdrawals and deposits
- 009 — Mobile offline synchronization
- 010 — Authenticated Vercel backend and sync gateway
- 011 — AI provider routing and budgets
- 012 — Natural-language transaction proposals
- 013 — Categorization and explicit rule learning
- 014 — Idempotent daily review agent
- 015 — AI Activity and run observability
- 016 — Budgets and evidence-based insights
- 017 — Regression, performance and recovery hardening
- 018 — Security and privacy release gates
- 019 — Release preparation and operator handoff
- System architecture
- Implementation plan
- devDependencies
- canonical.ts
- Endpoint inventory
- Security specification
- UI and UX design
- pendingOpsProvider
- theme.dart
- AI agent design
- Offline synchronization
- Deployment and operations
- Technical specification
- dependencies
- dependencies
- Product overview
- Data model
- Testing strategy
- devDependencies
- vercel.json
- Observability
- _ConfirmationSheet
- Dashboard.tsx
- Coding agent instructions
- Budget Agent
- BudgetsView.tsx
- Exception
- AppDatabase
- 14-FUTURE-ROADMAP.md
- FlutterActivity
- privacy.dart
- ReferenceLookup
- SyncApi
- budget_agent

## God Nodes (most connected - your core abstractions)
1. `_` - 71 edges
2. `runDaily()` - 34 edges
3. `UserScope` - 31 edges
4. `run()` - 29 edges
5. `ApiError` - 24 edges
6. `profileProvider` - 23 edges
7. `publishChange()` - 22 edges
8. `Architecture decisions and reconciliation` - 21 edges
9. `mutation()` - 20 edges
10. `CanonicalRecord` - 19 edges

## Surprising Connections (you probably didn't know these)
- `OwnerState` --references--> `CanonicalRecord`  [EXTRACTED]
  backend/src/agents/context.ts → backend/src/contracts/entities.ts
- `getDeps()` --indirect_call--> `defaultModelFactory()`  [INFERRED]
  backend/src/http/deps.ts → backend/src/ai/providers.ts
- `TransactionPayloadSchema` --calls--> `localDateOf()`  [EXTRACTED]
  backend/src/contracts/entities.ts → backend/src/contracts/primitives.ts
- `agentDeps()` --calls--> `UserScope`  [EXTRACTED]
  backend/src/routes/agent.ts → backend/src/store/scope.ts
- `deps()` --calls--> `MemoryStore`  [EXTRACTED]
  backend/test/http.test.ts → backend/src/store/memory.ts

## Import Cycles
- None detected.

## Communities (132 total, 10 thin omitted)

### Community 0 - "app_database.dart"
Cohesion: 0.01
Nodes (223): _, accountId, _accountIdMeta, action, _actionMeta, activityCreated, actualTableName, agentType (+215 more)

### Community 1 - "tables.dart"
Cohesion: 0.02
Nodes (101): accountId, action, agentType, aiEnabled, amountMinor, archived, attempts, baseCurrency (+93 more)

### Community 2 - "entities.ts"
Cohesion: 0.05
Nodes (58): Action, ActionSchema, ChangesQuerySchema, ClassifyRequest, ClassifyRequestSchema, ClassifyResponse, Confirmation, ConfirmationSchema (+50 more)

### Community 3 - "_"
Cohesion: 0.03
Nodes (53): _, acknowledgeAccepted, applyMine, applyPage, applyRecord, _blockDependents, Clock, Confirmation (+45 more)

### Community 4 - "entry_sheet.dart"
Cohesion: 0.04
Nodes (54): _accountId, _aiLoading, _aiMessage, _amount, _apply, _cancel, _cancelAi, _categoryFields (+46 more)

### Community 5 - "transactions_screen.dart"
Cohesion: 0.05
Nodes (32): ActivityView, a, ActivityScreen, _ActivityScreenState, _ActivityTile, _agentLabel, build, createState (+24 more)

### Community 6 - "onboarding_screen.dart"
Cohesion: 0.05
Nodes (43): profileRepositoryProvider, _SourceDialog, _AccountsStep, _accountTypes, _add, _ai, _AiStep, _busy (+35 more)

### Community 7 - "rules.ts"
Cohesion: 0.07
Nodes (43): OwnerState, AccountRef, applyRules(), capitalize(), categoryByNames(), CategoryRef, DEPOSIT_WORDS, EXPENSE_WORDS (+35 more)

### Community 8 - "profileProvider"
Cohesion: 0.11
Nodes (44): accountBalancesProvider, activeAccountsProvider, categoriesProvider, categoryRepositoryProvider, clockProvider, incomeSourcesProvider, ledgerRepositoryProvider, localStoreProvider (+36 more)

### Community 9 - "parse.ts"
Cohesion: 0.14
Nodes (39): CategorySuggestion, classifyTransaction(), persist(), suggestCategory(), consentStatus(), historyCategory(), loadOwnerState(), Begin (+31 more)

### Community 10 - "agent_repository.dart"
Cohesion: 0.05
Nodes (38): AgentRepository, aiMessage, api, candidate, confidence, createdAt, _db, dismissInsight (+30 more)

### Community 11 - "agent.ts"
Cohesion: 0.09
Nodes (24): UuidSchema, ApiError, ERROR_STATUS, ErrorCode, RETRYABLE, SAFE_MESSAGES, zodIssuesToFields(), errorName() (+16 more)

### Community 12 - "transaction_detail_screen.dart"
Cohesion: 0.06
Nodes (24): InsightView, ProposalView, insight, _showEvidence, stale, createState, currency, exponent (+16 more)

### Community 13 - "DataClass"
Cohesion: 0.10
Nodes (36): AccountRow, AccountsCompanion, ActivityRow, AgentRunRow, AgentRunsCompanion, AiActivitiesCompanion, AiInsightsCompanion, AiProposalsCompanion (+28 more)

### Community 14 - "shared.dart"
Cohesion: 0.09
Nodes (31): reviewCountProvider, AccountsScreen, build, showCreateAccountDialog, build, build, HomeScreen, budgetMonthProvider (+23 more)

### Community 15 - "quick_parser.dart"
Cohesion: 0.05
Nodes (35): accountId, amountText, byToken, cash, categoryId, description, destinationId, draft (+27 more)

### Community 16 - "daily.ts"
Cohesion: 0.16
Nodes (28): activeRecords(), loadParseContext(), checkpoint(), cleanup(), finishRun(), ItemOutcome, JobResult, Lease (+20 more)

### Community 17 - "transaction.dart"
Cohesion: 0.06
Nodes (30): accountId, amount, amountMinor, amountText, buildPayload, CategorizationSource, categoryId, checkAccount (+22 more)

### Community 18 - "providers.ts"
Cohesion: 0.08
Nodes (26): description, engines, node, @types/node, typescript, name, private, scripts (+18 more)

### Community 19 - "budgets_screen.dart"
Cohesion: 0.07
Nodes (22): budgetRepositoryProvider, _amount, BudgetsScreen, _BudgetsScreenState, categories, _category, createState, currency (+14 more)

### Community 20 - "service.ts"
Cohesion: 0.08
Nodes (29): AccountPayload, AppSettingsPayload, BudgetPayload, CanonicalMutation, CategorizationRulePayload, CategoryPayload, Change, COLLECTION_BY_ENTITY (+21 more)

### Community 21 - "ledger_repository.dart"
Cohesion: 0.06
Nodes (30): accountId, accountName, _accounts, _categories, categoryId, categoryName, confirmCreate, confirmDelete (+22 more)

### Community 22 - "package.json"
Cohesion: 0.07
Nodes (27): @types/node, typescript, name, private, scripts, build, dev, lint (+19 more)

### Community 23 - "sign_in_screen.dart"
Cohesion: 0.08
Nodes (26): authRepositoryProvider, sessionProvider, build, _busy, createState, dispose, _email, _error (+18 more)

### Community 24 - "transaction_actions.dart"
Cohesion: 0.06
Nodes (30): acceptCategoryProposal, account, _accounts, amount, c, _categories, category, categoryId (+22 more)

### Community 25 - "agents.test.ts"
Cohesion: 0.15
Nodes (24): confirmationHashInput(), validateBatch(), ai, parseEnv(), Script, scripted(), account(), category() (+16 more)

### Community 26 - "api_client.dart"
Cohesion: 0.07
Nodes (24): FirebaseCredentials, appCheckToken, changes, classifyTransaction, code, credentials, CredentialSource, dio (+16 more)

### Community 27 - "money.dart"
Cohesion: 0.07
Nodes (26): abs, allowZero, _ambiguousComma, body, buffer, checkedSum, _decimal, digits (+18 more)

### Community 28 - "providers.dart"
Cohesion: 0.08
Nodes (19): agentRepositoryProvider, api, apiClientProvider, appCheckToken, client, databaseProvider, db, _debounce (+11 more)

### Community 29 - "router.dart"
Cohesion: 0.07
Nodes (6): build, false, onboardingStateProvider, ping, profile, refresh

### Community 30 - "agents/insights.ts"
Cohesion: 0.15
Nodes (20): buildInsights(), formatMinor(), InsightDraft, InsightFacts, median(), balance(), effect(), LedgerTransaction (+12 more)

### Community 31 - "CanonicalRecord"
Cohesion: 0.20
Nodes (8): CanonicalRecord, StoreTransaction, Conflict, ReferenceReader, Rejection, reviewStateRecord(), SyncService, ValidatedOperation

### Community 32 - "auth_repository.dart"
Cohesion: 0.08
Nodes (22): _auth, AuthRepository, currentUser, email, _googleInitialized, googleServerClientId, _guard, _message (+14 more)

### Community 33 - "budget_ai_agent_technical_document_bd08a242.md"
Cohesion: 0.07
Nodes (26): 10. Account Balance Calculation, 11. Vercel Agent API Structure, 12. Vercel Environment Variables, 13. Authentication Flow for Agent Calls, 14. Agent Tool Design, 15. LLM Routing Policy, 16. Structured AI Contracts, 17. Real-Time Transaction Flow (+18 more)

### Community 34 - "deps.ts"
Cohesion: 0.15
Nodes (18): DailyDeps, ModelFactory, AuthContext, authenticateCron(), authenticateUser(), header(), Headers, safeEqual() (+10 more)

### Community 35 - "DocStore"
Cohesion: 0.17
Nodes (9): FirestoreStore, clone(), compare(), MemoryStore, runQuery(), DocData, DocStore, QuerySpec (+1 more)

### Community 36 - "core_test.dart"
Cohesion: 0.08
Nodes (18): a, account, accounts, balances, confirm, createAccount, entries, expense (+10 more)

### Community 37 - "sync_engine.dart"
Cohesion: 0.08
Nodes (21): accepted, api, _batchSize, conflicts, _cycle, _defer, _deferAll, deferred (+13 more)

### Community 38 - "router.ts"
Cohesion: 0.13
Nodes (20): ClassifyDeps, AgentDeps, BudgetExhaustedError, BudgetLimits, dayKey(), estimateTokens(), reconcile(), Reservation (+12 more)

### Community 39 - "account_repository.dart"
Cohesion: 0.08
Nodes (21): a, account, AccountBalance, accountPayload, AccountRepository, all, balanceMinor, _balanceSql (+13 more)

### Community 40 - "http.test.ts"
Cohesion: 0.09
Nodes (12): handler(), setDepsForTesting(), consoleLogger, LogEvent, SAFE_FIELDS, silentLogger, T0, core (+4 more)

### Community 41 - "codecs.dart"
Cohesion: 0.09
Nodes (19): clientWritableTypes, companionFor, createdAt, deletedAt, _iso, localCreatedAt, localUpdatedAt, localVersion (+11 more)

### Community 42 - "Table"
Cohesion: 0.22
Nodes (19): Accounts, AgentRuns, AiActivities, AiInsights, AiProposals, Budgets, Categories, CategorizationRules (+11 more)

### Community 43 - "app_config.dart"
Cohesion: 0.09
Nodes (19): _allowDebugInRelease, _api, apiBaseUrl, _apiKey, appCheckDebug, AppConfig, AppEnv, _appId (+11 more)

### Community 44 - "result.dart"
Cohesion: 0.11
Nodes (16): AppError, code, Err, error, ErrorKind, fields, isOk, kind (+8 more)

### Community 45 - "confirmation_sheet.dart"
Cohesion: 0.09
Nodes (16): build, _busy, ConfirmRow, createState, destructive, emphasis, label, note (+8 more)

### Community 46 - "categories_screen.dart"
Cohesion: 0.10
Nodes (20): incomeSourceRepositoryProvider, ruleRepositoryProvider, _account, all, _askName, controller, _create, createState (+12 more)

### Community 47 - "budget_ai_agent_architecture_document_716bf834.md"
Cohesion: 0.09
Nodes (21): 10. Agent Capabilities, 11. Security Architecture, 12. Data Privacy Boundaries, 13. Deployment Architecture, 14. Cost-Control Strategy, 15. Future Architecture Extensions, 1. Executive Summary, 2. Architecture Goals (+13 more)

### Community 48 - "src/ledger.ts"
Cohesion: 0.19
Nodes (19): SettingsView(), SettingsViewProps, initialAccounts, initialBudgets, initialCategories, initialIncomeSources, initialProfile, initialRules (+11 more)

### Community 49 - "accounts_screen.dart"
Cohesion: 0.11
Nodes (18): accountRepositoryProvider, AccountDetailScreen, _accountTypes, _CreateAccountForm, _CreateAccountFormState, createState, _date, _editOpening (+10 more)

### Community 50 - "Architecture decisions and reconciliation"
Cohesion: 0.10
Nodes (21): ADR-01 — Flutter, Riverpod and go_router, ADR-02 — Drift is the application-facing database, ADR-03 — Firebase Spark with Vercel Hobby, ADR-04 — Gemini primary, OpenRouter fallback, ADR-05 — Integer money and one currency, ADR-06 — AI proposals require financial confirmation, ADR-07 — Vercel-mediated revision sync, ADR-08 — Atomic transfer and conflict semantics (+13 more)

### Community 51 - "transactions_test.dart"
Cohesion: 0.10
Nodes (17): choose, close, ensureVisible, enterAmount, enterText, env, f, field (+9 more)

### Community 52 - "main.dart"
Cohesion: 0.10
Nodes (9): config, _connectivity, createState, dispose, _foregroundTimer, initializeApp, loaded, main (+1 more)

### Community 53 - "category_repository.dart"
Cohesion: 0.10
Nodes (18): all, CategoryRepository, create, _db, defaults, delete, enabled, IncomeSourceRepository (+10 more)

### Community 54 - "env.ts"
Cohesion: 0.16
Nodes (15): AiEnvSchema, AppEnv, AppEnvSchema, blankToUndefined(), boolFlag, ConfigError, CoreEnvSchema, Env (+7 more)

### Community 55 - "fake_server.dart"
Cohesion: 0.10
Nodes (17): _changes, dropNextResponse, failWith, injectChange, _now, pageLimit, _process, _publish (+9 more)

### Community 56 - "App.tsx"
Cohesion: 0.22
Nodes (16): react-dom, App(), AccountsView(), AIActivityView(), BudgetsView(), CategoriesView(), Header(), HeaderProps (+8 more)

### Community 57 - "common.dart"
Cohesion: 0.11
Nodes (13): actions, build, currency, exponent, icon, info, kind, message (+5 more)

### Community 58 - "selectors.dart"
Cohesion: 0.11
Nodes (15): accounts, allowNegative, allowNone, build, categories, controller, currency, errorText (+7 more)

### Community 59 - "helpers.dart"
Cohesion: 0.11
Nodes (10): db, dispose, overrides, settle, store, testConfig, TestEnv, testNow (+2 more)

### Community 60 - "budget_repository.dart"
Cohesion: 0.11
Nodes (16): budget, BudgetProgress, BudgetRepository, categoryName, create, _db, delete, payload (+8 more)

### Community 61 - "profile_repository.dart"
Cohesion: 0.11
Nodes (15): LocalStore, _db, defaultSettings, profile, profilePayload, profilePayloadOf, ProfileRepository, saveProfile (+7 more)

### Community 62 - "time.dart"
Cohesion: 0.11
Nodes (15): addDays, d, ensureTimeZones, firstOfNextMonth, _initialized, isValidTimeZone, local, localDateOf (+7 more)

### Community 63 - "TransactionParserModal.tsx"
Cohesion: 0.37
Nodes (13): lucide-react, react, AccountsViewProps, CategoriesViewProps, DashboardProps, ManualTransactionModalProps, TransactionParserModalProps, TransactionsViewProps (+5 more)

### Community 64 - "compilerOptions"
Cohesion: 0.11
Nodes (17): compilerOptions, allowImportingTsExtensions, isolatedModules, jsx, lib, module, moduleResolution, noEmit (+9 more)

### Community 67 - "StatelessWidget"
Cohesion: 0.12
Nodes (16): _Splash, EmptyState, ErrorBanner, MoneyText, SyncBadge, AccountSelector, AmountField, CategoryPicker (+8 more)

### Community 68 - "compilerOptions"
Cohesion: 0.12
Nodes (15): compilerOptions, esModuleInterop, forceConsistentCasingInFileNames, lib, module, moduleResolution, noEmit, noImplicitOverride (+7 more)

### Community 69 - "syncControllerProvider"
Cohesion: 0.16
Nodes (13): appConfigProvider, currentUidProvider, syncControllerProvider, userProvider, routerProvider, _RouterRefresh, build, _suggestCategory (+5 more)

### Community 70 - "screens_test.dart"
Cohesion: 0.13
Nodes (6): main, dispose, _finish, main, pump, pumpWidget

### Community 71 - "Budget Agent — manual setup, step by step"
Cohesion: 0.12
Nodes (15): 10. Set your owner UID, 11. Turn on Gemini (optional, after the privacy review), 12. Check the daily agent, 13. Before a real release (not done yet), 1. Create the Firebase project, 2. Enable sign-in providers, 3. Register the Android app, 4. Deploy Firestore rules and indexes (deny-all client access) (+7 more)

### Community 72 - "ledger.dart"
Cohesion: 0.12
Nodes (15): accountId, amountMinor, balanceOf, categoryId, deleted, destinationAccountId, effect, effectiveDate (+7 more)

### Community 73 - "text.dart"
Cohesion: 0.15
Nodes (10): boundedText, codePointLength, descriptionLimit, merchantLimit, nameLimit, normalizeMerchant, normalizeText, rawInputLimit (+2 more)

### Community 74 - "src/types.ts"
Cohesion: 0.18
Nodes (11): AIActivityViewProps, AccountType, AgentType, AIActivity, AIProposal, CategorizationSource, CategoryType, IncomeSourceType (+3 more)

### Community 75 - "canonical_json.dart"
Cohesion: 0.17
Nodes (8): canonicalHash, canonicalJson, message, openingTransactionId, out, sha256Hex, toString, _write

### Community 76 - "001 — Project bootstrap"
Cohesion: 0.17
Nodes (12): 001 — Project bootstrap, Acceptance criteria, Completion evidence, Definition of done, Dependencies, Documentation updates, Goal, Implementation scope (+4 more)

### Community 77 - "002 — Authentication and session boundaries"
Cohesion: 0.17
Nodes (12): 002 — Authentication and session boundaries, Acceptance criteria, Completion evidence, Definition of done, Dependencies, Documentation updates, Goal, Implementation scope (+4 more)

### Community 78 - "003 — Local database and domain foundations"
Cohesion: 0.17
Nodes (12): 003 — Local database and domain foundations, Acceptance criteria, Completion evidence, Definition of done, Dependencies, Documentation updates, Goal, Implementation scope (+4 more)

### Community 79 - "004 — Guided onboarding"
Cohesion: 0.17
Nodes (12): 004 — Guided onboarding, Acceptance criteria, Completion evidence, Definition of done, Dependencies, Documentation updates, Goal, Implementation scope (+4 more)

### Community 80 - "005 — Accounts and opening balances"
Cohesion: 0.17
Nodes (12): 005 — Accounts and opening balances, Acceptance criteria, Completion evidence, Definition of done, Dependencies, Documentation updates, Goal, Implementation scope (+4 more)

### Community 81 - "006 — Categories and income sources"
Cohesion: 0.17
Nodes (12): 006 — Categories and income sources, Acceptance criteria, Completion evidence, Definition of done, Dependencies, Documentation updates, Goal, Implementation scope (+4 more)

### Community 82 - "007 — Confirmed income and expense ledger"
Cohesion: 0.17
Nodes (12): 007 — Confirmed income and expense ledger, Acceptance criteria, Completion evidence, Definition of done, Dependencies, Documentation updates, Goal, Implementation scope (+4 more)

### Community 83 - "008 — Transfers, withdrawals and deposits"
Cohesion: 0.17
Nodes (12): 008 — Transfers, withdrawals and deposits, Acceptance criteria, Completion evidence, Definition of done, Dependencies, Documentation updates, Goal, Implementation scope (+4 more)

### Community 84 - "009 — Mobile offline synchronization"
Cohesion: 0.17
Nodes (12): 009 — Mobile offline synchronization, Acceptance criteria, Completion evidence, Definition of done, Dependencies, Documentation updates, Goal, Implementation scope (+4 more)

### Community 85 - "010 — Authenticated Vercel backend and sync gateway"
Cohesion: 0.17
Nodes (12): 010 — Authenticated Vercel backend and sync gateway, Acceptance criteria, Completion evidence, Definition of done, Dependencies, Documentation updates, Goal, Implementation scope (+4 more)

### Community 86 - "011 — AI provider routing and budgets"
Cohesion: 0.17
Nodes (12): 011 — AI provider routing and budgets, Acceptance criteria, Completion evidence, Definition of done, Dependencies, Documentation updates, Goal, Implementation scope (+4 more)

### Community 87 - "012 — Natural-language transaction proposals"
Cohesion: 0.17
Nodes (12): 012 — Natural-language transaction proposals, Acceptance criteria, Completion evidence, Definition of done, Dependencies, Documentation updates, Goal, Implementation scope (+4 more)

### Community 88 - "013 — Categorization and explicit rule learning"
Cohesion: 0.17
Nodes (12): 013 — Categorization and explicit rule learning, Acceptance criteria, Completion evidence, Definition of done, Dependencies, Documentation updates, Goal, Implementation scope (+4 more)

### Community 89 - "014 — Idempotent daily review agent"
Cohesion: 0.17
Nodes (12): 014 — Idempotent daily review agent, Acceptance criteria, Completion evidence, Definition of done, Dependencies, Documentation updates, Goal, Implementation scope (+4 more)

### Community 90 - "015 — AI Activity and run observability"
Cohesion: 0.17
Nodes (12): 015 — AI Activity and run observability, Acceptance criteria, Completion evidence, Definition of done, Dependencies, Documentation updates, Goal, Implementation scope (+4 more)

### Community 91 - "016 — Budgets and evidence-based insights"
Cohesion: 0.17
Nodes (12): 016 — Budgets and evidence-based insights, Acceptance criteria, Completion evidence, Definition of done, Dependencies, Documentation updates, Goal, Implementation scope (+4 more)

### Community 92 - "017 — Regression, performance and recovery hardening"
Cohesion: 0.17
Nodes (12): 017 — Regression, performance and recovery hardening, Acceptance criteria, Completion evidence, Definition of done, Dependencies, Documentation updates, Goal, Implementation scope (+4 more)

### Community 93 - "018 — Security and privacy release gates"
Cohesion: 0.17
Nodes (12): 018 — Security and privacy release gates, Acceptance criteria, Completion evidence, Definition of done, Dependencies, Documentation updates, Goal, Implementation scope (+4 more)

### Community 94 - "019 — Release preparation and operator handoff"
Cohesion: 0.17
Nodes (12): 019 — Release preparation and operator handoff, Acceptance criteria, Completion evidence, Definition of done, Dependencies, Documentation updates, Goal, Implementation scope (+4 more)

### Community 95 - "System architecture"
Cohesion: 0.18
Nodes (11): AI provider flow, Authentication, Backend architecture, Containers and components, Daily execution, Flutter architecture, Offline sync, Responsibilities (+3 more)

### Community 96 - "Implementation plan"
Cohesion: 0.18
Nodes (11): Estimate and scope control, Execution order, Implementation plan, Phase 1 — Foundation and identity, Phase 2 — Local domain and onboarding, Phase 3 — Deterministic ledger, Phase 4 — Authenticated replication, Phase 5 — Interactive AI and transparency (+3 more)

### Community 97 - "devDependencies"
Cohesion: 0.18
Nodes (11): devDependencies, tailwindcss, @tailwindcss/vite, tsx, @types/express, @types/node, @types/react, @types/react-dom (+3 more)

### Community 98 - "canonical.ts"
Cohesion: 0.33
Nodes (9): canonicalHash(), canonicalJson(), CanonicalJsonError, compareCodeUnits(), openingTransactionId(), sha256Hex(), operationRequestHash(), payloadSchemaFor() (+1 more)

### Community 99 - "Endpoint inventory"
Cohesion: 0.20
Nodes (10): API contracts, Endpoint inventory, GET /api/health, GET /api/jobs/daily-agent, GET /api/v1/agent/insights, GET /api/v1/sync/changes, POST /api/v1/agent/classify-transaction, POST /api/v1/agent/parse-transaction (+2 more)

### Community 100 - "Security specification"
Cohesion: 0.20
Nodes (10): Abuse, dependencies and environment gates, App Check, Authentication and session handling, Authorization, validation and replay, Financial privacy and provider gate, Firestore security rules, Local protection, logging and recovery, Secrets and least privilege (+2 more)

### Community 101 - "UI and UX design"
Cohesion: 0.20
Nodes (10): Accounts, sources, categories and transfers, AI Activity and Insights, Design philosophy, Entry flows, History, conflicts and budgets, Home dashboard, Navigation and reusable components, Onboarding (+2 more)

### Community 102 - "pendingOpsProvider"
Cohesion: 0.33
Nodes (9): blockedOpsProvider, build, conflictsProvider, cursorProvider, pendingOpsProvider, build, MoreScreen, build (+1 more)

### Community 103 - "theme.dart"
Cohesion: 0.20
Nodes (8): AppTheme, _build, dark, expense, income, light, modeOf, teal

### Community 104 - "AI agent design"
Cohesion: 0.22
Nodes (9): AI agent design, Daily agent algorithm, Learned categorization, Observability and failure behavior, Provider abstraction and selection, Responsibilities and orchestration, Rules before models, Structured output and confidence (+1 more)

### Community 105 - "Offline synchronization"
Cohesion: 0.22
Nodes (9): Bootstrap and recovery, Deletion, idempotency and atomic transfers, Deterministic conflict policy, Local write and outbox, Offline synchronization, Pull, push, pull, Retry and device lifecycle, Source of truth and protocol (+1 more)

### Community 106 - "Deployment and operations"
Cohesion: 0.22
Nodes (9): Backup and restore, CI/CD and initial provisioning order, Configuration inventory, Cron and execution budgets, Deployment and operations, Environments, Free-tier capacity, Migrations and rollback (+1 more)

### Community 107 - "Technical specification"
Cohesion: 0.25
Nodes (8): Configuration and environments, Module boundaries, Repository contracts, Results and failures, Runtime and packages, Technical specification, Value and serialization conventions, Versioning

### Community 108 - "dependencies"
Cohesion: 0.25
Nodes (8): dependencies, clsx, express, @google/genai, lucide-react, react, react-dom, tailwind-merge

### Community 109 - "dependencies"
Cohesion: 0.29
Nodes (7): dependencies, ai, @ai-sdk/google, @ai-sdk/provider, firebase-admin, @openrouter/ai-sdk-provider, zod

### Community 110 - "Product overview"
Cohesion: 0.29
Nodes (7): AI-first experience, Domain vocabulary and scope, Future scope, Goals and success criteria, MVP requirements and coverage, Problem and differentiator, Product overview

### Community 111 - "Data model"
Cohesion: 0.29
Nodes (7): Common types and ownership, Data model, Entities, Ledger mathematics, Retention and recovery, Supporting entities and metadata, Transaction payload

### Community 112 - "Testing strategy"
Cohesion: 0.29
Nodes (7): Agent goldens and evaluation, CI and definition of done, End-to-end release scenarios, Ledger invariants, Sync fault matrix, Test layers, Testing strategy

### Community 113 - "devDependencies"
Cohesion: 0.33
Nodes (6): devDependencies, fast-check, @types/node, typescript, @vercel/node, vitest

### Community 114 - "vercel.json"
Cohesion: 0.33
Nodes (5): maxDuration, crons, functions, api/**/*.ts, $schema

### Community 115 - "Observability"
Cohesion: 0.33
Nodes (6): AgentRun and AI Activity, Correlation and events, Metrics and operating targets, Observability, Retention and incident response, Three audiences

### Community 116 - "_ConfirmationSheet"
Cohesion: 0.40
Nodes (4): _ConfirmationSheet, _ConfirmationSheetState, _BudgetDialog, _BudgetDialogState

### Community 117 - "Dashboard.tsx"
Cohesion: 0.53
Nodes (5): Dashboard(), calculateAccountBalance(), calculatePeriodExpense(), calculatePeriodIncome(), AIInsight

### Community 118 - "Coding agent instructions"
Cohesion: 0.40
Nodes (4): Architecture and invariants, Coding agent instructions, Security and coding, Task execution and completion

### Community 119 - "Budget Agent"
Cohesion: 0.40
Nodes (5): Budget Agent, Capabilities and stack, Documentation index, Local setup and workflow, Repository layout

### Community 120 - "BudgetsView.tsx"
Cohesion: 0.50
Nodes (4): BudgetsViewProps, calculateCategorySpending(), currentMonthStr, Budget

### Community 121 - "Exception"
Cohesion: 0.50
Nodes (3): UnsupportedSchemaException, CanonicalJsonException, ApiFailure

### Community 127 - "ReferenceLookup"
Cohesion: 0.67
Nodes (3): ReferenceLookup, ReferenceSnapshot, _Refs

### Community 128 - "SyncApi"
Cohesion: 0.67
Nodes (3): ApiClient, SyncApi, FakeServer

## Knowledge Gaps
- **1730 isolated node(s):** `name`, `version`, `private`, `description`, `type` (+1725 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 1898 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **10 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Data model` connect `Data model` to `daily.ts`, `03-IMPLEMENTATION-PLAN.md`?**
  _High betweenness centrality (0.066) - this node is a cross-community bridge._
- **Why does `Firestore paths and indexes` connect `daily.ts` to `Data model`?**
  _High betweenness centrality (0.066) - this node is a cross-community bridge._
- **Why does `SyncService` connect `CanonicalRecord` to `daily.ts`, `agents.test.ts`, `agent.ts`, `service.ts`?**
  _High betweenness centrality (0.024) - this node is a cross-community bridge._
- **Are the 5 inferred relationships involving `runDaily()` (e.g. with `.collection()` and `.doc()`) actually correct?**
  _`runDaily()` has 5 INFERRED edges - model-reasoned connections that need verification._
- **What connects `name`, `version`, `private` to the rest of the system?**
  _1730 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `app_database.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.00851063829787234 - nodes in this community are weakly interconnected._
- **Should `tables.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.01904761904761905 - nodes in this community are weakly interconnected._