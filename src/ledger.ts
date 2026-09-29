import {
  Account,
  Category,
  IncomeSource,
  Transaction,
  Budget,
  CategorizationRule,
  UserProfile,
  AppSettings,
} from './types';

// Format integer minor units to currency string e.g. LKR 1,500.00
export function formatMoney(
  amountMinor: number,
  currency: string = 'LKR',
  exponent: number = 2
): string {
  const isNegative = amountMinor < 0;
  const absMinor = Math.abs(amountMinor);
  const factor = Math.pow(10, exponent);
  const major = Math.floor(absMinor / factor);
  const minor = absMinor % factor;
  const minorStr = minor.toString().padStart(exponent, '0');
  const majorStr = major.toLocaleString('en-US');
  const sign = isNegative ? '-' : '';
  return `${sign}${currency} ${majorStr}.${minorStr}`;
}

// Convert user decimal input (e.g. "1500.50") to integer minor units (150050)
export function parseMoneyToMinor(
  input: string | number,
  exponent: number = 2
): number {
  if (typeof input === 'number') {
    return Math.round(input * Math.pow(10, exponent));
  }
  const clean = input.replace(/[^0-9.-]/g, '');
  const val = parseFloat(clean);
  if (isNaN(val)) return 0;
  return Math.round(val * Math.pow(10, exponent));
}

// Effect of transaction on an account:
// +m(t) if income and accountId=a
// -m(t) if expense and accountId=a
// -m(t) if transfer and accountId=a
// +m(t) if transfer and destinationAccountId=a
// d(t)*m(t) if opening and accountId=a (+1 for credit, -1 for debit)
export function calculateAccountBalance(
  accountId: string,
  transactions: Transaction[]
): number {
  return transactions.reduce((acc, t) => {
    if (t.type === 'income' && t.accountId === accountId) {
      return acc + t.amountMinor;
    }
    if (t.type === 'expense' && t.accountId === accountId) {
      return acc - t.amountMinor;
    }
    if (t.type === 'transfer') {
      if (t.accountId === accountId) {
        return acc - t.amountMinor;
      }
      if (t.destinationAccountId === accountId) {
        return acc + t.amountMinor;
      }
    }
    if (t.type === 'opening' && t.accountId === accountId) {
      const sign = t.openingDirection === 'debit' ? -1 : 1;
      return acc + sign * t.amountMinor;
    }
    return acc;
  }, 0);
}

// Net worth is the sum of balances across all accounts
export function calculateNetWorth(
  accounts: Account[],
  transactions: Transaction[]
): number {
  return accounts.reduce(
    (sum, a) => sum + calculateAccountBalance(a.id, transactions),
    0
  );
}

// Income sum for a specific period
export function calculatePeriodIncome(
  transactions: Transaction[],
  startDate?: string,
  endDate?: string
): number {
  return transactions
    .filter(
      (t) =>
        t.type === 'income' &&
        (!startDate || t.effectiveDate >= startDate) &&
        (!endDate || t.effectiveDate <= endDate)
    )
    .reduce((sum, t) => sum + t.amountMinor, 0);
}

// Expense sum for a specific period
export function calculatePeriodExpense(
  transactions: Transaction[],
  startDate?: string,
  endDate?: string
): number {
  return transactions
    .filter(
      (t) =>
        t.type === 'expense' &&
        (!startDate || t.effectiveDate >= startDate) &&
        (!endDate || t.effectiveDate <= endDate)
    )
    .reduce((sum, t) => sum + t.amountMinor, 0);
}

// Spending for a specific category in a month (YYYY-MM)
export function calculateCategorySpending(
  categoryId: string,
  transactions: Transaction[],
  month: string // YYYY-MM
): number {
  return transactions
    .filter(
      (t) =>
        t.type === 'expense' &&
        t.categoryId === categoryId &&
        t.effectiveDate.startsWith(month)
    )
    .reduce((sum, t) => sum + t.amountMinor, 0);
}

// Strict payload validator per AGENTS.md and 04-DATA-MODEL.md invariants
export function validateTransaction(
  t: Partial<Transaction>,
  accounts: Account[],
  categories: Category[],
  incomeSources: IncomeSource[]
): string | null {
  if (!t.type) return 'Transaction type is required.';

  if (t.type === 'opening') {
    if (typeof t.amountMinor !== 'number' || t.amountMinor < 0) {
      return 'Opening balance amount must be zero or positive integer.';
    }
    if (!t.accountId || !accounts.some((a) => a.id === t.accountId)) {
      return 'Valid account ID is required.';
    }
    if (!t.openingDirection || !['credit', 'debit'].includes(t.openingDirection)) {
      return 'Opening direction must be credit or debit.';
    }
    return null;
  }

  if (typeof t.amountMinor !== 'number' || t.amountMinor <= 0) {
    return 'Amount must be a positive integer in minor units.';
  }

  if (!t.accountId || !accounts.some((a) => a.id === t.accountId)) {
    return 'Valid funding/primary account is required.';
  }

  if (t.type === 'expense') {
    if (t.destinationAccountId) {
      return 'Expense cannot have a destination account.';
    }
    if (t.incomeSourceId) {
      return 'Expense cannot have an income source.';
    }
    if (t.categoryId) {
      const cat = categories.find((c) => c.id === t.categoryId);
      if (!cat || cat.type !== 'expense') {
        return 'Expense category must be of type expense.';
      }
    }
  } else if (t.type === 'income') {
    if (t.destinationAccountId) {
      return 'Income cannot have a destination account.';
    }
    if (!t.incomeSourceId || !incomeSources.some((s) => s.id === t.incomeSourceId)) {
      return 'Income requires an income source identifying the origin.';
    }
    if (!t.categoryId) {
      return 'Income requires an income category.';
    }
    const cat = categories.find((c) => c.id === t.categoryId);
    if (!cat || cat.type !== 'income') {
      return 'Income category must be of type income.';
    }
  } else if (t.type === 'transfer') {
    if (!t.destinationAccountId) {
      return 'Transfer requires a distinct destination account.';
    }
    if (t.destinationAccountId === t.accountId) {
      return 'Transfer source and destination accounts must be different.';
    }
    if (t.categoryId) {
      return 'Transfer cannot have a category.';
    }
    if (t.incomeSourceId) {
      return 'Transfer cannot have an income source.';
    }
  }

  return null;
}

// Initial seed data with authentic Sri Lankan context (LKR, ComBank, Keells, etc.)
export const initialProfile: UserProfile = {
  id: 'profile',
  displayName: 'Dilaikshan',
  baseCurrency: 'LKR',
  currencyExponent: 2,
  timeZone: 'Asia/Colombo',
  onboardingComplete: true,
};

export const initialSettings: AppSettings = {
  id: 'settings',
  theme: 'dark',
  aiEnabled: true,
  dailyReviewEnabled: true,
  learningEnabled: true,
  fallbackEnabled: true,
  defaultExpenseAccountId: 'acc-combank',
};

export const initialAccounts: Account[] = [
  {
    id: 'acc-combank',
    name: 'Commercial Bank Checking',
    type: 'bank',
    currency: 'LKR',
    archived: false,
    sortOrder: 1,
  },
  {
    id: 'acc-cash',
    name: 'Cash in Hand',
    type: 'cash',
    currency: 'LKR',
    archived: false,
    sortOrder: 2,
  },
  {
    id: 'acc-savings',
    name: 'BOC Savings',
    type: 'savings',
    currency: 'LKR',
    archived: false,
    sortOrder: 3,
  },
  {
    id: 'acc-wallet',
    name: 'FriMi Digital Wallet',
    type: 'wallet',
    currency: 'LKR',
    archived: false,
    sortOrder: 4,
  },
];

export const initialIncomeSources: IncomeSource[] = [
  {
    id: 'src-salary',
    name: 'Primary Salary (Virtusa)',
    type: 'employer',
    defaultAccountId: 'acc-combank',
    archived: false,
  },
  {
    id: 'src-freelance',
    name: 'Upwork Freelancing',
    type: 'freelance',
    defaultAccountId: 'acc-combank',
    archived: false,
  },
  {
    id: 'src-investments',
    name: 'Treasury Bills & Interest',
    type: 'investment',
    defaultAccountId: 'acc-savings',
    archived: false,
  },
];

export const initialCategories: Category[] = [
  // Expense categories
  {
    id: 'cat-groceries',
    name: 'Groceries & Household',
    type: 'expense',
    parentId: null,
    icon: 'ShoppingCart',
    sortOrder: 1,
    isSystem: true,
    archived: false,
  },
  {
    id: 'cat-dining',
    name: 'Dining & Restaurants',
    type: 'expense',
    parentId: null,
    icon: 'Utensils',
    sortOrder: 2,
    isSystem: true,
    archived: false,
  },
  {
    id: 'cat-transport',
    name: 'Transport & Fuel',
    type: 'expense',
    parentId: null,
    icon: 'Car',
    sortOrder: 3,
    isSystem: true,
    archived: false,
  },
  {
    id: 'cat-utilities',
    name: 'Bills & Utilities',
    type: 'expense',
    parentId: null,
    icon: 'Zap',
    sortOrder: 4,
    isSystem: true,
    archived: false,
  },
  {
    id: 'cat-health',
    name: 'Healthcare & Medical',
    type: 'expense',
    parentId: null,
    icon: 'HeartPulse',
    sortOrder: 5,
    isSystem: true,
    archived: false,
  },
  {
    id: 'cat-entertainment',
    name: 'Entertainment & Leisure',
    type: 'expense',
    parentId: null,
    icon: 'Film',
    sortOrder: 6,
    isSystem: true,
    archived: false,
  },
  // Income categories
  {
    id: 'cat-salary-inc',
    name: 'Employment Salary',
    type: 'income',
    parentId: null,
    icon: 'Briefcase',
    sortOrder: 10,
    isSystem: true,
    archived: false,
  },
  {
    id: 'cat-freelance-inc',
    name: 'Freelance & Contract',
    type: 'income',
    parentId: null,
    icon: 'Laptop',
    sortOrder: 11,
    isSystem: true,
    archived: false,
  },
  {
    id: 'cat-passive-inc',
    name: 'Investment Returns',
    type: 'income',
    parentId: null,
    icon: 'TrendingUp',
    sortOrder: 12,
    isSystem: true,
    archived: false,
  },
];

// Helper to get formatted current month YYYY-MM
export const currentMonthStr = new Date().toISOString().slice(0, 7);
export const todayDateStr = new Date().toISOString().slice(0, 10);

export const initialBudgets: Budget[] = [
  {
    id: 'b-groceries',
    month: currentMonthStr,
    categoryId: 'cat-groceries',
    limitMinor: 6000000, // LKR 60,000.00
    currency: 'LKR',
  },
  {
    id: 'b-dining',
    month: currentMonthStr,
    categoryId: 'cat-dining',
    limitMinor: 2500000, // LKR 25,000.00
    currency: 'LKR',
  },
  {
    id: 'b-transport',
    month: currentMonthStr,
    categoryId: 'cat-transport',
    limitMinor: 3000000, // LKR 30,000.00
    currency: 'LKR',
  },
  {
    id: 'b-utilities',
    month: currentMonthStr,
    categoryId: 'cat-utilities',
    limitMinor: 2000000, // LKR 20,000.00
    currency: 'LKR',
  },
];

export const initialRules: CategorizationRule[] = [
  {
    id: 'rule-keells',
    matchKind: 'keyword',
    normalizedPattern: 'keells',
    transactionType: 'expense',
    categoryId: 'cat-groceries',
    suggestedAccountId: 'acc-combank',
    suggestedIncomeSourceId: null,
    priority: 10,
    enabled: true,
    origin: 'acceptedSuggestion',
  },
  {
    id: 'rule-cargills',
    matchKind: 'keyword',
    normalizedPattern: 'cargills',
    transactionType: 'expense',
    categoryId: 'cat-groceries',
    suggestedAccountId: 'acc-combank',
    suggestedIncomeSourceId: null,
    priority: 10,
    enabled: true,
    origin: 'acceptedSuggestion',
  },
  {
    id: 'rule-uber',
    matchKind: 'keyword',
    normalizedPattern: 'uber',
    transactionType: 'expense',
    categoryId: 'cat-transport',
    suggestedAccountId: 'acc-combank',
    suggestedIncomeSourceId: null,
    priority: 8,
    enabled: true,
    origin: 'acceptedSuggestion',
  },
  {
    id: 'rule-dialog',
    matchKind: 'keyword',
    normalizedPattern: 'dialog',
    transactionType: 'expense',
    categoryId: 'cat-utilities',
    suggestedAccountId: 'acc-combank',
    suggestedIncomeSourceId: null,
    priority: 8,
    enabled: true,
    origin: 'acceptedSuggestion',
  },
];

export const initialTransactions: Transaction[] = [
  // Opening balances for accounts
  {
    id: 'op-combank',
    type: 'opening',
    amountMinor: 18500000, // LKR 185,000.00
    currency: 'LKR',
    accountId: 'acc-combank',
    destinationAccountId: null,
    incomeSourceId: null,
    categoryId: null,
    merchant: null,
    description: 'Initial Opening Balance - Commercial Bank',
    occurredAt: new Date(Date.now() - 25 * 86400000).toISOString(),
    effectiveDate: new Date(Date.now() - 25 * 86400000).toISOString().slice(0, 10),
    entryTimeZone: 'Asia/Colombo',
    origin: 'opening',
    categorizationSource: null,
    proposalId: null,
    openingDirection: 'credit',
  },
  {
    id: 'op-cash',
    type: 'opening',
    amountMinor: 2500000, // LKR 25,000.00
    currency: 'LKR',
    accountId: 'acc-cash',
    destinationAccountId: null,
    incomeSourceId: null,
    categoryId: null,
    merchant: null,
    description: 'Initial Opening Balance - Physical Cash',
    occurredAt: new Date(Date.now() - 25 * 86400000).toISOString(),
    effectiveDate: new Date(Date.now() - 25 * 86400000).toISOString().slice(0, 10),
    entryTimeZone: 'Asia/Colombo',
    origin: 'opening',
    categorizationSource: null,
    proposalId: null,
    openingDirection: 'credit',
  },
  {
    id: 'op-savings',
    type: 'opening',
    amountMinor: 50000000, // LKR 500,000.00
    currency: 'LKR',
    accountId: 'acc-savings',
    destinationAccountId: null,
    incomeSourceId: null,
    categoryId: null,
    merchant: null,
    description: 'Initial Opening Balance - BOC Savings',
    occurredAt: new Date(Date.now() - 25 * 86400000).toISOString(),
    effectiveDate: new Date(Date.now() - 25 * 86400000).toISOString().slice(0, 10),
    entryTimeZone: 'Asia/Colombo',
    origin: 'opening',
    categorizationSource: null,
    proposalId: null,
    openingDirection: 'credit',
  },
  // Sample salary income
  {
    id: 'tx-salary-1',
    type: 'income',
    amountMinor: 22000000, // LKR 220,000.00
    currency: 'LKR',
    accountId: 'acc-combank',
    destinationAccountId: null,
    incomeSourceId: 'src-salary',
    categoryId: 'cat-salary-inc',
    merchant: 'Virtusa Sri Lanka',
    description: 'Monthly Engineering Salary Deposit',
    occurredAt: new Date(Date.now() - 10 * 86400000).toISOString(),
    effectiveDate: new Date(Date.now() - 10 * 86400000).toISOString().slice(0, 10),
    entryTimeZone: 'Asia/Colombo',
    origin: 'manual',
    categorizationSource: 'rule',
    proposalId: null,
    openingDirection: null,
  },
  // Sample transfer from bank to cash (ATM withdrawal)
  {
    id: 'tx-atm-1',
    type: 'transfer',
    amountMinor: 2000000, // LKR 20,000.00
    currency: 'LKR',
    accountId: 'acc-combank',
    destinationAccountId: 'acc-cash',
    incomeSourceId: null,
    categoryId: null,
    merchant: 'ComBank ATM Colpetty',
    description: 'Cash withdrawal for daily expenses',
    occurredAt: new Date(Date.now() - 8 * 86400000).toISOString(),
    effectiveDate: new Date(Date.now() - 8 * 86400000).toISOString().slice(0, 10),
    entryTimeZone: 'Asia/Colombo',
    origin: 'manual',
    categorizationSource: null,
    proposalId: null,
    openingDirection: null,
  },
  // Sample expenses
  {
    id: 'tx-keells-1',
    type: 'expense',
    amountMinor: 1485000, // LKR 14,850.00
    currency: 'LKR',
    accountId: 'acc-combank',
    destinationAccountId: null,
    incomeSourceId: null,
    categoryId: 'cat-groceries',
    merchant: 'Keells Super',
    description: 'Weekly grocery supplies, fresh vegetables & fruits',
    occurredAt: new Date(Date.now() - 5 * 86400000).toISOString(),
    effectiveDate: new Date(Date.now() - 5 * 86400000).toISOString().slice(0, 10),
    entryTimeZone: 'Asia/Colombo',
    origin: 'aiInput',
    categorizationSource: 'rule',
    proposalId: 'prop-sample-1',
    openingDirection: null,
  },
  {
    id: 'tx-fuel-1',
    type: 'expense',
    amountMinor: 650000, // LKR 6,500.00
    currency: 'LKR',
    accountId: 'acc-combank',
    destinationAccountId: null,
    incomeSourceId: null,
    categoryId: 'cat-transport',
    merchant: 'Ceypetco Fuel Station',
    description: 'Petrol full tank for car',
    occurredAt: new Date(Date.now() - 3 * 86400000).toISOString(),
    effectiveDate: new Date(Date.now() - 3 * 86400000).toISOString().slice(0, 10),
    entryTimeZone: 'Asia/Colombo',
    origin: 'manual',
    categorizationSource: 'manual',
    proposalId: null,
    openingDirection: null,
  },
  {
    id: 'tx-dining-1',
    type: 'expense',
    amountMinor: 420000, // LKR 4,200.00
    currency: 'LKR',
    accountId: 'acc-cash',
    destinationAccountId: null,
    incomeSourceId: null,
    categoryId: 'cat-dining',
    merchant: 'Perera & Sons',
    description: 'Family evening tea and pastries',
    occurredAt: new Date(Date.now() - 1 * 86400000).toISOString(),
    effectiveDate: new Date(Date.now() - 1 * 86400000).toISOString().slice(0, 10),
    entryTimeZone: 'Asia/Colombo',
    origin: 'aiInput',
    categorizationSource: 'ai',
    proposalId: 'prop-sample-2',
    openingDirection: null,
  },
];
