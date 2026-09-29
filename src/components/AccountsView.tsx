import React, { useState } from 'react';
import {
  Wallet,
  Plus,
  Building2,
  Banknote,
  PiggyBank,
  CreditCard,
  AlertCircle,
  X,
  Check,
  History,
} from 'lucide-react';
import { Account, AccountType, Transaction } from '../types';
import { formatMoney, calculateAccountBalance, parseMoneyToMinor } from '../ledger';

interface AccountsViewProps {
  accounts: Account[];
  transactions: Transaction[];
  currency: string;
  onAddAccount: (
    account: Omit<Account, 'id'>,
    openingBalanceMinor: number,
    openingDirection: 'credit' | 'debit'
  ) => void;
  selectedAccountId?: string | null;
  onSelectAccount: (id: string | null) => void;
}

export const AccountsView: React.FC<AccountsViewProps> = ({
  accounts,
  transactions,
  currency,
  onAddAccount,
  selectedAccountId,
  onSelectAccount,
}) => {
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [name, setName] = useState('');
  const [type, setType] = useState<AccountType>('bank');
  const [openingBalanceStr, setOpeningBalanceStr] = useState('0');
  const [openingDirection, setOpeningDirection] = useState<'credit' | 'debit'>('credit');
  const [error, setError] = useState<string | null>(null);

  const getTypeIcon = (t: AccountType) => {
    switch (t) {
      case 'bank':
        return Building2;
      case 'cash':
        return Banknote;
      case 'savings':
        return PiggyBank;
      case 'wallet':
        return CreditCard;
    }
  };

  const handleCreate = (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim()) {
      setError('Account name is required.');
      return;
    }

    const openingMinor = parseMoneyToMinor(openingBalanceStr);
    onAddAccount(
      {
        name: name.trim(),
        type,
        currency,
        archived: false,
        sortOrder: accounts.length + 1,
      },
      openingMinor,
      openingDirection
    );

    setIsAddModalOpen(false);
    setName('');
    setOpeningBalanceStr('0');
    setError(null);
  };

  const activeAccount = accounts.find((a) => a.id === selectedAccountId);
  const accountTransactions = selectedAccountId
    ? transactions
        .filter(
          (t) =>
            t.accountId === selectedAccountId ||
            t.destinationAccountId === selectedAccountId
        )
        .sort((a, b) => new Date(b.occurredAt).getTime() - new Date(a.occurredAt).getTime())
    : [];

  return (
    <div className="space-y-6">
      {/* Title & Add button */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-lg font-bold text-slate-100 flex items-center space-x-2">
            <Wallet className="w-5 h-5 text-emerald-400" />
            <span>Asset Accounts & Balances</span>
          </h2>
          <p className="text-xs text-slate-400 mt-0.5">
            Balances are derived strictly from confirmed ledger transactions.
          </p>
        </div>
        <button
          onClick={() => setIsAddModalOpen(true)}
          className="px-3.5 py-2 rounded-xl bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-bold text-xs flex items-center space-x-1.5 transition-all shadow-md shadow-emerald-500/20 cursor-pointer"
        >
          <Plus className="w-4 h-4 stroke-[3]" />
          <span>Add Account</span>
        </button>
      </div>

      {/* Account Cards Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {accounts.map((acc) => {
          const Icon = getTypeIcon(acc.type);
          const balanceMinor = calculateAccountBalance(acc.id, transactions);
          const isSelected = selectedAccountId === acc.id;
          const isOverdrawn = balanceMinor < 0;

          return (
            <div
              key={acc.id}
              onClick={() => onSelectAccount(isSelected ? null : acc.id)}
              className={`p-5 rounded-2xl border transition-all cursor-pointer ${
                isSelected
                  ? 'bg-slate-800/90 border-emerald-500 ring-2 ring-emerald-500/20 shadow-lg'
                  : 'bg-slate-800/40 border-slate-700/60 hover:border-slate-600 hover:bg-slate-800/60'
              }`}
            >
              <div className="flex items-center justify-between mb-3">
                <div className="p-2.5 rounded-xl bg-slate-700/40 text-slate-300">
                  <Icon className="w-4 h-4" />
                </div>
                <span className="text-[10px] font-semibold uppercase tracking-wider px-2 py-0.5 rounded-full bg-slate-700 text-slate-300">
                  {acc.type}
                </span>
              </div>

              <h3 className="text-sm font-bold text-slate-100 line-clamp-1">
                {acc.name}
              </h3>

              <div className="mt-2">
                <span
                  className={`text-xl font-extrabold font-mono ${
                    isOverdrawn ? 'text-rose-400' : 'text-emerald-400'
                  }`}
                >
                  {formatMoney(balanceMinor, acc.currency)}
                </span>
              </div>

              <div className="mt-3 pt-3 border-t border-slate-700/60 flex items-center justify-between text-[11px] text-slate-400">
                <span>Ledger Activity</span>
                <span className="text-emerald-400 font-semibold flex items-center space-x-1">
                  <History className="w-3 h-3" />
                  <span>
                    {
                      transactions.filter(
                        (t) =>
                          t.accountId === acc.id ||
                          t.destinationAccountId === acc.id
                      ).length
                    }{' '}
                    entries
                  </span>
                </span>
              </div>
            </div>
          );
        })}
      </div>

      {/* Account Specific Audit Trail */}
      {activeAccount && (
        <div className="p-6 rounded-2xl bg-slate-800/40 border border-slate-700/60 space-y-4">
          <div className="flex items-center justify-between border-b border-slate-700 pb-3">
            <div>
              <span className="text-xs uppercase tracking-wider text-slate-400 font-semibold">
                Ledger Audit Trail for
              </span>
              <h3 className="text-base font-bold text-slate-100">
                {activeAccount.name}
              </h3>
            </div>
            <button
              onClick={() => onSelectAccount(null)}
              className="text-xs text-slate-400 hover:text-slate-200"
            >
              Clear Filter
            </button>
          </div>

          <div className="divide-y divide-slate-800">
            {accountTransactions.length === 0 ? (
              <p className="text-xs text-slate-400 py-4 text-center">
                No transactions recorded for this account.
              </p>
            ) : (
              accountTransactions.map((tx) => {
                const isFunding = tx.accountId === activeAccount.id;
                let effectMinor = 0;
                let sign = '';

                if (tx.type === 'income') {
                  effectMinor = tx.amountMinor;
                  sign = '+';
                } else if (tx.type === 'expense') {
                  effectMinor = tx.amountMinor;
                  sign = '-';
                } else if (tx.type === 'transfer') {
                  if (isFunding) {
                    effectMinor = tx.amountMinor;
                    sign = '-';
                  } else {
                    effectMinor = tx.amountMinor;
                    sign = '+';
                  }
                } else if (tx.type === 'opening') {
                  effectMinor = tx.amountMinor;
                  sign = tx.openingDirection === 'debit' ? '-' : '+';
                }

                return (
                  <div
                    key={tx.id}
                    className="py-3 flex items-center justify-between text-xs"
                  >
                    <div>
                      <div className="font-semibold text-slate-200">
                        {tx.merchant || tx.description}
                      </div>
                      <div className="text-slate-400 text-[11px]">
                        {tx.effectiveDate} • {tx.type}
                      </div>
                    </div>
                    <div
                      className={`font-mono font-bold ${
                        sign === '+' ? 'text-emerald-400' : 'text-rose-400'
                      }`}
                    >
                      {sign}
                      {formatMoney(effectMinor, tx.currency)}
                    </div>
                  </div>
                );
              })
            )}
          </div>
        </div>
      )}

      {/* Add Account Modal */}
      {isAddModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/80 backdrop-blur-sm animate-in fade-in">
          <div className="bg-slate-900 border border-slate-800 rounded-3xl w-full max-w-md overflow-hidden shadow-2xl">
            <div className="p-5 border-b border-slate-800 flex items-center justify-between">
              <h3 className="text-base font-bold text-slate-100">
                Add Asset Account
              </h3>
              <button
                onClick={() => setIsAddModalOpen(false)}
                className="text-slate-400 hover:text-slate-200"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleCreate} className="p-6 space-y-4">
              {error && (
                <div className="p-3 rounded-xl bg-rose-500/10 border border-rose-500/20 text-rose-400 text-xs flex items-center space-x-2">
                  <AlertCircle className="w-4 h-4 shrink-0" />
                  <span>{error}</span>
                </div>
              )}

              <div>
                <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1">
                  Account Name *
                </label>
                <input
                  type="text"
                  required
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  placeholder="e.g. Seylan Bank Savings"
                  className="w-full bg-slate-800 border border-slate-700 rounded-xl px-3 py-2 text-sm text-slate-100 focus:outline-none focus:border-emerald-500"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1">
                  Account Type *
                </label>
                <select
                  value={type}
                  onChange={(e) => setType(e.target.value as AccountType)}
                  className="w-full bg-slate-800 border border-slate-700 rounded-xl px-3 py-2 text-xs text-slate-100 focus:outline-none focus:border-emerald-500"
                >
                  <option value="bank">Bank Checking / Savings</option>
                  <option value="cash">Physical Cash</option>
                  <option value="wallet">Digital Wallet</option>
                  <option value="savings">Fixed / Investment Savings</option>
                </select>
              </div>

              {/* Invariant: Account creation and opening balance are one atomic operation */}
              <div className="p-4 rounded-xl bg-slate-800/80 border border-slate-700 space-y-3">
                <span className="text-[11px] uppercase tracking-wider font-bold text-emerald-400 block">
                  Initial Opening Balance (Ledger Entry)
                </span>
                <p className="text-[11px] text-slate-400 leading-normal">
                  In accordance with ledger invariants, opening balances are recorded as a signed opening transaction.
                </p>

                <div className="grid grid-cols-2 gap-2">
                  <div>
                    <label className="block text-[10px] uppercase text-slate-400 mb-1">
                      Starting Balance ({currency})
                    </label>
                    <input
                      type="number"
                      step="0.01"
                      value={openingBalanceStr}
                      onChange={(e) => setOpeningBalanceStr(e.target.value)}
                      placeholder="0.00"
                      className="w-full bg-slate-900 border border-slate-700 rounded-xl px-3 py-1.5 text-sm font-mono font-bold text-slate-100 focus:outline-none focus:border-emerald-500"
                    />
                  </div>
                  <div>
                    <label className="block text-[10px] uppercase text-slate-400 mb-1">
                      Direction
                    </label>
                    <select
                      value={openingDirection}
                      onChange={(e) =>
                        setOpeningDirection(e.target.value as 'credit' | 'debit')
                      }
                      className="w-full bg-slate-900 border border-slate-700 rounded-xl px-3 py-1.5 text-xs text-slate-100 focus:outline-none focus:border-emerald-500"
                    >
                      <option value="credit">Credit (Positive Asset)</option>
                      <option value="debit">Debit (Overdraft / Negative)</option>
                    </select>
                  </div>
                </div>
              </div>

              <div className="pt-3 flex items-center justify-end space-x-2 border-t border-slate-800">
                <button
                  type="button"
                  onClick={() => setIsAddModalOpen(false)}
                  className="px-4 py-2 text-xs font-semibold text-slate-400 hover:text-slate-200"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-5 py-2 rounded-xl bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-bold text-xs flex items-center space-x-1.5 transition-all shadow-md shadow-emerald-500/20"
                >
                  <Check className="w-4 h-4 stroke-[3]" />
                  <span>Create Account & Post Opening</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
