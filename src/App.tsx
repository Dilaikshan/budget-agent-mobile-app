import React, { useState, useEffect } from 'react';
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
import { loadStoredData, saveStoredData } from './storage';
import { calculateNetWorth, formatMoney } from './ledger';
import { Header } from './components/Header';
import { Dashboard } from './components/Dashboard';
import { TransactionsView } from './components/TransactionsView';
import { AccountsView } from './components/AccountsView';
import { BudgetsView } from './components/BudgetsView';
import { CategoriesView } from './components/CategoriesView';
import { AIActivityView } from './components/AIActivityView';
import { SettingsView } from './components/SettingsView';
import { TransactionParserModal } from './components/TransactionParserModal';
import { ManualTransactionModal } from './components/ManualTransactionModal';

export const App: React.FC = () => {
  const [data, setData] = useState(() => loadStoredData());
  const [activeTab, setActiveTab] = useState('dashboard');
  const [selectedAccountId, setSelectedAccountId] = useState<string | null>(null);

  // Modals
  const [isQuickEntryOpen, setIsQuickEntryOpen] = useState(false);
  const [isManualEntryOpen, setIsManualEntryOpen] = useState(false);
  const [isReviewLoading, setIsReviewLoading] = useState(false);

  // Persist state changes
  useEffect(() => {
    saveStoredData(data);
  }, [data]);

  const netWorthMinor = calculateNetWorth(data.accounts, data.transactions);

  // Confirm and commit a transaction to the deterministic ledger
  const handleConfirmTransaction = (
    txData: Omit<Transaction, 'id'>,
    saveRule?: {
      matchKind: 'keyword';
      pattern: string;
      categoryId: string;
    }
  ) => {
    const newTx: Transaction = {
      ...txData,
      id: 'tx-' + Date.now() + '-' + Math.random().toString(36).substring(2, 6),
    };

    let updatedRules = [...data.rules];
    if (saveRule) {
      // Check if rule already exists
      const existing = updatedRules.find(
        (r) => r.normalizedPattern === saveRule.pattern.toLowerCase()
      );
      if (!existing) {
        updatedRules.push({
          id: 'rule-' + Date.now(),
          matchKind: saveRule.matchKind,
          normalizedPattern: saveRule.pattern.toLowerCase(),
          transactionType: txData.type === 'income' ? 'income' : 'expense',
          categoryId: saveRule.categoryId,
          suggestedAccountId: txData.accountId,
          suggestedIncomeSourceId: txData.incomeSourceId,
          priority: 10,
          enabled: true,
          origin: 'acceptedSuggestion',
        });
      }
    }

    setData((prev) => ({
      ...prev,
      transactions: [newTx, ...prev.transactions],
      rules: updatedRules,
    }));
  };

  // Delete transaction (opening balances protected)
  const handleDeleteTransaction = (id: string) => {
    setData((prev) => ({
      ...prev,
      transactions: prev.transactions.filter((t) => t.id !== id),
    }));
  };

  // Add account with mandatory atomic opening balance transaction
  const handleAddAccount = (
    accountData: Omit<Account, 'id'>,
    openingBalanceMinor: number,
    openingDirection: 'credit' | 'debit'
  ) => {
    const newAccountId = 'acc-' + Date.now();
    const newAccount: Account = {
      ...accountData,
      id: newAccountId,
    };

    const openingTx: Transaction = {
      id: 'op-' + newAccountId,
      type: 'opening',
      amountMinor: openingBalanceMinor,
      currency: accountData.currency,
      accountId: newAccountId,
      destinationAccountId: null,
      incomeSourceId: null,
      categoryId: null,
      merchant: null,
      description: `Opening Balance for ${accountData.name}`,
      occurredAt: new Date().toISOString(),
      effectiveDate: new Date().toISOString().slice(0, 10),
      entryTimeZone: data.profile.timeZone,
      origin: 'opening',
      categorizationSource: null,
      proposalId: null,
      openingDirection,
    };

    setData((prev) => ({
      ...prev,
      accounts: [...prev.accounts, newAccount],
      transactions: [openingTx, ...prev.transactions],
      activities: [
        {
          id: 'act-' + Date.now(),
          agentType: 'accountSuggestion',
          action: 'Account Created',
          outcome: 'applied',
          summary: `Created account "${newAccount.name}" with opening balance ${formatMoney(openingBalanceMinor, newAccount.currency)}.`,
          timestamp: new Date().toISOString(),
          entityIds: [newAccountId],
        },
        ...prev.activities,
      ],
    }));
  };

  // Add or update category budget
  const handleSetBudget = (categoryId: string, limitMinor: number, month: string) => {
    setData((prev) => {
      const existingIdx = prev.budgets.findIndex(
        (b) => b.categoryId === categoryId && b.month === month
      );
      if (existingIdx >= 0) {
        const updated = [...prev.budgets];
        updated[existingIdx] = {
          ...updated[existingIdx],
          limitMinor,
        };
        return { ...prev, budgets: updated };
      } else {
        const newBudget: Budget = {
          id: 'b-' + Date.now(),
          month,
          categoryId,
          limitMinor,
          currency: prev.profile.baseCurrency,
        };
        return { ...prev, budgets: [...prev.budgets, newBudget] };
      }
    });
  };

  // Trigger Daily AI Review
  const handleTriggerDailyReview = async () => {
    setIsReviewLoading(true);
    try {
      const response = await fetch('/api/agent-review', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          transactions: data.transactions,
          accounts: data.accounts,
          categories: data.categories,
          budgets: data.budgets,
          currency: data.profile.baseCurrency,
        }),
      });

      if (response.ok) {
        const result = await response.json();
        if (result.insights && Array.isArray(result.insights)) {
          setData((prev) => ({
            ...prev,
            insights: result.insights,
            activities: [
              {
                id: 'act-' + Date.now(),
                agentType: 'dailyReview',
                action: 'Daily Review Completed',
                outcome: 'applied',
                summary: `Evaluated ${prev.transactions.length} ledger entries across ${prev.accounts.length} accounts.`,
                timestamp: new Date().toISOString(),
                entityIds: [],
                provider: result.provider,
              },
              ...prev.activities,
            ],
          }));
        }
      }
    } catch (err) {
      console.warn('Agent review error', err);
    } finally {
      setIsReviewLoading(false);
    }
  };

  const handleLogActivity = (act: Omit<AIActivity, 'id' | 'timestamp'>) => {
    setData((prev) => ({
      ...prev,
      activities: [
        {
          ...act,
          id: 'act-' + Date.now(),
          timestamp: new Date().toISOString(),
        },
        ...prev.activities,
      ],
    }));
  };

  return (
    <div className="min-h-screen bg-slate-950 text-slate-100 flex flex-col font-sans">
      <Header
        netWorthMinor={netWorthMinor}
        currency={data.profile.baseCurrency}
        activeTab={activeTab}
        setActiveTab={setActiveTab}
        onOpenQuickEntry={() => setIsQuickEntryOpen(true)}
      />

      <main className="flex-1 max-w-7xl w-full mx-auto px-4 sm:px-6 lg:px-8 py-6">
        {activeTab === 'dashboard' && (
          <Dashboard
            accounts={data.accounts}
            categories={data.categories}
            incomeSources={data.incomeSources}
            transactions={data.transactions}
            insights={data.insights}
            currency={data.profile.baseCurrency}
            onOpenQuickEntry={() => setIsQuickEntryOpen(true)}
            onOpenManualEntry={() => setIsManualEntryOpen(true)}
            onSelectAccount={(accId) => {
              setSelectedAccountId(accId);
              setActiveTab('accounts');
            }}
            onViewAllTransactions={() => setActiveTab('transactions')}
          />
        )}

        {activeTab === 'transactions' && (
          <TransactionsView
            transactions={data.transactions}
            accounts={data.accounts}
            categories={data.categories}
            incomeSources={data.incomeSources}
            currency={data.profile.baseCurrency}
            onDeleteTransaction={handleDeleteTransaction}
            onOpenQuickEntry={() => setIsQuickEntryOpen(true)}
            onOpenManualEntry={() => setIsManualEntryOpen(true)}
          />
        )}

        {activeTab === 'accounts' && (
          <AccountsView
            accounts={data.accounts}
            transactions={data.transactions}
            currency={data.profile.baseCurrency}
            onAddAccount={handleAddAccount}
            selectedAccountId={selectedAccountId}
            onSelectAccount={setSelectedAccountId}
          />
        )}

        {activeTab === 'budgets' && (
          <BudgetsView
            budgets={data.budgets}
            categories={data.categories}
            transactions={data.transactions}
            currency={data.profile.baseCurrency}
            onSetBudget={handleSetBudget}
          />
        )}

        {activeTab === 'categories' && (
          <CategoriesView
            categories={data.categories}
            incomeSources={data.incomeSources}
            rules={data.rules}
            accounts={data.accounts}
            onAddCategory={(cat) =>
              setData((prev) => ({
                ...prev,
                categories: [
                  ...prev.categories,
                  { ...cat, id: 'cat-' + Date.now() },
                ],
              }))
            }
            onAddIncomeSource={(src) =>
              setData((prev) => ({
                ...prev,
                incomeSources: [
                  ...prev.incomeSources,
                  { ...src, id: 'src-' + Date.now() },
                ],
              }))
            }
            onAddRule={(rule) =>
              setData((prev) => ({
                ...prev,
                rules: [...prev.rules, { ...rule, id: 'rule-' + Date.now() }],
              }))
            }
            onToggleRule={(id) =>
              setData((prev) => ({
                ...prev,
                rules: prev.rules.map((r) =>
                  r.id === id ? { ...r, enabled: !r.enabled } : r
                ),
              }))
            }
            onDeleteRule={(id) =>
              setData((prev) => ({
                ...prev,
                rules: prev.rules.filter((r) => r.id !== id),
              }))
            }
          />
        )}

        {activeTab === 'ai-activity' && (
          <AIActivityView
            activities={data.activities}
            onTriggerDailyReview={handleTriggerDailyReview}
            isReviewLoading={isReviewLoading}
          />
        )}

        {activeTab === 'settings' && (
          <SettingsView
            profile={data.profile}
            settings={data.settings}
            onUpdateProfile={(profile) =>
              setData((prev) => ({ ...prev, profile }))
            }
            onUpdateSettings={(settings) =>
              setData((prev) => ({ ...prev, settings }))
            }
            onDataReset={() => setData(loadStoredData())}
          />
        )}
      </main>

      {/* AI Natural Language Parser Modal */}
      <TransactionParserModal
        isOpen={isQuickEntryOpen}
        onClose={() => setIsQuickEntryOpen(false)}
        accounts={data.accounts}
        categories={data.categories}
        incomeSources={data.incomeSources}
        rules={data.rules}
        currency={data.profile.baseCurrency}
        onConfirmTransaction={handleConfirmTransaction}
        onLogActivity={handleLogActivity}
      />

      {/* Structured Manual Entry Modal */}
      <ManualTransactionModal
        isOpen={isManualEntryOpen}
        onClose={() => setIsManualEntryOpen(false)}
        accounts={data.accounts}
        categories={data.categories}
        incomeSources={data.incomeSources}
        currency={data.profile.baseCurrency}
        onSave={(tx) => handleConfirmTransaction(tx)}
      />
    </div>
  );
};
