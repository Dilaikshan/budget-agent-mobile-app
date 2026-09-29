import {
  UserProfile,
  Account,
  IncomeSource,
  Category,
  Transaction,
  Budget,
  CategorizationRule,
  AIActivity,
  AIInsight,
  AppSettings,
} from './types';
import {
  initialProfile,
  initialAccounts,
  initialIncomeSources,
  initialCategories,
  initialBudgets,
  initialRules,
  initialTransactions,
  initialSettings,
} from './ledger';

const STORAGE_KEYS = {
  PROFILE: 'budget_agent_profile_v1',
  ACCOUNTS: 'budget_agent_accounts_v1',
  INCOME_SOURCES: 'budget_agent_income_sources_v1',
  CATEGORIES: 'budget_agent_categories_v1',
  TRANSACTIONS: 'budget_agent_transactions_v1',
  BUDGETS: 'budget_agent_budgets_v1',
  RULES: 'budget_agent_rules_v1',
  ACTIVITIES: 'budget_agent_activities_v1',
  INSIGHTS: 'budget_agent_insights_v1',
  SETTINGS: 'budget_agent_settings_v1',
};

export function loadStoredData() {
  const getOrSet = <T>(key: string, defaultVal: T): T => {
    try {
      const stored = localStorage.getItem(key);
      if (stored) return JSON.parse(stored);
      localStorage.setItem(key, JSON.stringify(defaultVal));
      return defaultVal;
    } catch (e) {
      console.error(`Failed to read from localStorage [${key}]`, e);
      return defaultVal;
    }
  };

  const profile = getOrSet<UserProfile>(STORAGE_KEYS.PROFILE, initialProfile);
  const accounts = getOrSet<Account[]>(STORAGE_KEYS.ACCOUNTS, initialAccounts);
  const incomeSources = getOrSet<IncomeSource[]>(
    STORAGE_KEYS.INCOME_SOURCES,
    initialIncomeSources
  );
  const categories = getOrSet<Category[]>(
    STORAGE_KEYS.CATEGORIES,
    initialCategories
  );
  const transactions = getOrSet<Transaction[]>(
    STORAGE_KEYS.TRANSACTIONS,
    initialTransactions
  );
  const budgets = getOrSet<Budget[]>(STORAGE_KEYS.BUDGETS, initialBudgets);
  const rules = getOrSet<CategorizationRule[]>(
    STORAGE_KEYS.RULES,
    initialRules
  );
  const activities = getOrSet<AIActivity[]>(STORAGE_KEYS.ACTIVITIES, [
    {
      id: 'act-init-1',
      agentType: 'transactionParsing',
      action: 'Natural Language Parse',
      outcome: 'applied',
      summary: 'Parsed "Weekly grocery supplies at Keells" into LKR 14,850.00 expense with high rule confidence.',
      timestamp: new Date(Date.now() - 5 * 86400000).toISOString(),
      entityIds: ['tx-keells-1'],
      provider: 'rule_engine',
    },
    {
      id: 'act-init-2',
      agentType: 'dailyReview',
      action: 'Daily Ledger Invariant Audit',
      outcome: 'applied',
      summary: 'Verified double-entry consistency: transfer sum equals zero, all account balances intact.',
      timestamp: new Date().toISOString(),
      entityIds: [],
      provider: 'analytical_engine',
    },
  ]);
  const insights = getOrSet<AIInsight[]>(STORAGE_KEYS.INSIGHTS, [
    {
      id: 'ins-1',
      kind: 'dailySummary',
      title: 'Current Ledger Status',
      summary: '3 active asset accounts tracked. Net balance derived from strictly confirmed ledger entries.',
      status: 'active',
    },
    {
      id: 'ins-2',
      kind: 'spendingTrend',
      title: 'Monthly Budget Health',
      summary: 'Groceries budget is 25% utilized for the current month. Transport spending is on track.',
      status: 'active',
    },
  ]);
  const settings = getOrSet<AppSettings>(
    STORAGE_KEYS.SETTINGS,
    initialSettings
  );

  return {
    profile,
    accounts,
    incomeSources,
    categories,
    transactions,
    budgets,
    rules,
    activities,
    insights,
    settings,
  };
}

export function saveStoredData(data: {
  profile?: UserProfile;
  accounts?: Account[];
  incomeSources?: IncomeSource[];
  categories?: Category[];
  transactions?: Transaction[];
  budgets?: Budget[];
  rules?: CategorizationRule[];
  activities?: AIActivity[];
  insights?: AIInsight[];
  settings?: AppSettings;
}) {
  try {
    if (data.profile) localStorage.setItem(STORAGE_KEYS.PROFILE, JSON.stringify(data.profile));
    if (data.accounts) localStorage.setItem(STORAGE_KEYS.ACCOUNTS, JSON.stringify(data.accounts));
    if (data.incomeSources) localStorage.setItem(STORAGE_KEYS.INCOME_SOURCES, JSON.stringify(data.incomeSources));
    if (data.categories) localStorage.setItem(STORAGE_KEYS.CATEGORIES, JSON.stringify(data.categories));
    if (data.transactions) localStorage.setItem(STORAGE_KEYS.TRANSACTIONS, JSON.stringify(data.transactions));
    if (data.budgets) localStorage.setItem(STORAGE_KEYS.BUDGETS, JSON.stringify(data.budgets));
    if (data.rules) localStorage.setItem(STORAGE_KEYS.RULES, JSON.stringify(data.rules));
    if (data.activities) localStorage.setItem(STORAGE_KEYS.ACTIVITIES, JSON.stringify(data.activities));
    if (data.insights) localStorage.setItem(STORAGE_KEYS.INSIGHTS, JSON.stringify(data.insights));
    if (data.settings) localStorage.setItem(STORAGE_KEYS.SETTINGS, JSON.stringify(data.settings));
  } catch (err) {
    console.error('Failed to write to localStorage', err);
  }
}

export function exportBackupJson() {
  const data = loadStoredData();
  const exportPayload = {
    version: '1.0.0',
    exportedAt: new Date().toISOString(),
    ...data,
  };
  return JSON.stringify(exportPayload, null, 2);
}

export function importBackupJson(jsonString: string): boolean {
  try {
    const parsed = JSON.parse(jsonString);
    if (!parsed || !parsed.accounts || !parsed.transactions) {
      throw new Error('Invalid backup schema');
    }
    saveStoredData({
      profile: parsed.profile,
      accounts: parsed.accounts,
      incomeSources: parsed.incomeSources,
      categories: parsed.categories,
      transactions: parsed.transactions,
      budgets: parsed.budgets,
      rules: parsed.rules,
      activities: parsed.activities,
      insights: parsed.insights,
      settings: parsed.settings,
    });
    return true;
  } catch (e) {
    console.error('Import failed', e);
    return false;
  }
}

export function resetAllDataToSeed() {
  localStorage.clear();
  return loadStoredData();
}

// Rule matching utility
export function matchCategorizationRule(
  text: string,
  merchant: string | null,
  rules: CategorizationRule[],
  type: 'income' | 'expense'
): CategorizationRule | null {
  const lowerText = text.toLowerCase();
  const lowerMerchant = merchant ? merchant.toLowerCase() : '';

  const activeRules = rules
    .filter((r) => r.enabled && r.transactionType === type)
    .sort((a, b) => b.priority - a.priority);

  for (const rule of activeRules) {
    const pat = rule.normalizedPattern.toLowerCase();
    if (rule.matchKind === 'merchantExact') {
      if (lowerMerchant === pat || lowerText === pat) {
        return rule;
      }
    } else {
      // keyword
      if (lowerMerchant.includes(pat) || lowerText.includes(pat)) {
        return rule;
      }
    }
  }

  return null;
}
