import React, { useState } from 'react';
import {
  Sparkles,
  X,
  Check,
  AlertCircle,
  ShieldCheck,
  ArrowRight,
  TrendingDown,
  TrendingUp,
  ArrowRightLeft,
  Info,
  Loader2,
} from 'lucide-react';
import {
  Account,
  Category,
  IncomeSource,
  Transaction,
  CategorizationRule,
  AIActivity,
} from '../types';
import { formatMoney, parseMoneyToMinor, validateTransaction } from '../ledger';
import { matchCategorizationRule } from '../storage';

interface TransactionParserModalProps {
  isOpen: boolean;
  onClose: () => void;
  accounts: Account[];
  categories: Category[];
  incomeSources: IncomeSource[];
  rules: CategorizationRule[];
  currency: string;
  onConfirmTransaction: (
    tx: Omit<Transaction, 'id'>,
    saveRule?: {
      matchKind: 'keyword';
      pattern: string;
      categoryId: string;
    }
  ) => void;
  onLogActivity: (activity: Omit<AIActivity, 'id' | 'timestamp'>) => void;
}

export const TransactionParserModal: React.FC<TransactionParserModalProps> = ({
  isOpen,
  onClose,
  accounts,
  categories,
  incomeSources,
  rules,
  currency,
  onConfirmTransaction,
  onLogActivity,
}) => {
  const [rawText, setRawText] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Proposal candidate state
  const [candidate, setCandidate] = useState<{
    type: 'expense' | 'income' | 'transfer';
    amountMinor: number;
    amountDisplay: string;
    currency: string;
    accountId: string;
    destinationAccountId: string;
    categoryId: string;
    incomeSourceId: string;
    merchant: string;
    description: string;
    confidence: number;
    fieldConfidence: Record<string, number>;
    reasoning: string;
    provider: string;
  } | null>(null);

  const [shouldSaveRule, setShouldSaveRule] = useState(false);

  if (!isOpen) return null;

  const examplePrompts = [
    'Keells supermarket 4,500 LKR from ComBank',
    'Received salary 180,000 from Virtusa into ComBank',
    'Transferred 10,000 from ComBank to Cash wallet',
    'Dinner at Perera & Sons 1,850 LKR from Cash',
  ];

  const handleParse = async (textToParse: string = rawText) => {
    if (!textToParse.trim()) {
      setError('Please enter a transaction description.');
      return;
    }

    setIsLoading(true);
    setError(null);
    const startTime = Date.now();

    try {
      const response = await fetch('/api/parse-transaction', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          rawText: textToParse,
          accounts: accounts.map((a) => ({ id: a.id, name: a.name, type: a.type })),
          categories: categories.map((c) => ({ id: c.id, name: c.name, type: c.type })),
          incomeSources: incomeSources.map((s) => ({ id: s.id, name: s.name })),
          currency,
        }),
      });

      if (!response.ok) {
        throw new Error(`Server returned ${response.status}`);
      }

      const data = await response.json();
      const cand = data.candidate;

      // Also check local deterministic rule engine to enhance or cross-reference
      if (cand.type === 'expense' || cand.type === 'income') {
        const matchedRule = matchCategorizationRule(
          textToParse,
          cand.merchant,
          rules,
          cand.type
        );
        if (matchedRule) {
          cand.categoryId = matchedRule.categoryId;
          cand.fieldConfidence = {
            ...cand.fieldConfidence,
            categoryId: 0.98,
          };
          cand.reasoning += ` Matched user rule "${matchedRule.normalizedPattern}".`;
        }
      }

      // Default account if missing
      const finalAccountId =
        cand.accountId ||
        (accounts.length > 0 ? accounts[0].id : '');

      const finalDestAccountId =
        cand.type === 'transfer'
          ? cand.destinationAccountId ||
            (accounts.find((a) => a.id !== finalAccountId)?.id || '')
          : '';

      const finalCategoryId =
        cand.categoryId ||
        (cand.type !== 'transfer'
          ? categories.find((c) => c.type === (cand.type === 'income' ? 'income' : 'expense'))?.id || ''
          : '');

      const finalIncomeSourceId =
        cand.type === 'income'
          ? cand.incomeSourceId || (incomeSources.length > 0 ? incomeSources[0].id : '')
          : '';

      setCandidate({
        type: cand.type || 'expense',
        amountMinor: cand.amountMinor || 0,
        amountDisplay: ((cand.amountMinor || 0) / 100).toFixed(2),
        currency: cand.currency || currency,
        accountId: finalAccountId,
        destinationAccountId: finalDestAccountId,
        categoryId: finalCategoryId,
        incomeSourceId: finalIncomeSourceId,
        merchant: cand.merchant || '',
        description: cand.description || textToParse,
        confidence: cand.confidence || 0.8,
        fieldConfidence: cand.fieldConfidence || {},
        reasoning: cand.reasoning || 'Parsed by financial agent.',
        provider: data.provider || 'ai_agent',
      });

      onLogActivity({
        agentType: 'transactionParsing',
        action: 'Natural Language Parse',
        outcome: 'proposed',
        summary: `Parsed proposal for "${textToParse.slice(0, 40)}..." [${cand.type}] with ${Math.round((cand.confidence || 0.8) * 100)}% confidence.`,
        entityIds: [],
        provider: data.provider,
        latencyMs: Date.now() - startTime,
      });
    } catch (err: unknown) {
      console.error('Parse failed', err);
      setError('Could not connect to parser. Falling back to manual entry.');
    } finally {
      setIsLoading(false);
    }
  };

  const handleConfirmAndPost = () => {
    if (!candidate) return;

    const parsedMinor = parseMoneyToMinor(candidate.amountDisplay);
    if (parsedMinor <= 0) {
      setError('Amount must be greater than zero.');
      return;
    }

    const payload: Omit<Transaction, 'id'> = {
      type: candidate.type,
      amountMinor: parsedMinor,
      currency: candidate.currency,
      accountId: candidate.accountId,
      destinationAccountId:
        candidate.type === 'transfer' ? candidate.destinationAccountId : null,
      incomeSourceId:
        candidate.type === 'income' ? candidate.incomeSourceId : null,
      categoryId: candidate.type !== 'transfer' ? candidate.categoryId : null,
      merchant: candidate.merchant.trim() || null,
      description: candidate.description.trim(),
      occurredAt: new Date().toISOString(),
      effectiveDate: new Date().toISOString().slice(0, 10),
      entryTimeZone: 'Asia/Colombo',
      origin: 'aiInput',
      categorizationSource: candidate.confidence > 0.8 ? 'ai' : 'manual',
      proposalId: 'prop-' + Date.now(),
      openingDirection: null,
    };

    const valError = validateTransaction(payload, accounts, categories, incomeSources);
    if (valError) {
      setError(valError);
      return;
    }

    let ruleToSave = undefined;
    if (shouldSaveRule && candidate.merchant.trim() && candidate.categoryId) {
      ruleToSave = {
        matchKind: 'keyword' as const,
        pattern: candidate.merchant.trim().toLowerCase(),
        categoryId: candidate.categoryId,
      };
    }

    onConfirmTransaction(payload, ruleToSave);

    onLogActivity({
      agentType: 'transactionParsing',
      action: 'Confirm Proposal to Ledger',
      outcome: 'applied',
      summary: `User explicitly confirmed proposal: ${formatMoney(parsedMinor, candidate.currency)} posted to account ledger.`,
      entityIds: [candidate.accountId],
      provider: candidate.provider,
    });

    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/80 backdrop-blur-sm animate-in fade-in duration-200">
      <div className="bg-slate-900 border border-slate-800 rounded-3xl w-full max-w-2xl overflow-hidden shadow-2xl flex flex-col max-h-[90vh]">
        {/* Modal Header */}
        <div className="p-5 border-b border-slate-800 flex items-center justify-between bg-slate-900/60">
          <div className="flex items-center space-x-3">
            <div className="p-2.5 rounded-xl bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
              <Sparkles className="w-5 h-5" />
            </div>
            <div>
              <h3 className="text-base font-bold text-slate-100">
                AI Natural Language Entry
              </h3>
              <p className="text-xs text-slate-400">
                AI generates a proposal. Deterministic code commits to the ledger.
              </p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-2 rounded-xl text-slate-400 hover:text-slate-200 hover:bg-slate-800 transition-colors cursor-pointer"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Modal Body */}
        <div className="p-6 space-y-6 overflow-y-auto">
          {/* Natural Language Prompt Area */}
          <div>
            <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-2">
              Describe your transaction in plain language
            </label>
            <div className="relative">
              <textarea
                value={rawText}
                onChange={(e) => setRawText(e.target.value)}
                onKeyDown={(e) => {
                  if (e.key === 'Enter' && (e.metaKey || e.ctrlKey)) {
                    e.preventDefault();
                    handleParse();
                  }
                }}
                rows={3}
                placeholder="e.g. Paid 3500 LKR for groceries at Keells using Commercial Bank"
                className="w-full bg-slate-800/70 border border-slate-700/80 rounded-2xl p-3.5 text-sm text-slate-100 placeholder:text-slate-400 focus:outline-none focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500 transition-all resize-none"
              />
            </div>

            {/* Quick Example Pills */}
            <div className="mt-2.5 flex items-center gap-1.5 flex-wrap">
              <span className="text-[11px] text-slate-400">Examples:</span>
              {examplePrompts.map((prompt, idx) => (
                <button
                  key={idx}
                  type="button"
                  onClick={() => {
                    setRawText(prompt);
                    handleParse(prompt);
                  }}
                  className="text-[11px] px-2.5 py-1 rounded-lg bg-slate-800 hover:bg-slate-700 text-slate-300 border border-slate-700/60 transition-colors cursor-pointer line-clamp-1"
                >
                  {prompt}
                </button>
              ))}
            </div>

            {/* Analyze Action */}
            <div className="mt-4 flex items-center justify-between">
              <span className="text-[11px] text-slate-400">
                Press Ctrl+Enter or click Parse
              </span>
              <button
                type="button"
                disabled={isLoading || !rawText.trim()}
                onClick={() => handleParse()}
                className="px-4 py-2 rounded-xl bg-emerald-500 hover:bg-emerald-400 disabled:bg-slate-800 disabled:text-slate-400 text-slate-950 font-semibold text-xs sm:text-sm flex items-center space-x-2 transition-all cursor-pointer shadow-md shadow-emerald-500/20"
              >
                {isLoading ? (
                  <>
                    <Loader2 className="w-4 h-4 animate-spin" />
                    <span>Analyzing...</span>
                  </>
                ) : (
                  <>
                    <Sparkles className="w-4 h-4" />
                    <span>Analyze with Agent</span>
                  </>
                )}
              </button>
            </div>
          </div>

          {error && (
            <div className="p-3.5 rounded-xl bg-rose-500/10 border border-rose-500/20 text-rose-400 text-xs flex items-center space-x-2">
              <AlertCircle className="w-4 h-4 shrink-0" />
              <span>{error}</span>
            </div>
          )}

          {/* AI Proposal Card */}
          {candidate && (
            <div className="p-5 rounded-2xl bg-slate-800/40 border border-emerald-500/40 space-y-4 shadow-inner">
              <div className="flex items-center justify-between border-b border-slate-700/60 pb-3">
                <div className="flex items-center space-x-2">
                  <ShieldCheck className="w-4 h-4 text-emerald-400" />
                  <span className="text-xs font-bold uppercase tracking-wider text-slate-200">
                    Agent Proposal (Explicit Confirmation Required)
                  </span>
                </div>
                <div className="flex items-center space-x-2">
                  <span className="text-[11px] px-2 py-0.5 rounded-full bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 font-mono">
                    {Math.round(candidate.confidence * 100)}% Confidence
                  </span>
                  <span className="text-[10px] text-slate-400 font-mono">
                    {candidate.provider}
                  </span>
                </div>
              </div>

              {/* Reasoning */}
              <div className="p-3 rounded-xl bg-slate-900/60 border border-slate-700/50 text-xs text-slate-300 leading-relaxed flex items-start space-x-2">
                <Info className="w-4 h-4 text-emerald-400 shrink-0 mt-0.5" />
                <div>
                  <span className="font-semibold text-emerald-400">Why Suggested: </span>
                  {candidate.reasoning}
                </div>
              </div>

              {/* Editable Fields Grid */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                {/* Type Selection */}
                <div>
                  <label className="block text-[11px] font-semibold uppercase tracking-wider text-slate-400 mb-1">
                    Transaction Type
                  </label>
                  <div className="grid grid-cols-3 gap-1 bg-slate-900 p-1 rounded-xl border border-slate-700">
                    {(['expense', 'income', 'transfer'] as const).map((t) => (
                      <button
                        key={t}
                        type="button"
                        onClick={() => setCandidate({ ...candidate, type: t })}
                        className={`text-xs py-1.5 rounded-lg font-medium capitalize transition-colors cursor-pointer ${
                          candidate.type === t
                            ? t === 'expense'
                              ? 'bg-rose-500/20 text-rose-300 font-semibold'
                              : t === 'income'
                              ? 'bg-emerald-500/20 text-emerald-300 font-semibold'
                              : 'bg-blue-500/20 text-blue-300 font-semibold'
                            : 'text-slate-400 hover:text-slate-200'
                        }`}
                      >
                        {t}
                      </button>
                    ))}
                  </div>
                </div>

                {/* Amount */}
                <div>
                  <label className="block text-[11px] font-semibold uppercase tracking-wider text-slate-400 mb-1">
                    Amount ({currency})
                  </label>
                  <input
                    type="number"
                    step="0.01"
                    value={candidate.amountDisplay}
                    onChange={(e) =>
                      setCandidate({ ...candidate, amountDisplay: e.target.value })
                    }
                    className="w-full bg-slate-900 border border-slate-700 rounded-xl px-3 py-1.5 text-sm font-mono font-bold text-slate-100 focus:outline-none focus:border-emerald-500"
                  />
                </div>

                {/* Funding / Primary Account */}
                <div>
                  <label className="block text-[11px] font-semibold uppercase tracking-wider text-slate-400 mb-1">
                    {candidate.type === 'income'
                      ? 'Destination Account'
                      : candidate.type === 'transfer'
                      ? 'Source Account'
                      : 'Funding Account'}
                  </label>
                  <select
                    value={candidate.accountId}
                    onChange={(e) =>
                      setCandidate({ ...candidate, accountId: e.target.value })
                    }
                    className="w-full bg-slate-900 border border-slate-700 rounded-xl px-3 py-1.5 text-xs text-slate-100 focus:outline-none focus:border-emerald-500"
                  >
                    {accounts.map((a) => (
                      <option key={a.id} value={a.id}>
                        {a.name} ({a.type})
                      </option>
                    ))}
                  </select>
                </div>

                {/* Destination Account (Only for Transfer) */}
                {candidate.type === 'transfer' && (
                  <div>
                    <label className="block text-[11px] font-semibold uppercase tracking-wider text-slate-400 mb-1">
                      Destination Account
                    </label>
                    <select
                      value={candidate.destinationAccountId}
                      onChange={(e) =>
                        setCandidate({
                          ...candidate,
                          destinationAccountId: e.target.value,
                        })
                      }
                      className="w-full bg-slate-900 border border-slate-700 rounded-xl px-3 py-1.5 text-xs text-slate-100 focus:outline-none focus:border-emerald-500"
                    >
                      {accounts
                        .filter((a) => a.id !== candidate.accountId)
                        .map((a) => (
                          <option key={a.id} value={a.id}>
                            {a.name} ({a.type})
                          </option>
                        ))}
                    </select>
                  </div>
                )}

                {/* Category (For Expense or Income) */}
                {candidate.type !== 'transfer' && (
                  <div>
                    <label className="block text-[11px] font-semibold uppercase tracking-wider text-slate-400 mb-1">
                      Category
                    </label>
                    <select
                      value={candidate.categoryId}
                      onChange={(e) =>
                        setCandidate({ ...candidate, categoryId: e.target.value })
                      }
                      className="w-full bg-slate-900 border border-slate-700 rounded-xl px-3 py-1.5 text-xs text-slate-100 focus:outline-none focus:border-emerald-500"
                    >
                      <option value="">-- Uncategorized --</option>
                      {categories
                        .filter((c) => c.type === (candidate.type === 'income' ? 'income' : 'expense'))
                        .map((c) => (
                          <option key={c.id} value={c.id}>
                            {c.name}
                          </option>
                        ))}
                    </select>
                  </div>
                )}

                {/* Income Source (For Income only) */}
                {candidate.type === 'income' && (
                  <div>
                    <label className="block text-[11px] font-semibold uppercase tracking-wider text-slate-400 mb-1">
                      Income Source (Origin)
                    </label>
                    <select
                      value={candidate.incomeSourceId}
                      onChange={(e) =>
                        setCandidate({ ...candidate, incomeSourceId: e.target.value })
                      }
                      className="w-full bg-slate-900 border border-slate-700 rounded-xl px-3 py-1.5 text-xs text-slate-100 focus:outline-none focus:border-emerald-500"
                    >
                      {incomeSources.map((s) => (
                        <option key={s.id} value={s.id}>
                          {s.name} ({s.type})
                        </option>
                      ))}
                    </select>
                  </div>
                )}

                {/* Merchant / Payee */}
                <div>
                  <label className="block text-[11px] font-semibold uppercase tracking-wider text-slate-400 mb-1">
                    Merchant / Payee / Origin
                  </label>
                  <input
                    type="text"
                    value={candidate.merchant}
                    onChange={(e) =>
                      setCandidate({ ...candidate, merchant: e.target.value })
                    }
                    placeholder="e.g. Keells Super"
                    className="w-full bg-slate-900 border border-slate-700 rounded-xl px-3 py-1.5 text-xs text-slate-100 focus:outline-none focus:border-emerald-500"
                  />
                </div>

                {/* Description */}
                <div>
                  <label className="block text-[11px] font-semibold uppercase tracking-wider text-slate-400 mb-1">
                    Description
                  </label>
                  <input
                    type="text"
                    value={candidate.description}
                    onChange={(e) =>
                      setCandidate({ ...candidate, description: e.target.value })
                    }
                    className="w-full bg-slate-900 border border-slate-700 rounded-xl px-3 py-1.5 text-xs text-slate-100 focus:outline-none focus:border-emerald-500"
                  />
                </div>
              </div>

              {/* Rule Learning Checkbox */}
              {candidate.merchant.trim() && candidate.categoryId && candidate.type !== 'transfer' && (
                <div className="flex items-center space-x-2 pt-2">
                  <input
                    type="checkbox"
                    id="saveRule"
                    checked={shouldSaveRule}
                    onChange={(e) => setShouldSaveRule(e.target.checked)}
                    className="w-4 h-4 rounded text-emerald-500 bg-slate-900 border-slate-700 focus:ring-emerald-500"
                  />
                  <label htmlFor="saveRule" className="text-xs text-slate-300 cursor-pointer">
                    Remember this: automatically categorize future transactions containing{' '}
                    <span className="font-semibold text-emerald-400">
                      "{candidate.merchant.trim()}"
                    </span>
                  </label>
                </div>
              )}
            </div>
          )}
        </div>

        {/* Modal Footer */}
        <div className="p-5 border-t border-slate-800 bg-slate-900/80 flex items-center justify-between">
          <button
            type="button"
            onClick={onClose}
            className="text-xs font-semibold px-4 py-2 rounded-xl text-slate-400 hover:text-slate-200 transition-colors cursor-pointer"
          >
            Cancel
          </button>

          {candidate && (
            <button
              type="button"
              onClick={handleConfirmAndPost}
              className="text-xs sm:text-sm font-semibold px-5 py-2.5 rounded-xl bg-gradient-to-r from-emerald-500 to-teal-500 hover:from-emerald-400 hover:to-teal-400 text-slate-950 flex items-center space-x-2 shadow-lg shadow-emerald-500/25 transition-all active:scale-95 cursor-pointer"
            >
              <Check className="w-4 h-4 stroke-[3]" />
              <span>Confirm & Post to Ledger</span>
            </button>
          )}
        </div>
      </div>
    </div>
  );
};
