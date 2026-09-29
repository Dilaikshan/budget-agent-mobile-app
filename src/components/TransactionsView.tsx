import React, { useState } from 'react';
import {
  ListOrdered,
  Search,
  Filter,
  Trash2,
  ArrowUpRight,
  ArrowDownLeft,
  ArrowRightLeft,
  Building2,
  Sparkles,
  ShieldCheck,
  AlertTriangle,
} from 'lucide-react';
import { Account, Category, IncomeSource, Transaction } from '../types';
import { formatMoney } from '../ledger';

interface TransactionsViewProps {
  transactions: Transaction[];
  accounts: Account[];
  categories: Category[];
  incomeSources: IncomeSource[];
  currency: string;
  onDeleteTransaction: (id: string) => void;
  onOpenQuickEntry: () => void;
  onOpenManualEntry: () => void;
}

export const TransactionsView: React.FC<TransactionsViewProps> = ({
  transactions,
  accounts,
  categories,
  incomeSources,
  currency,
  onDeleteTransaction,
  onOpenQuickEntry,
  onOpenManualEntry,
}) => {
  const [searchTerm, setSearchTerm] = useState('');
  const [typeFilter, setTypeFilter] = useState<string>('all');
  const [accountFilter, setAccountFilter] = useState<string>('all');
  const [deletingId, setDeletingId] = useState<string | null>(null);

  const getAccountName = (id: string) => accounts.find((a) => a.id === id)?.name || id;
  const getCategoryName = (id: string | null) =>
    categories.find((c) => c.id === id)?.name || 'Uncategorized';
  const getIncomeSourceName = (id: string | null) =>
    incomeSources.find((s) => s.id === id)?.name || 'Direct';

  const filtered = transactions
    .filter((tx) => {
      if (typeFilter !== 'all' && tx.type !== typeFilter) return false;
      if (accountFilter !== 'all' && tx.accountId !== accountFilter && tx.destinationAccountId !== accountFilter) {
        return false;
      }
      if (searchTerm.trim()) {
        const term = searchTerm.toLowerCase();
        const matchDesc = tx.description.toLowerCase().includes(term);
        const matchMerchant = tx.merchant ? tx.merchant.toLowerCase().includes(term) : false;
        const matchCat = tx.categoryId ? getCategoryName(tx.categoryId).toLowerCase().includes(term) : false;
        if (!matchDesc && !matchMerchant && !matchCat) return false;
      }
      return true;
    })
    .sort((a, b) => new Date(b.occurredAt).getTime() - new Date(a.occurredAt).getTime());

  return (
    <div className="space-y-6">
      {/* Top Controls */}
      <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-3">
        <div className="flex items-center space-x-2">
          <ListOrdered className="w-5 h-5 text-emerald-400" />
          <h2 className="text-lg font-bold text-slate-100">
            Confirmed Financial Ledger
          </h2>
          <span className="text-xs px-2 py-0.5 rounded-full bg-slate-800 text-slate-300 font-mono">
            {filtered.length} entries
          </span>
        </div>
        <div className="flex items-center space-x-2">
          <button
            onClick={onOpenManualEntry}
            className="px-3 py-1.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-200 text-xs font-semibold border border-slate-700 transition-colors cursor-pointer"
          >
            Manual Entry
          </button>
          <button
            onClick={onOpenQuickEntry}
            className="px-3.5 py-1.5 rounded-xl bg-emerald-500 hover:bg-emerald-400 text-slate-950 text-xs font-bold transition-all shadow-md shadow-emerald-500/20 flex items-center space-x-1.5 cursor-pointer"
          >
            <Sparkles className="w-3.5 h-3.5" />
            <span>AI Quick Entry</span>
          </button>
        </div>
      </div>

      {/* Filter and Search Bar */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 p-4 rounded-2xl bg-slate-800/40 border border-slate-700/60">
        {/* Search */}
        <div className="relative">
          <Search className="w-4 h-4 text-slate-400 absolute left-3 top-3" />
          <input
            type="text"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            placeholder="Search merchant, description..."
            className="w-full bg-slate-900 border border-slate-700 rounded-xl pl-9 pr-3 py-2 text-xs text-slate-100 focus:outline-none focus:border-emerald-500"
          />
        </div>

        {/* Type Filter */}
        <div className="flex items-center space-x-2">
          <Filter className="w-4 h-4 text-slate-400 shrink-0" />
          <select
            value={typeFilter}
            onChange={(e) => setTypeFilter(e.target.value)}
            className="w-full bg-slate-900 border border-slate-700 rounded-xl px-3 py-2 text-xs text-slate-100 focus:outline-none focus:border-emerald-500"
          >
            <option value="all">All Types</option>
            <option value="expense">Expenses Only</option>
            <option value="income">Income Only</option>
            <option value="transfer">Transfers Only</option>
            <option value="opening">Opening Balances</option>
          </select>
        </div>

        {/* Account Filter */}
        <div>
          <select
            value={accountFilter}
            onChange={(e) => setAccountFilter(e.target.value)}
            className="w-full bg-slate-900 border border-slate-700 rounded-xl px-3 py-2 text-xs text-slate-100 focus:outline-none focus:border-emerald-500"
          >
            <option value="all">All Accounts</option>
            {accounts.map((a) => (
              <option key={a.id} value={a.id}>
                {a.name}
              </option>
            ))}
          </select>
        </div>
      </div>

      {/* Table / List */}
      <div className="bg-slate-800/40 rounded-2xl border border-slate-700/60 overflow-hidden divide-y divide-slate-800">
        {filtered.length === 0 ? (
          <div className="p-10 text-center text-slate-400 text-sm">
            No transactions match the selected filter.
          </div>
        ) : (
          filtered.map((tx) => {
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

                  <div className="min-w-0">
                    <div className="flex items-center space-x-2">
                      <span className="text-sm font-semibold text-slate-100 truncate">
                        {tx.merchant || tx.description}
                      </span>
                      {tx.categorizationSource === 'ai' && (
                        <span className="text-[10px] px-1.5 py-0.5 rounded bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 font-medium">
                          AI Proposal
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

                {/* Amount and Delete Action */}
                <div className="flex items-center space-x-3 shrink-0">
                  <div className="text-right">
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

                  {/* Delete button (opening balances are protected per spec) */}
                  {!isOpening && (
                    <button
                      onClick={() => setDeletingId(tx.id)}
                      title="Delete transaction"
                      className="p-1.5 rounded-lg text-slate-500 hover:text-rose-400 hover:bg-rose-500/10 transition-colors cursor-pointer"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  )}
                </div>
              </div>
            );
          })
        )}
      </div>

      {/* Delete Confirmation Modal */}
      {deletingId && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/80 backdrop-blur-sm">
          <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 max-w-sm w-full space-y-4 shadow-2xl">
            <div className="flex items-center space-x-3 text-rose-400">
              <AlertTriangle className="w-6 h-6" />
              <h3 className="text-base font-bold text-slate-100">
                Delete Ledger Entry?
              </h3>
            </div>
            <p className="text-xs text-slate-300 leading-relaxed">
              This action removes the transaction from the deterministic ledger and recalculates all affected account balances.
            </p>
            <div className="flex items-center justify-end space-x-2 pt-2">
              <button
                onClick={() => setDeletingId(null)}
                className="px-3.5 py-1.5 text-xs text-slate-400 hover:text-slate-200"
              >
                Cancel
              </button>
              <button
                onClick={() => {
                  onDeleteTransaction(deletingId);
                  setDeletingId(null);
                }}
                className="px-4 py-1.5 rounded-xl bg-rose-500 hover:bg-rose-600 text-white font-semibold text-xs transition-colors"
              >
                Confirm Delete
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
