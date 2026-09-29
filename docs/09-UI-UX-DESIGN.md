# UI and UX design

## Design philosophy

Make recording money feel like a short conversation with a reliable notebook. Lead with today's activity, available account balances and a useful review prompt. Avoid imitation credit cards, promotional banking banners, trading tickers and decorative financial claims. AI is visible through quick input, suggestions and explanations without competing with the ledger.

Light theme uses a warm neutral background, dark text and a restrained teal action color; dark theme uses near-black surfaces and high-contrast text. Income/expense colors are supplemented by labels and signs. Use consistent 8-point spacing, readable 16-point body text and platform-native typography. Respect system theme and text size. Financial amounts align for scanning and always show currency when context could be ambiguous.

## Navigation and reusable components

Bottom navigation: Home, Transactions, Insights, More. Persistent “Add” action opens AI quick input with an adjacent category-entry option. More contains Accounts, Categories, Income Sources, Budgets, AI Activity and Settings. Route guards distinguish signed-out, email-verification, onboarding and ready states without throwing away saved drafts.

Reusable components: MoneyText, AmountInput, AccountSelector, CategoryPicker, IncomeSourceSelector, DatePicker, TransactionProposalCard, ConfidenceHint, ConfirmationSheet, SyncBadge, ConflictComparison, InsightCard, AIActivityRow, EmptyState and ErrorBanner. ConfirmationSheet is shared by both entry paths; selector widgets expose archived/reference errors consistently.

## Onboarding

1. Sign in with Google or email/password; show verification/resend/reset-password actions and clear network errors. No personal ledger bootstrap before verified owner access.
2. Explain Account (“where money is”), IncomeSource (“where income came from”), Category (“what it is for”) and Transfer with Bank → Cash example.
3. Confirm base currency (LKR default) and timezone (Asia/Colombo default). Explain currency cannot change after opening entries in MVP.
4. Create at least one account, suggest Cash Wallet and Primary Bank without auto-creating them. Enter signed opening balances with effective dates; show exact confirmation, including zero.
5. Install default income/expense category tree after user accepts it. Create at least one income source or skip until first income. Explain that sources do not hold balances.
6. Explain AI proposals, uncertainty, learned rules, provider data sharing and Activity. Offer independent opt-in controls with privacy eligibility status; no model keys on mobile. Complete onboarding only after required local entities are saved atomically. Sync may remain pending.

Default categories are editable two-level roots/children (Food/Restaurant, Transport, Bills, Shopping, Salary, Freelance). Do not use account names as income sources or spending categories.

## Home dashboard

Show total recorded balance (including archived accounts), active account balances, month-to-date income/expense and budget progress. Label the total as “Recorded balance,” not bank-verified balance. Opening/transfer events are excluded from income/expense cards. Include one daily-review card with count and “Review suggestions,” one useful insight if available, and recent transactions.

Local pending/conflicted changes carry a badge near totals. “Last synced” reports successful cursor catch-up, not last attempt. An AI result based on older synced data says so; never hide pending amounts to match a remote summary.

## Entry flows

Quick input preserves text as a Draft. Enter “lunch kfc 2500 cash”; show local candidate immediately, then optional online enhancement. While awaiting AI, the category/manual form remains editable. A late response cannot overwrite user edits; compare draft version and offer it as a separate suggestion. Cancel stops inference request and preserves draft.

Category entry: choose expense/income → category/root or child → amount → funding/destination account; income adds source. Category-first and AI entry both construct the same Draft and use the same validators. Transfer has a separate From → To editor, not an expense category. “Swap accounts” is an explicit action.

Confirmation shows type, currency/amount, account direction, category/source, merchant and date, plus provenance where AI supplied a field. Required missing fields block Save with field-specific messages; unknown category may be saved only for expense and appears in review queue. All fields can be edited. High confidence never removes confirmation. Double-tapping Save produces one operation through a disabled in-flight control plus stable command ID.

After Save: immediately show the transaction and changed local balance with pending badge, retain undo as an explicitly confirmed delete action, and optionally ask “Remember this merchant category?” as a separate choice. Do not make rule learning a prerequisite for saving.

## Accounts, sources, categories and transfers

Accounts show name/type/currency, ledger-derived balance and chronological activity. Opening balance is a visible entry; editing it previews before/after balance and requires confirmation. Archive hides an account from new selectors but keeps its historical effect in total wealth. Negative balances show a neutral warning without preventing accurate recording.

Category/source managers support create, rename, archive and sort; parent/type restrictions explain why an existing referenced category cannot be reorganized silently. Source default account is a suggestion only. Transfer confirmation emphasizes equal amount leaving and entering two distinct accounts, with “Not counted as spending or income.” Deposit/withdrawal input that lacks an origin/destination asks for the missing account.

## History, conflicts and budgets

History filters by type, account, category, income source, date and sync/review state. Each row identifies account direction, amount and date; transfer rows use arrows and no income/expense color semantics. Detail shows editable fields, confirmed status, categorization provenance, related AI Activity and remote sync status.

Conflict comparison shows “Saved on this device” and “Accepted from another device” side by side, including original values. Actions are Keep remote or Review and apply mine. Any financially different result goes through ConfirmationSheet again. Never offer a misleading generic Retry for revision conflicts.

Budgets are monthly category limits with spent/remaining and an accessible progress bar. Parent includes children once; prevent overlapping parent/child budgets for a month with a clear explanation. No rollover or predicted future transactions. Edit and delete are ordinary explicit user actions; budgets do not affect account balances.

## AI Activity and Insights

AI Activity is a chronological timeline with outcome, logical agent, short explanation, provider/model (expandable), rule matches and links to proposals/evidence. Filters: needs review, applied, skipped, failed. Separate a proposed category from a confirmed change. A “No AI call needed” record explains a rule match; avoid noisy duplicate rows on retry.

Insights show period, deterministic facts, supporting transactions and data coverage. Trends require comparable complete periods. Recurring-pattern cards say “Possible recurring expense” with examples, not “Payment scheduled.” Users can dismiss insights and reject suggestions; accepting a financial suggestion opens the normal confirmation flow. Stale/expired proposals offer re-review or explicit manual entry, never silent acceptance.

## Settings and states

Settings: theme, timezone, immutable base-currency explanation, default account, AI/fallback/daily/learning controls, reviewed privacy policy, sync queue/conflicts, manual Sync now, export/restore, sign out and app version. Model credentials/configuration are operator deployment settings, not a mobile API-key form.

| State | Behavior |
|---|---|
| Loading | Skeleton for local database startup; bounded progress for sync/AI; no blocking full-screen spinner during ordinary entry |
| Empty | Home teaches account setup; history offers both entry methods; insights explain data needed |
| Offline | Persistent compact badge; deterministic entry available; remote AI action explains availability |
| AI failure | Keep draft and selectors; manual completion CTA; optional retry with a fresh explicit request |
| Sync pending | Show queued count and last successful sync; local save remains successful |
| Auth/network blocked | Explain sign-in/verification requirement for sync; retain local records |
| Storage error | Do not claim saved; preserve draft in memory and offer retry/export if possible |
| Conflict | Retain local overlay, label uncertain remote agreement and show comparison |
| Partial daily run | Show last completed coverage, pending review count and safe error summary |

Accessibility: ≥48 logical-pixel touch targets, semantic labels for every icon/chart/amount, keyboard/screen-reader traversal, 200% text scaling, AA contrast, reduced-motion support and no color-only meaning. Use locale-aware formatted amounts but deterministic parsing. Manual device checks include TalkBack, dark mode, long account names and large values.
