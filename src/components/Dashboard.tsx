import React from 'react';
import {
  TrendingUp,
  TrendingDown,
  ArrowRightLeft,
  Sparkles,
  Wallet,
  CheckCircle2,
  AlertCircle,
  Plus,
  ArrowUpRight,
  ArrowDownLeft,
  Calendar,
  Building2,
  Tag,
} from 'lucide-react';
import { Account, Category, IncomeSource, Transaction, AIInsight } from '../types';
import {
  formatMoney,
  calculateAccountBalance,
  calculatePeriodIncome,
  calculatePeriodExpense,
} from '../ledger';

interface DashboardProps {
  accounts: Account[];
  categories: Category[];
  incomeSources: IncomeSource[];
  transactions: Transaction[];
  insights: AIInsight[];
  currency: string;
  onOpenQuickEntry: () => void;
  onOpenManualEntry: () => void;
  onSelectAccount: (accountId: string) => void;
  onViewAllTransactions: () => void;
}

export const Dashboard: React.FC<DashboardProps> = ({
  accounts,
  categories,
  incomeSources,
  transactions,
  insights,
  currency,
  onOpenQuickEntry,
  onOpenManualEntry,
  onSelectAccount,
  onViewAllTransactions,
}) => {
  // Current month string YYYY-MM
  const currentMonth = new Date().toISOString().slice(0, 7);
  const startOfMonth = `${currentMonth}-01`;
  const endOfMonth = `${currentMonth}-31`;

  const monthlyIncomeMinor = calculatePeriodIncome(transactions, startOfMonth, endOfMonth);
  const monthlyExpenseMinor = calculatePeriodExpense(transactions, startOfMonth, endOfMonth);
  const monthlySavingsMinor = monthlyIncomeMinor - monthlyExpenseMinor;

  const recentTransactions = [...transactions]
    .sort((a, b) => new Date(b.occurredAt).getTime() - new Date(a.occurredAt).getTime())
    .slice(0, 8);

  const getAccountName = (id: string) => accounts.find((a) => a.id === id)?.name || id;
  const getCategoryName = (id: string | null) =>
    categories.find((c) => c.id === id)?.name || 'Uncategorized';
  const getIncomeSourceName = (id: string | null) =>
    incomeSources.find((s) => s.id === id)?.name || 'Direct';

  return (
    <div className="space-y-6">
      {/* AI Daily Review / Invariant Status Banner */}
      {insights.length > 0 && (
        <div className="p-4 rounded-2xl bg-gradient-to-r from-slate-800/90 via-slate-800 to-slate-800/80 border border-slate-700/80 shadow-md flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
          <div className="flex items-start space-x-3.5">
            <div className="p-2.5 rounded-xl bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 shrink-0">
              <Sparkles className="w-5 h-5 stroke-[2.2]" />
            </div>
            <div>
              <div className="flex items-center space-x-2">
                <span className="text-xs font-bold uppercase tracking-wider text-emerald-400">
                  Daily AI Agent Review
                </span>
                <span className="text-[10px] px-1.5 py-0.5 rounded bg-slate-700 text-slate-300 font-mono">
                  Verified Invariant
                </span>
              </div>
              <h3 className="text-sm font-semibold text-slate-100 mt-0.5">
                {insights[0].title}
              </h3>
              <p className="text-xs text-slate-300 mt-1 leading-relaxed max-w-3xl">
                {insights[0].summary}
              </p>
            </div>
          </div>
          <div className="flex items-center space-x-2 self-end md:self-center shrink-0">
            <button
              onClick={onOpenQuickEntry}
              className="text-xs font-semibold px-3 py-1.5 rounded-lg bg-emerald-500/20 text-emerald-300 hover:bg-emerald-500/30 transition-colors border border-emerald-500/30 cursor-pointer flex items-center space-x-1"
            >
              <Sparkles className="w-3.5 h-3.5" />
              <span>Natural Entry</span>
            </button>
          </div>
        </div>
      )}

      {/* Metric Cards Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        {/* Income this month */}
        <div className="p-5 rounded-2xl bg-slate-800/60 border border-slate-700/60 hover:border-slate-600 transition-all">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold uppercase tracking-wider text-slate-400">
              Monthly Income
            </span>
            <div className="p-2 rounded-xl bg-emerald-500/10 text-emerald-400">
              <TrendingUp className="w-4 h-4" />
            </div>
          </div>
          <div className="mt-3">
            <span className="text-2xl font-extrabold text-slate-100 font-mono">
              {formatMoney(monthlyIncomeMinor, currency)}
            </span>
          </div>
          <p className="text-xs text-slate-400 mt-1">
            Confirmed income from sources & salary
          </p>
        </div>

        {/* Expenses this month */}
        <div className="p-5 rounded-2xl bg-slate-800/60 border border-slate-700/60 hover:border-slate-600 transition-all">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold uppercase tracking-wider text-slate-400">
              Monthly Expenses
            </span>
            <div className="p-2 rounded-xl bg-rose-500/10 text-rose-400">
              <TrendingDown className="w-4 h-4" />
            </div>
          </div>
          <div className="mt-3">
            <span className="text-2xl font-extrabold text-slate-100 font-mono">
              {formatMoney(monthlyExpenseMinor, currency)}
            </span>
          </div>
          <p className="text-xs text-slate-400 mt-1">
            Excludes internal transfers & opening balances
          </p>
        </div>

        {/* Net Savings */}
        <div className="p-5 rounded-2xl bg-slate-800/60 border border-slate-700/60 hover:border-slate-600 transition-all sm:col-span-2 lg:col-span-1">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold uppercase tracking-wider text-slate-400">
              Net Savings (Cashflow)
            </span>
            <div className={`p-2 rounded-xl ${monthlySavingsMinor >= 0 ? 'bg-teal-500/10 text-teal-400' : 'bg-amber-500/10 text-amber-400'}`}>
              <Wallet className="w-4 h-4" />
            </div>
          </div>
          <div className="mt-3">
            <span className={`text-2xl font-extrabold font-mono ${monthlySavingsMinor >= 0 ? 'text-teal-400' : 'text-amber-400'}`}>
              {formatMoney(monthlySavingsMinor, currency)}
            </span>
          </div>
          <p className="text-xs text-slate-400 mt-1">
            {monthlySavingsMinor >= 0 ? 'Positive retained capital' : 'Net deficit for this period'}
          </p>
        </div>
      </div>

      {/* Accounts Ledger Breakdown */}
      <div>
        <div className="flex items-center justify-between mb-3">
          <div className="flex items-center space-x-2">
            <Wallet className="w-4 h-4 text-emerald-400" />
            <h2 className="text-base font-bold text-slate-100">Asset Accounts</h2>
            <span className="text-xs text-slate-400">({accounts.length} active)</span>
          </div>
          <span className="text-xs text-slate-400 hidden sm:inline">
            Derived strictly from confirmed transactions
          </span>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
          {accounts.map((acc) => {
            const balanceMinor = calculateAccountBalance(acc.id, transactions);
            const isNegative = balanceMinor < 0;
            return (
              <div
                key={acc.id}
                onClick={() => onSelectAccount(acc.id)}
                className="p-4 rounded-xl bg-slate-800/40 border border-slate-700/60 hover:border-emerald-500/50 hover:bg-slate-800/70 transition-all cursor-pointer group"
              >
                <div className="flex items-center justify-between mb-2">
                  <span className="text-xs font-semibold uppercase tracking-wider text-slate-400">
                    {acc.type}
                  </span>
                  <span className="text-[10px] px-2 py-0.5 rounded-full bg-slate-700/60 text-slate-300 font-mono">
                    {acc.currency}
                  </span>
                </div>
                <h4 className="text-sm font-bold text-slate-100 group-hover:text-emerald-400 transition-colors line-clamp-1">
                  {acc.name}
                </h4>
                <div className="mt-2">
                  <span
                    className={`text-lg font-extrabold font-mono ${
                      isNegative ? 'text-rose-400' : 'text-slate-100'
                    }`}
                  >
                    {formatMoney(balanceMinor, acc.currency)}
                  </span>
                </div>
                {isNegative && (
                  <p className="text-[10px] text-amber-400 flex items-center mt-1">
                    <AlertCircle className="w-3 h-3 mr-1 inline" /> Overdrawn balance
                  </p>
                )}
              </div>
            );
          })}
        </div>
      </div>

      {/* Recent Confirmed Transactions */}
      <div>
        <div className="flex items-center justify-between mb-3">
          <div className="flex items-center space-x-2">
            <CheckCircle2 className="w-4 h-4 text-emerald-400" />
            <h2 className="text-base font-bold text-slate-100">Recent Confirmed Ledger Entries</h2>
          </div>
          <div className="flex items-center space-x-2">
            <button
              onClick={onOpenManualEntry}
              className="text-xs font-semibold px-2.5 py-1 rounded-lg bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-700 transition-colors cursor-pointer flex items-center space-x-1"
            >
              <Plus className="w-3.5 h-3.5" />
              <span>Manual Entry</span>
            </button>
            <button
              onClick={onViewAllTransactions}
              className="text-xs font-semibold text-emerald-400 hover:text-emerald-300 transition-colors cursor-pointer"
            >
              View Full Ledger →
            </button>
          </div>
        </div>

        <div className="bg-slate-800/40 rounded-2xl border border-slate-700/60 overflow-hidden divide-y divide-slate-800">
          {recentTransactions.length === 0 ? (
            <div className="p-8 text-center">
              <p className="text-sm text-slate-400">No transactions recorded yet.</p>
              <button
                onClick={onOpenQuickEntry}
                className="mt-3 text-xs font-semibold px-4 py-2 rounded-xl bg-emerald-500 text-slate-950 hover:bg-emerald-400 transition-colors"
              >
                Add Your First Transaction
              </button>
            </div>
          ) : (
            recentTransactions.map((tx) => {
              const isExpense = tx.type === 'expense';
              const isIncome = tx.type === 'income';
              const isTransfer = tx.type === 'transfer';
              const isOpening = tx.type === 'opening';

              return (
                <div
                  key={tx.id}
                  className="p-4 hover:bg-slate-800/60 transition-colors flex items-center justify-between gap-4"
                >
                  <div className="flex items-center space-x-3.5 min-w-0">
                    {/* Type Icon Badge */}
                    <div
                      className={`p-2.5 rounded-xl shrink-0 ${
                        isExpense
                          ? 'bg-rose-500/10 text-rose-400 border border-rose-500/20'
                          : isIncome
                          ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20'
                          : isTransfer
                          ? 'bg-blue-500/10 text-blue-400 border border-blue-500/20'
                          : 'bg-purple-500/10 text-purple-400 border border-purple-500/20'
                      }`}
                    >
                      {isExpense && <ArrowUpRight className="w-4 h-4" />}
                      {isIncome && <ArrowDownLeft className="w-4 h-4" />}
                      {isTransfer && <ArrowRightLeft className="w-4 h-4" />}
                      {isOpening && <Building2 className="w-4 h-4" />}
                    </div>

                    {/* Transaction Details */}
                    <div className="min-w-0">
                      <div className="flex items-center space-x-2">
                        <span className="text-sm font-semibold text-slate-100 truncate">
                          {tx.merchant || tx.description}
                        </span>
                        {tx.categorizationSource === 'ai' && (
                          <span className="text-[10px] px-1.5 py-0.5 rounded bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 font-medium">
                            AI Suggested
                          </span>
                        )}
                        {tx.categorizationSource === 'rule' && (
                          <span className="text-[10px] px-1.5 py-0.5 rounded bg-blue-500/10 text-blue-400 border border-blue-500/20 font-medium">
                            Rule Matched
                          </span>
                        )}
                      </div>

                      <div className="flex items-center space-x-2 text-xs text-slate-400 mt-0.5 flex-wrap">
                        <span>{tx.effectiveDate}</span>
                        <span>•</span>
                        {isTransfer ? (
                          <span>
                            {getAccountName(tx.accountId)} → {getAccountName(tx.destinationAccountId || '')}
                          </span>
                        ) : isIncome ? (
                          <span>
                            To {getAccountName(tx.accountId)} ({getIncomeSourceName(tx.incomeSourceId)})
                          </span>
                        ) : (
                          <span>
                            From {getAccountName(tx.accountId)}
                          </span>
                        )}
                        {tx.categoryId && (
                          <>
                            <span>•</span>
                            <span className="text-slate-300 font-medium">
                              {getCategoryName(tx.categoryId)}
                            </span>
                          </>
                        )}
                      </div>
                    </div>
                  </div>

                  {/* Amount */}
                  <div className="text-right shrink-0">
                    <span
                      className={`text-sm sm:text-base font-bold font-mono ${
                        isExpense
                          ? 'text-rose-400'
                          : isIncome
                          ? 'text-emerald-400'
                          : isTransfer
                          ? 'text-blue-400'
                          : 'text-purple-400'
                      }`}
                    >
                      {isExpense ? '-' : isIncome ? '+' : ''}
                      {formatMoney(tx.amountMinor, tx.currency)}
                    </span>
                    <span className="block text-[10px] uppercase tracking-wider text-slate-400 font-mono">
                      {tx.type}
                    </span>
                  </div>
                </div>
              );
            })
          )}
        </div>
      </div>
    </div>
  );
};
