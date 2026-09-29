import React, { useState } from 'react';
import {
  ShieldCheck,
  Plus,
  Tag,
  Briefcase,
  ToggleLeft,
  ToggleRight,
  Trash2,
  X,
  Check,
  Sparkles,
} from 'lucide-react';
import { Category, IncomeSource, CategorizationRule, Account } from '../types';

interface CategoriesViewProps {
  categories: Category[];
  incomeSources: IncomeSource[];
  rules: CategorizationRule[];
  accounts: Account[];
  onAddCategory: (cat: Omit<Category, 'id'>) => void;
  onAddIncomeSource: (src: Omit<IncomeSource, 'id'>) => void;
  onAddRule: (rule: Omit<CategorizationRule, 'id'>) => void;
  onToggleRule: (id: string) => void;
  onDeleteRule: (id: string) => void;
}

export const CategoriesView: React.FC<CategoriesViewProps> = ({
  categories,
  incomeSources,
  rules,
  accounts,
  onAddCategory,
  onAddIncomeSource,
  onAddRule,
  onToggleRule,
  onDeleteRule,
}) => {
  const [activeTab, setActiveTab] = useState<'rules' | 'categories' | 'sources'>('rules');

  // New Rule Modal
  const [isRuleModalOpen, setIsRuleModalOpen] = useState(false);
  const [rulePattern, setRulePattern] = useState('');
  const [ruleKind, setRuleKind] = useState<'keyword' | 'merchantExact'>('keyword');
  const [ruleType, setRuleType] = useState<'expense' | 'income'>('expense');
  const [ruleCategoryId, setRuleCategoryId] = useState(
    categories.find((c) => c.type === 'expense')?.id || ''
  );
  const [rulePriority, setRulePriority] = useState(10);

  // New Category Modal
  const [isCatModalOpen, setIsCatModalOpen] = useState(false);
  const [catName, setCatName] = useState('');
  const [catType, setCatType] = useState<'expense' | 'income'>('expense');

  // New Source Modal
  const [isSrcModalOpen, setIsSrcModalOpen] = useState(false);
  const [srcName, setSrcName] = useState('');
  const [srcType, setSrcType] = useState<'employer' | 'freelance' | 'business' | 'investment' | 'other'>('employer');

  const getCategoryName = (id: string) =>
    categories.find((c) => c.id === id)?.name || id;

  const handleCreateRule = (e: React.FormEvent) => {
    e.preventDefault();
    if (!rulePattern.trim() || !ruleCategoryId) return;

    onAddRule({
      matchKind: ruleKind,
      normalizedPattern: rulePattern.trim().toLowerCase(),
      transactionType: ruleType,
      categoryId: ruleCategoryId,
      suggestedAccountId: null,
      suggestedIncomeSourceId: null,
      priority: Number(rulePriority),
      enabled: true,
      origin: 'user',
    });

    setIsRuleModalOpen(false);
    setRulePattern('');
  };

  const handleCreateCat = (e: React.FormEvent) => {
    e.preventDefault();
    if (!catName.trim()) return;

    onAddCategory({
      name: catName.trim(),
      type: catType,
      parentId: null,
      icon: 'Tag',
      sortOrder: categories.length + 1,
      isSystem: false,
      archived: false,
    });

    setIsCatModalOpen(false);
    setCatName('');
  };

  const handleCreateSrc = (e: React.FormEvent) => {
    e.preventDefault();
    if (!srcName.trim()) return;

    onAddIncomeSource({
      name: srcName.trim(),
      type: srcType,
      defaultAccountId: accounts[0]?.id || null,
      archived: false,
    });

    setIsSrcModalOpen(false);
    setSrcName('');
  };

  return (
    <div className="space-y-6">
      {/* Tab Switcher */}
      <div className="flex items-center justify-between border-b border-slate-800 pb-3">
        <div className="flex space-x-2">
          <button
            onClick={() => setActiveTab('rules')}
            className={`px-3.5 py-1.5 rounded-xl text-xs font-semibold transition-colors cursor-pointer ${
              activeTab === 'rules'
                ? 'bg-emerald-500/20 text-emerald-400 border border-emerald-500/30'
                : 'text-slate-400 hover:text-slate-200'
            }`}
          >
            Categorization Rules ({rules.length})
          </button>
          <button
            onClick={() => setActiveTab('categories')}
            className={`px-3.5 py-1.5 rounded-xl text-xs font-semibold transition-colors cursor-pointer ${
              activeTab === 'categories'
                ? 'bg-emerald-500/20 text-emerald-400 border border-emerald-500/30'
                : 'text-slate-400 hover:text-slate-200'
            }`}
          >
            Categories ({categories.length})
          </button>
          <button
            onClick={() => setActiveTab('sources')}
            className={`px-3.5 py-1.5 rounded-xl text-xs font-semibold transition-colors cursor-pointer ${
              activeTab === 'sources'
                ? 'bg-emerald-500/20 text-emerald-400 border border-emerald-500/30'
                : 'text-slate-400 hover:text-slate-200'
            }`}
          >
            Income Sources ({incomeSources.length})
          </button>
        </div>

        {activeTab === 'rules' && (
          <button
            onClick={() => setIsRuleModalOpen(true)}
            className="px-3.5 py-1.5 rounded-xl bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-bold text-xs flex items-center space-x-1.5 transition-all shadow-md shadow-emerald-500/20 cursor-pointer"
          >
            <Plus className="w-4 h-4 stroke-[3]" />
            <span>Add Rule</span>
          </button>
        )}

        {activeTab === 'categories' && (
          <button
            onClick={() => setIsCatModalOpen(true)}
            className="px-3.5 py-1.5 rounded-xl bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-bold text-xs flex items-center space-x-1.5 transition-all shadow-md shadow-emerald-500/20 cursor-pointer"
          >
            <Plus className="w-4 h-4 stroke-[3]" />
            <span>Add Category</span>
          </button>
        )}

        {activeTab === 'sources' && (
          <button
            onClick={() => setIsSrcModalOpen(true)}
            className="px-3.5 py-1.5 rounded-xl bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-bold text-xs flex items-center space-x-1.5 transition-all shadow-md shadow-emerald-500/20 cursor-pointer"
          >
            <Plus className="w-4 h-4 stroke-[3]" />
            <span>Add Source</span>
          </button>
        )}
      </div>

      {/* Rules Tab */}
      {activeTab === 'rules' && (
        <div className="space-y-4">
          <div className="p-4 rounded-xl bg-slate-800/40 border border-slate-700/60 text-xs text-slate-300 flex items-start space-x-3">
            <ShieldCheck className="w-5 h-5 text-emerald-400 shrink-0 mt-0.5" />
            <div>
              <span className="font-semibold text-slate-100">
                Deterministic Rule Priority
              </span>
              <p className="text-slate-400 mt-0.5">
                Local rules execute before or in verification with AI models. Matches automatically pre-populate candidate categories with 98% confidence.
              </p>
            </div>
          </div>

          <div className="bg-slate-800/40 rounded-2xl border border-slate-700/60 overflow-hidden divide-y divide-slate-800">
            {rules.length === 0 ? (
              <div className="p-8 text-center text-xs text-slate-400">
                No categorization rules defined yet.
              </div>
            ) : (
              rules.map((rule) => (
                <div
                  key={rule.id}
                  className="p-4 flex items-center justify-between hover:bg-slate-800/60 transition-colors"
                >
                  <div className="flex items-center space-x-3">
                    <button
                      onClick={() => onToggleRule(rule.id)}
                      className="cursor-pointer text-slate-400 hover:text-emerald-400 transition-colors"
                    >
                      {rule.enabled ? (
                        <ToggleRight className="w-6 h-6 text-emerald-400" />
                      ) : (
                        <ToggleLeft className="w-6 h-6 text-slate-600" />
                      )}
                    </button>
                    <div>
                      <div className="flex items-center space-x-2">
                        <span className="text-sm font-bold font-mono text-emerald-300">
                          "{rule.normalizedPattern}"
                        </span>
                        <span className="text-[10px] uppercase font-mono px-1.5 py-0.5 rounded bg-slate-700 text-slate-300">
                          {rule.matchKind}
                        </span>
                        <span className="text-[10px] uppercase font-mono px-1.5 py-0.5 rounded bg-slate-700 text-slate-300">
                          priority {rule.priority}
                        </span>
                      </div>
                      <div className="text-xs text-slate-400 mt-0.5">
                        Categorizes as{' '}
                        <span className="text-slate-200 font-semibold">
                          {getCategoryName(rule.categoryId)}
                        </span>{' '}
                        ({rule.transactionType})
                      </div>
                    </div>
                  </div>

                  <button
                    onClick={() => onDeleteRule(rule.id)}
                    className="p-1.5 text-slate-500 hover:text-rose-400 transition-colors cursor-pointer"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              ))
            )}
          </div>
        </div>
      )}

      {/* Categories Tab */}
      {activeTab === 'categories' && (
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          {/* Expense Categories */}
          <div className="p-5 rounded-2xl bg-slate-800/40 border border-slate-700/60 space-y-3">
            <h3 className="text-sm font-bold text-rose-400 uppercase tracking-wider flex items-center space-x-2">
              <Tag className="w-4 h-4" />
              <span>Expense Categories</span>
            </h3>
            <div className="divide-y divide-slate-800">
              {categories
                .filter((c) => c.type === 'expense')
                .map((c) => (
                  <div key={c.id} className="py-2.5 flex items-center justify-between text-xs">
                    <span className="text-slate-200 font-medium">{c.name}</span>
                    {c.isSystem && (
                      <span className="text-[10px] text-slate-400 font-mono">System</span>
                    )}
                  </div>
                ))}
            </div>
          </div>

          {/* Income Categories */}
          <div className="p-5 rounded-2xl bg-slate-800/40 border border-slate-700/60 space-y-3">
            <h3 className="text-sm font-bold text-emerald-400 uppercase tracking-wider flex items-center space-x-2">
              <Tag className="w-4 h-4" />
              <span>Income Categories</span>
            </h3>
            <div className="divide-y divide-slate-800">
              {categories
                .filter((c) => c.type === 'income')
                .map((c) => (
                  <div key={c.id} className="py-2.5 flex items-center justify-between text-xs">
                    <span className="text-slate-200 font-medium">{c.name}</span>
                    {c.isSystem && (
                      <span className="text-[10px] text-slate-400 font-mono">System</span>
                    )}
                  </div>
                ))}
            </div>
          </div>
        </div>
      )}

      {/* Income Sources Tab */}
      {activeTab === 'sources' && (
        <div className="p-5 rounded-2xl bg-slate-800/40 border border-slate-700/60 space-y-3">
          <div className="flex items-center space-x-2">
            <Briefcase className="w-4 h-4 text-emerald-400" />
            <h3 className="text-sm font-bold text-slate-100 uppercase tracking-wider">
              Income Sources (Origins)
            </h3>
          </div>
          <p className="text-xs text-slate-400">
            Per domain invariants, every confirmed income transaction requires an income source identifying origin.
          </p>

          <div className="divide-y divide-slate-800">
            {incomeSources.map((s) => (
              <div key={s.id} className="py-3 flex items-center justify-between text-xs">
                <div>
                  <div className="font-semibold text-slate-200">{s.name}</div>
                  <div className="text-[11px] text-slate-400 uppercase font-mono mt-0.5">
                    {s.type}
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Add Rule Modal */}
      {isRuleModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/80 backdrop-blur-sm animate-in fade-in">
          <div className="bg-slate-900 border border-slate-800 rounded-3xl w-full max-w-sm overflow-hidden shadow-2xl">
            <div className="p-5 border-b border-slate-800 flex items-center justify-between">
              <h3 className="text-base font-bold text-slate-100">
                New Categorization Rule
              </h3>
              <button
                onClick={() => setIsRuleModalOpen(false)}
                className="text-slate-400 hover:text-slate-200"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleCreateRule} className="p-6 space-y-4">
              <div>
                <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1">
                  Pattern / Keyword *
                </label>
                <input
                  type="text"
                  required
                  value={rulePattern}
                  onChange={(e) => setRulePattern(e.target.value)}
                  placeholder="e.g. keells, uber, dialog"
                  className="w-full bg-slate-800 border border-slate-700 rounded-xl px-3 py-2 text-xs text-slate-100 focus:outline-none focus:border-emerald-500"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1">
                  Match Kind
                </label>
                <select
                  value={ruleKind}
                  onChange={(e) =>
                    setRuleKind(e.target.value as 'keyword' | 'merchantExact')
                  }
                  className="w-full bg-slate-800 border border-slate-700 rounded-xl px-3 py-2 text-xs text-slate-100 focus:outline-none focus:border-emerald-500"
                >
                  <option value="keyword">Keyword (Substring match)</option>
                  <option value="merchantExact">Exact Merchant Match</option>
                </select>
              </div>

              <div>
                <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1">
                  Transaction Type
                </label>
                <select
                  value={ruleType}
                  onChange={(e) =>
                    setRuleType(e.target.value as 'expense' | 'income')
                  }
                  className="w-full bg-slate-800 border border-slate-700 rounded-xl px-3 py-2 text-xs text-slate-100 focus:outline-none focus:border-emerald-500"
                >
                  <option value="expense">Expense</option>
                  <option value="income">Income</option>
                </select>
              </div>

              <div>
                <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1">
                  Assign Category
                </label>
                <select
                  value={ruleCategoryId}
                  onChange={(e) => setRuleCategoryId(e.target.value)}
                  className="w-full bg-slate-800 border border-slate-700 rounded-xl px-3 py-2 text-xs text-slate-100 focus:outline-none focus:border-emerald-500"
                >
                  {categories
                    .filter((c) => c.type === ruleType)
                    .map((c) => (
                      <option key={c.id} value={c.id}>
                        {c.name}
                      </option>
                    ))}
                </select>
              </div>

              <div>
                <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1">
                  Priority (1-20)
                </label>
                <input
                  type="number"
                  min="1"
                  max="20"
                  value={rulePriority}
                  onChange={(e) => setRulePriority(Number(e.target.value))}
                  className="w-full bg-slate-800 border border-slate-700 rounded-xl px-3 py-2 text-xs text-slate-100 focus:outline-none focus:border-emerald-500"
                />
              </div>

              <div className="pt-3 flex items-center justify-end space-x-2 border-t border-slate-800">
                <button
                  type="button"
                  onClick={() => setIsRuleModalOpen(false)}
                  className="px-4 py-2 text-xs text-slate-400 hover:text-slate-200"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-5 py-2 rounded-xl bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-bold text-xs flex items-center space-x-1.5 transition-all shadow-md shadow-emerald-500/20"
                >
                  <Check className="w-4 h-4 stroke-[3]" />
                  <span>Save Rule</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Add Category Modal */}
      {isCatModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/80 backdrop-blur-sm animate-in fade-in">
          <div className="bg-slate-900 border border-slate-800 rounded-3xl w-full max-w-sm overflow-hidden shadow-2xl">
            <div className="p-5 border-b border-slate-800 flex items-center justify-between">
              <h3 className="text-base font-bold text-slate-100">
                New Category
              </h3>
              <button
                onClick={() => setIsCatModalOpen(false)}
                className="text-slate-400 hover:text-slate-200"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleCreateCat} className="p-6 space-y-4">
              <div>
                <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1">
                  Category Name *
                </label>
                <input
                  type="text"
                  required
                  value={catName}
                  onChange={(e) => setCatName(e.target.value)}
                  placeholder="e.g. Education, Subscriptions"
                  className="w-full bg-slate-800 border border-slate-700 rounded-xl px-3 py-2 text-xs text-slate-100 focus:outline-none focus:border-emerald-500"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1">
                  Type
                </label>
                <select
                  value={catType}
                  onChange={(e) =>
                    setCatType(e.target.value as 'expense' | 'income')
                  }
                  className="w-full bg-slate-800 border border-slate-700 rounded-xl px-3 py-2 text-xs text-slate-100 focus:outline-none focus:border-emerald-500"
                >
                  <option value="expense">Expense</option>
                  <option value="income">Income</option>
                </select>
              </div>

              <div className="pt-3 flex items-center justify-end space-x-2 border-t border-slate-800">
                <button
                  type="button"
                  onClick={() => setIsCatModalOpen(false)}
                  className="px-4 py-2 text-xs text-slate-400 hover:text-slate-200"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-5 py-2 rounded-xl bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-bold text-xs"
                >
                  Create Category
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Add Income Source Modal */}
      {isSrcModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/80 backdrop-blur-sm animate-in fade-in">
          <div className="bg-slate-900 border border-slate-800 rounded-3xl w-full max-w-sm overflow-hidden shadow-2xl">
            <div className="p-5 border-b border-slate-800 flex items-center justify-between">
              <h3 className="text-base font-bold text-slate-100">
                New Income Source
              </h3>
              <button
                onClick={() => setIsSrcModalOpen(false)}
                className="text-slate-400 hover:text-slate-200"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleCreateSrc} className="p-6 space-y-4">
              <div>
                <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1">
                  Source Name *
                </label>
                <input
                  type="text"
                  required
                  value={srcName}
                  onChange={(e) => setSrcName(e.target.value)}
                  placeholder="e.g. Client X, Stock Dividends"
                  className="w-full bg-slate-800 border border-slate-700 rounded-xl px-3 py-2 text-xs text-slate-100 focus:outline-none focus:border-emerald-500"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1">
                  Source Type
                </label>
                <select
                  value={srcType}
                  onChange={(e) =>
                    setSrcType(
                      e.target.value as
                        | 'employer'
                        | 'freelance'
                        | 'business'
                        | 'investment'
                        | 'other'
                    )
                  }
                  className="w-full bg-slate-800 border border-slate-700 rounded-xl px-3 py-2 text-xs text-slate-100 focus:outline-none focus:border-emerald-500"
                >
                  <option value="employer">Employer / Corporate Salary</option>
                  <option value="freelance">Freelance / Contracting</option>
                  <option value="business">Business Revenue</option>
                  <option value="investment">Investments & Dividends</option>
                  <option value="other">Other</option>
                </select>
              </div>

              <div className="pt-3 flex items-center justify-end space-x-2 border-t border-slate-800">
                <button
                  type="button"
                  onClick={() => setIsSrcModalOpen(false)}
                  className="px-4 py-2 text-xs text-slate-400 hover:text-slate-200"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-5 py-2 rounded-xl bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-bold text-xs"
                >
                  Create Source
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
