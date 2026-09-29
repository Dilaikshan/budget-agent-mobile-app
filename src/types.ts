export type AccountType = 'bank' | 'cash' | 'wallet' | 'savings';
export type IncomeSourceType = 'employer' | 'freelance' | 'business' | 'investment' | 'other';
export type CategoryType = 'income' | 'expense';
export type TransactionType = 'expense' | 'income' | 'transfer' | 'opening';
export type OpeningDirection = 'credit' | 'debit';
export type CategorizationSource = 'manual' | 'rule' | 'ai';
export type MatchKind = 'merchantExact' | 'keyword';
export type AgentType = 'transactionParsing' | 'categorization' | 'accountSuggestion' | 'dailyReview' | 'patternLearning' | 'insight';

export interface UserProfile {
  id: 'profile';
  displayName: string;
  baseCurrency: string;
  currencyExponent: number; // 2 for cents/cents equivalent
  timeZone: string;
  onboardingComplete: boolean;
}

export interface Account {
  id: string;
  name: string;
  type: AccountType;
  currency: string;
  archived: boolean;
  sortOrder: number;
}

export interface IncomeSource {
  id: string;
  name: string;
  type: IncomeSourceType;
  defaultAccountId: string | null;
  archived: boolean;
}

export interface Category {
  id: string;
  name: string;
  type: CategoryType;
  parentId: string | null;
  icon: string | null;
  sortOrder: number;
  isSystem: boolean;
  archived: boolean;
}

export interface Transaction {
  id: string;
  type: TransactionType;
  amountMinor: number; // Integer minor units (e.g. 1500.50 -> 150050)
  currency: string;
  accountId: string; // Source or funding account, or target for income
  destinationAccountId: string | null; // For transfer only
  incomeSourceId: string | null; // For income only
  categoryId: string | null; // For expense or income
  merchant: string | null;
  description: string;
  occurredAt: string; // ISO string
  effectiveDate: string; // YYYY-MM-DD
  entryTimeZone: string;
  origin: 'manual' | 'aiInput' | 'opening';
  categorizationSource: CategorizationSource | null;
  proposalId: string | null;
  openingDirection: OpeningDirection | null;
}

export interface Budget {
  id: string;
  month: string; // YYYY-MM
  categoryId: string;
  limitMinor: number; // Integer minor units
  currency: string;
}

export interface CategorizationRule {
  id: string;
  matchKind: MatchKind;
  normalizedPattern: string;
  transactionType: 'income' | 'expense';
  categoryId: string;
  suggestedAccountId: string | null;
  suggestedIncomeSourceId: string | null;
  priority: number;
  enabled: boolean;
  origin: 'user' | 'acceptedSuggestion';
  evidenceTransactionIds?: string[];
}

export interface AIProposal {
  id: string;
  rawInput: string;
  candidate: {
    type: TransactionType;
    amountMinor: number;
    currency: string;
    accountId: string | null;
    destinationAccountId: string | null;
    categoryId: string | null;
    incomeSourceId: string | null;
    merchant: string | null;
    description: string;
    confidence: number;
    fieldConfidence: Record<string, number>;
    reasoning: string;
  };
  provider: string;
  status: 'pending' | 'accepted' | 'rejected';
  createdAt: string;
}

export interface AIActivity {
  id: string;
  agentType: AgentType;
  action: string;
  outcome: 'proposed' | 'applied' | 'skipped' | 'failed' | 'needsReview';
  summary: string;
  timestamp: string;
  entityIds: string[];
  provider?: string;
  latencyMs?: number;
}

export interface AIInsight {
  id: string;
  kind: 'dailySummary' | 'spendingTrend' | 'recurringPattern' | 'consistency';
  title: string;
  summary: string;
  status: 'active' | 'dismissed';
  sourceWatermark?: number;
}

export interface AppSettings {
  id: 'settings';
  theme: 'system' | 'light' | 'dark';
  aiEnabled: boolean;
  dailyReviewEnabled: boolean;
  learningEnabled: boolean;
  fallbackEnabled: boolean;
  defaultExpenseAccountId: string | null;
}
