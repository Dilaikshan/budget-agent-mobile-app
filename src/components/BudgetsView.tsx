import React, { useState } from 'react';
import {
  Layers,
  Plus,
  AlertTriangle,
  CheckCircle,
  TrendingDown,
  X,
  Check,
} from 'lucide-react';
import { Budget, Category, Transaction } from '../types';
import {
  formatMoney,
  calculateCategorySpending,
  parseMoneyToMinor,
  currentMonthStr,
} from '../ledger';

interface BudgetsViewProps {
  budgets: Budget[];
  categories: Category[];
  transactions: Transaction[];
  currency: string;
  onSetBudget: (categoryId: string, limitMinor: number, month: string) => void;
}

export const BudgetsView: React.FC<BudgetsViewProps> = ({
  budgets,
  categories,
  transactions,
  currency,
  onSetBudget,
}) => {
  const [selectedMonth, setSelectedMonth] = useState(currentMonthStr);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [categoryId, setCategoryId] = useState('');
  const [limitStr, setLimitStr] = useState('');

  const expenseCategories = categories.filter(
    (c) => c.type === 'expense' && !c.archived
  );

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    if (!categoryId) return;
    const limitMinor = parseMoneyToMinor(limitStr);
    if (limitMinor <= 0) return;

    onSetBudget(categoryId, limitMinor, selectedMonth);
    setIsModalOpen(false);
    setLimitStr('');
  };

  const getCategoryName = (id: string) =>
    categories.find((c) => c.id === id)?.name || 'Category';

  const monthlyBudgets = budgets.filter((b) => b.month === selectedMonth);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-3">
        <div>
          <h2 className="text-lg font-bold text-slate-100 flex items-center space-x-2">
            <Layers className="w-5 h-5 text-emerald-400" />
            <span>Monthly Category Budgets</span>
          </h2>
          <p className="text-xs text-slate-400 mt-0.5">
            Deterministic monthly category limits with real-time ledger tracking.
          </p>
        </div>

        <div className="flex items-center space-x-2">
          <input
            type="month"
            value={selectedMonth}
            onChange={(e) => setSelectedMonth(e.target.value)}
            className="bg-slate-800 border border-slate-700 rounded-xl px-3 py-1.5 text-xs text-slate-100 focus:outline-none focus:border-emerald-500"
          />
          <button
            onClick={() => {
              if (expenseCategories.length > 0) {
                setCategoryId(expenseCategories[0].id);
              }
              setIsModalOpen(true);
            }}
            className="px-3.5 py-1.5 rounded-xl bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-bold text-xs flex items-center space-x-1.5 transition-all shadow-md shadow-emerald-500/20 cursor-pointer"
          >
            <Plus className="w-4 h-4 stroke-[3]" />
            <span>Set Budget</span>
          </button>
        </div>
      </div>

      {/* Budgets Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {monthlyBudgets.length === 0 ? (
          <div className="col-span-2 p-8 text-center bg-slate-800/40 rounded-2xl border border-slate-700/60">
            <p className="text-sm text-slate-400">
              No budgets established for {selectedMonth}.
            </p>
            <button
              onClick={() => {
                if (expenseCategories.length > 0) {
                  setCategoryId(expenseCategories[0].id);
                }
                setIsModalOpen(true);
              }}
              className="mt-3 text-xs font-semibold px-4 py-2 rounded-xl bg-emerald-500 text-slate-950 hover:bg-emerald-400 transition-colors"
            >
              Set First Category Budget
            </button>
          </div>
        ) : (
          monthlyBudgets.map((b) => {
            const spentMinor = calculateCategorySpending(
              b.categoryId,
              transactions,
              selectedMonth
            );
            const remainingMinor = b.limitMinor - spentMinor;
            const percent = Math.min(
              Math.round((spentMinor / b.limitMinor) * 100),
              200
            );
            const isOver = spentMinor > b.limitMinor;
            const isWarning = !isOver && percent >= 80;

            return (
              <div
                key={b.id}
                className="p-5 rounded-2xl bg-slate-800/40 border border-slate-700/60 space-y-3"
              >
                <div className="flex items-center justify-between">
                  <h3 className="text-sm font-bold text-slate-100">
                    {getCategoryName(b.categoryId)}
                  </h3>
                  <span
                    className={`text-xs font-semibold px-2 py-0.5 rounded-full font-mono ${
                      isOver
                        ? 'bg-rose-500/10 text-rose-400 border border-rose-500/20'
                        : isWarning
                        ? 'bg-amber-500/10 text-amber-400 border border-amber-500/20'
                        : 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20'
                    }`}
                  >
                    {percent}% used
                  </span>
                </div>

                {/* Progress bar */}
                <div className="w-full bg-slate-900 h-2.5 rounded-full overflow-hidden">
                  <div
                    className={`h-full transition-all duration-300 ${
                      isOver
                        ? 'bg-rose-500'
                        : isWarning
                        ? 'bg-amber-500'
                        : 'bg-emerald-500'
                    }`}
                    style={{ width: `${Math.min(percent, 100)}%` }}
                  />
                </div>

                {/* Stats */}
                <div className="flex items-center justify-between text-xs font-mono pt-1">
                  <div>
                    <span className="text-slate-400 block text-[10px] uppercase font-sans">
                      Spent
                    </span>
                    <span className="font-bold text-slate-200">
                      {formatMoney(spentMinor, currency)}
                    </span>
                  </div>
                  <div className="text-right">
                    <span className="text-slate-400 block text-[10px] uppercase font-sans">
                      {isOver ? 'Over Budget' : 'Remaining'}
                    </span>
                    <span
                      className={`font-bold ${
                        isOver ? 'text-rose-400' : 'text-emerald-400'
                      }`}
                    >
                      {formatMoney(Math.abs(remainingMinor), currency)}
                    </span>
                  </div>
                </div>

                <div className="text-[11px] text-slate-400 flex items-center justify-between pt-1 border-t border-slate-800">
                  <span>Limit: {formatMoney(b.limitMinor, currency)}</span>
                  {isOver && (
                    <span className="text-rose-400 flex items-center space-x-1">
                      <AlertTriangle className="w-3 h-3" />
                      <span>Exceeded limit</span>
                    </span>
                  )}
                </div>
              </div>
            );
          })
        )}
      </div>

      {/* Set Budget Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/80 backdrop-blur-sm animate-in fade-in">
          <div className="bg-slate-900 border border-slate-800 rounded-3xl w-full max-w-sm overflow-hidden shadow-2xl">
            <div className="p-5 border-b border-slate-800 flex items-center justify-between">
              <h3 className="text-base font-bold text-slate-100">
                Set Monthly Budget
              </h3>
              <button
                onClick={() => setIsModalOpen(false)}
                className="text-slate-400 hover:text-slate-200"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleSave} className="p-6 space-y-4">
              <div>
                <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1">
                  Month
                </label>
                <input
                  type="month"
                  value={selectedMonth}
                  onChange={(e) => setSelectedMonth(e.target.value)}
                  className="w-full bg-slate-800 border border-slate-700 rounded-xl px-3 py-2 text-xs text-slate-100 focus:outline-none focus:border-emerald-500"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1">
                  Expense Category
                </label>
                <select
                  value={categoryId}
                  onChange={(e) => setCategoryId(e.target.value)}
                  className="w-full bg-slate-800 border border-slate-700 rounded-xl px-3 py-2 text-xs text-slate-100 focus:outline-none focus:border-emerald-500"
                >
                  {expenseCategories.map((c) => (
                    <option key={c.id} value={c.id}>
                      {c.name}
                    </option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1">
                  Monthly Limit ({currency})
                </label>
                <input
                  type="number"
                  step="1"
                  required
                  value={limitStr}
                  onChange={(e) => setLimitStr(e.target.value)}
                  placeholder="e.g. 50000"
                  className="w-full bg-slate-800 border border-slate-700 rounded-xl px-3 py-2 text-sm font-mono font-bold text-slate-100 focus:outline-none focus:border-emerald-500"
                />
              </div>

              <div className="pt-3 flex items-center justify-end space-x-2 border-t border-slate-800">
                <button
                  type="button"
                  onClick={() => setIsModalOpen(false)}
                  className="px-4 py-2 text-xs text-slate-400 hover:text-slate-200"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-5 py-2 rounded-xl bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-bold text-xs flex items-center space-x-1.5 transition-all shadow-md shadow-emerald-500/20"
                >
                  <Check className="w-4 h-4 stroke-[3]" />
                  <span>Save Budget</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
