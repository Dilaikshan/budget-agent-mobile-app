import { parseDecimalToMinor } from '../domain/money.js';
import { addDays, localDateOf } from '../domain/time.js';

/**
 * Deterministic rules before models (docs/06 "Rules before models"). Explicit
 * text wins; nothing is guessed when ambiguous; no new references are created.
 */

export interface AccountRef {
  id: string;
  name: string;
  type: 'bank' | 'cash' | 'wallet' | 'savings';
}
export interface CategoryRef {
  id: string;
  name: string;
  type: 'income' | 'expense';
  parentId: string | null;
}
export interface SourceRef {
  id: string;
  name: string;
  type: 'employer' | 'freelance' | 'business' | 'investment' | 'other';
  defaultAccountId: string | null;
}
export interface RuleRef {
  id: string;
  matchKind: 'merchantExact' | 'keyword';
  normalizedPattern: string;
  transactionType: 'income' | 'expense';
  categoryId: string;
  suggestedAccountId: string | null;
  suggestedIncomeSourceId: string | null;
  priority: number;
}

export interface ParseContext {
  accounts: AccountRef[];
  categories: CategoryRef[];
  sources: SourceRef[];
  rules: RuleRef[];
  currencyExponent: number;
}

export type Intent = 'income' | 'expense' | 'transfer' | 'unknown';
export type Field = 'intent' | 'amountMinor' | 'accountId' | 'destinationAccountId' | 'categoryId' | 'incomeSourceId' | 'effectiveDate' | 'merchant';

export interface RuleCandidate {
  intent: Intent;
  amountMinor: number | null;
  merchant: string | null;
  description: string;
  accountId: string | null;
  destinationAccountId: string | null;
  categoryId: string | null;
  incomeSourceId: string | null;
  effectiveDate: string | null;
  fieldConfidence: Partial<Record<Field, number>>;
  questions: string[];
  ruleMatches: number;
  /** Fields the user's text stated explicitly; a model may not override them. */
  explicit: Set<Field>;
  /** Tokens that would conflict if a model supplied a different value. */
  amountAmbiguous: boolean;
}

const TRANSFER_WORDS = new Set(['withdraw', 'withdrew', 'withdrawal', 'withdrawn', 'atm', 'transfer', 'transferred', 'moved', 'move']);
const WITHDRAW_WORDS = new Set(['withdraw', 'withdrew', 'withdrawal', 'withdrawn', 'atm']);
const INCOME_WORDS = new Set(['salary', 'freelance', 'received', 'income', 'bonus', 'dividend', 'earned', 'credited', 'wages']);
const DEPOSIT_WORDS = new Set(['deposit', 'deposited']);
const EXPENSE_WORDS = new Set(['paid', 'pay', 'bought', 'buy', 'spent', 'spend', 'bill', 'purchase', 'purchased']);
const STOP_WORDS = new Set(['bank', 'account', 'acc', 'savings', 'saving', 'current', 'wallet', 'the', 'my', 'of', 'plc', 'ltd', 'and']);

/** Curated merchant tokens → display name and category names tried in order. */
const MERCHANTS: Record<string, { display: string; categories: string[] }> = {
  kfc: { display: 'KFC', categories: ['Restaurant', 'Restaurants', 'Food'] },
  mcdonalds: { display: "McDonald's", categories: ['Restaurant', 'Restaurants', 'Food'] },
  keells: { display: 'Keells', categories: ['Groceries', 'Grocery', 'Food'] },
  cargills: { display: 'Cargills', categories: ['Groceries', 'Grocery', 'Food'] },
  arpico: { display: 'Arpico', categories: ['Groceries', 'Grocery', 'Shopping'] },
  spar: { display: 'SPAR', categories: ['Groceries', 'Grocery', 'Food'] },
  glomark: { display: 'Glomark', categories: ['Groceries', 'Grocery', 'Food'] },
  dialog: { display: 'Dialog', categories: ['Phone', 'Mobile', 'Bills'] },
  mobitel: { display: 'Mobitel', categories: ['Phone', 'Mobile', 'Bills'] },
  slt: { display: 'SLT', categories: ['Internet', 'Bills'] },
  uber: { display: 'Uber', categories: ['Taxi', 'Transport'] },
  pickme: { display: 'PickMe', categories: ['Taxi', 'Transport'] },
  daraz: { display: 'Daraz', categories: ['Shopping'] },
};

const KEYWORDS: Record<string, string[]> = {
  lunch: ['Restaurant', 'Restaurants', 'Food'],
  dinner: ['Restaurant', 'Restaurants', 'Food'],
  breakfast: ['Restaurant', 'Restaurants', 'Food'],
  coffee: ['Restaurant', 'Cafe', 'Food'],
  restaurant: ['Restaurant', 'Restaurants', 'Food'],
  groceries: ['Groceries', 'Grocery', 'Food'],
  grocery: ['Groceries', 'Grocery', 'Food'],
  supermarket: ['Groceries', 'Grocery', 'Food'],
  bus: ['Transport'],
  train: ['Transport'],
  taxi: ['Taxi', 'Transport'],
  tuk: ['Taxi', 'Transport'],
  fuel: ['Fuel', 'Transport'],
  petrol: ['Fuel', 'Transport'],
  electricity: ['Electricity', 'Bills'],
  water: ['Water', 'Bills'],
  rent: ['Rent', 'Housing', 'Bills'],
  salary: ['Salary'],
  freelance: ['Freelance'],
  bonus: ['Bonus', 'Salary'],
};

export function normalizeText(s: string): string {
  return s.normalize('NFC').toLowerCase().replace(/\s+/g, ' ').trim();
}

/** Merchant normalization: lowercase NFC and whitespace collapse; digits kept. */
export function normalizeMerchant(s: string): string {
  return normalizeText(s);
}

function words(s: string): string[] {
  return s.match(/[\p{L}\p{N}]+/gu) ?? [];
}

function hasToken(tokens: string[], phrase: string): boolean {
  const p = words(phrase);
  if (p.length === 0) return false;
  for (let i = 0; i + p.length <= tokens.length; i++) {
    if (p.every((w, j) => tokens[i + j] === w)) return true;
  }
  return false;
}

function significantTokens(name: string): string[] {
  return words(normalizeText(name)).filter((w) => w.length >= 3 && !STOP_WORDS.has(w));
}

interface Mention {
  accountId: string;
  index: number;
  preposition: string | null;
}

function findAccountMentions(tokens: string[], accounts: AccountRef[]): { mentions: Mention[]; ambiguousTokens: boolean } {
  const byToken = new Map<string, Set<string>>();
  const add = (tok: string, id: string) => {
    if (!byToken.has(tok)) byToken.set(tok, new Set());
    byToken.get(tok)!.add(id);
  };
  for (const a of accounts) for (const t of significantTokens(a.name)) add(t, a.id);
  const cash = accounts.filter((a) => a.type === 'cash');
  if (cash.length === 1) add('cash', cash[0]!.id);

  const mentions: Mention[] = [];
  let ambiguousTokens = false;
  tokens.forEach((tok, index) => {
    const ids = byToken.get(tok);
    if (!ids) return;
    if (ids.size > 1) {
      ambiguousTokens = true;
      return;
    }
    const accountId = [...ids][0]!;
    if (mentions.some((m) => m.accountId === accountId && Math.abs(m.index - index) <= 2)) return;
    const prev = tokens[index - 1] ?? null;
    mentions.push({ accountId, index, preposition: prev && ['from', 'to', 'into', 'via', 'using', 'with', 'by'].includes(prev) ? prev : null });
  });
  return { mentions, ambiguousTokens };
}

function extractAmount(normalized: string, exponent: number): { minor: number | null; ambiguous: boolean; tokens: string[] } {
  const spaced = normalized.replace(/(\d)([a-z])/g, '$1 $2').replace(/([a-z])(\d)/g, '$1 $2');
  const numeric = spaced
    .split(' ')
    .map((t) => t.replace(/[.,]+$/, ''))
    .filter((t) => /^[0-9][0-9.,]*$/.test(t));
  if (numeric.length === 0) return { minor: null, ambiguous: false, tokens: [] };
  if (numeric.length > 1) return { minor: null, ambiguous: true, tokens: numeric };
  const parsed = parseDecimalToMinor(numeric[0]!, exponent);
  return parsed.ok && parsed.minor > 0
    ? { minor: parsed.minor, ambiguous: false, tokens: numeric }
    : { minor: null, ambiguous: true, tokens: numeric };
}

function extractDate(normalized: string, tokens: string[], referenceNow: Date, tz: string): { date: string | null; explicit: boolean; ambiguous: boolean } {
  const today = localDateOf(referenceNow, tz);
  const iso = normalized.match(/\b(\d{4})-(\d{2})-(\d{2})\b/);
  if (iso) {
    const d = `${iso[1]}-${iso[2]}-${iso[3]}`;
    const valid = !Number.isNaN(Date.parse(`${d}T00:00:00Z`)) && new Date(`${d}T00:00:00Z`).toISOString().startsWith(d);
    return valid ? { date: d, explicit: true, ambiguous: false } : { date: null, explicit: false, ambiguous: true };
  }
  if (/\b\d{1,2}[/.]\d{1,2}([/.]\d{2,4})?\b/.test(normalized)) return { date: null, explicit: false, ambiguous: true };
  if (tokens.includes('yesterday')) return { date: addDays(today, -1), explicit: true, ambiguous: false };
  if (tokens.includes('today')) return { date: today, explicit: true, ambiguous: false };
  return { date: today, explicit: false, ambiguous: false };
}

function categoryByNames(names: string[], type: 'income' | 'expense', categories: CategoryRef[]): string | null {
  for (const n of names) {
    const hits = categories.filter((c) => c.type === type && normalizeText(c.name) === normalizeText(n));
    if (hits.length === 1) return hits[0]!.id;
  }
  return null;
}

export function applyRules(rawInput: string, ctx: ParseContext, referenceNow: Date, timeZone: string): RuleCandidate {
  const normalized = normalizeText(rawInput);
  const tokens = words(normalized);
  const questions: string[] = [];
  const fc: Partial<Record<Field, number>> = {};
  const explicit = new Set<Field>();
  let ruleMatches = 0;

  // Amount.
  const amount = extractAmount(normalized, ctx.currencyExponent);
  if (amount.minor !== null) {
    fc.amountMinor = 0.95;
    explicit.add('amountMinor');
  } else if (amount.ambiguous) {
    questions.push('Which amount should be recorded? Use digits with a "." decimal point.');
  } else {
    questions.push('What was the amount?');
  }

  // Intent.
  const has = (set: Set<string>) => tokens.some((t) => set.has(t));
  const accountMentions = findAccountMentions(tokens, ctx.accounts);
  const fromTo =
    accountMentions.mentions.find((m) => m.preposition === 'from') && accountMentions.mentions.find((m) => m.preposition === 'to' || m.preposition === 'into');
  let intent: Intent = 'unknown';
  const merchantKey = tokens.find((t) => t in MERCHANTS) ?? null;
  const keyword = tokens.find((t) => t in KEYWORDS) ?? null;
  const transferish = has(TRANSFER_WORDS) || (has(DEPOSIT_WORDS) && Boolean(fromTo));
  const incomeish = has(INCOME_WORDS);
  const expenseish = has(EXPENSE_WORDS) || merchantKey !== null || (keyword !== null && !['salary', 'freelance', 'bonus'].includes(keyword));
  if (transferish && !incomeish) intent = 'transfer';
  else if (incomeish && !transferish && !has(EXPENSE_WORDS)) intent = 'income';
  else if (expenseish && !transferish && !incomeish) intent = 'expense';
  if (intent !== 'unknown') {
    fc.intent = 0.9;
    explicit.add('intent');
  } else if (has(DEPOSIT_WORDS)) {
    questions.push('Is this income, or a transfer between your own accounts?');
  } else {
    questions.push('Is this an expense, income or a transfer?');
  }

  // Accounts.
  let accountId: string | null = null;
  let destinationAccountId: string | null = null;
  const ms = accountMentions.mentions;
  if (accountMentions.ambiguousTokens) questions.push('Which account did you mean?');
  if (intent === 'transfer') {
    const from = ms.find((m) => m.preposition === 'from');
    const to = ms.find((m) => m.preposition === 'to' || m.preposition === 'into');
    const cash = ctx.accounts.filter((a) => a.type === 'cash');
    if (from) accountId = from.accountId;
    if (to) destinationAccountId = to.accountId;
    if (has(WITHDRAW_WORDS)) {
      if (!accountId) accountId = ms.find((m) => ctx.accounts.find((a) => a.id === m.accountId)?.type !== 'cash')?.accountId ?? null;
      if (!destinationAccountId && cash.length === 1) {
        destinationAccountId = cash[0]!.id;
        fc.destinationAccountId = 0.7;
      }
    } else if (!from && !to && ms.length === 2) {
      accountId = ms[0]!.accountId;
      destinationAccountId = ms[1]!.accountId;
      fc.accountId = 0.6;
      fc.destinationAccountId = 0.6;
    }
    if (accountId && destinationAccountId && accountId === destinationAccountId) {
      destinationAccountId = null;
      questions.push('Source and destination accounts must be different.');
    }
    if (accountId) {
      fc.accountId ??= 0.95;
      explicit.add('accountId');
    } else questions.push('Which account did the money leave?');
    if (destinationAccountId) {
      fc.destinationAccountId ??= 0.95;
      if (fc.destinationAccountId >= 0.9) explicit.add('destinationAccountId');
    } else questions.push('Which account received the money?');
  } else if (intent === 'income' || intent === 'expense') {
    const distinct = [...new Set(ms.map((m) => m.accountId))];
    if (distinct.length === 1) {
      accountId = distinct[0]!;
      fc.accountId = 0.95;
      explicit.add('accountId');
    } else {
      questions.push(intent === 'income' ? 'Which account received this income?' : 'Which account paid for this?');
    }
  }

  // Merchant, category, income source.
  let merchant: string | null = merchantKey ? MERCHANTS[merchantKey]!.display : null;
  let categoryId: string | null = null;
  let incomeSourceId: string | null = null;

  if (intent === 'income' || intent === 'expense') {
    const normMerchant = merchant ? normalizeMerchant(merchant) : null;
    const matches = ctx.rules
      .filter((r) => r.transactionType === intent)
      .filter((r) => (r.matchKind === 'merchantExact' ? normMerchant === r.normalizedPattern || hasToken(tokens, r.normalizedPattern) : hasToken(tokens, r.normalizedPattern)))
      .sort((a, b) => b.priority - a.priority || (a.matchKind === b.matchKind ? 0 : a.matchKind === 'merchantExact' ? -1 : 1) || a.id.localeCompare(b.id));
    if (matches.length > 0) {
      const top = matches.filter((r) => r.priority === matches[0]!.priority && r.matchKind === matches[0]!.matchKind);
      const cats = new Set(top.map((r) => r.categoryId));
      if (cats.size === 1 && ctx.categories.some((c) => c.id === top[0]!.categoryId)) {
        const rule = top[0]!;
        categoryId = rule.categoryId;
        fc.categoryId = 0.95;
        ruleMatches++;
        if (!merchant && rule.matchKind === 'merchantExact') merchant = titleCase(rule.normalizedPattern);
        if (!accountId && rule.suggestedAccountId && ctx.accounts.some((a) => a.id === rule.suggestedAccountId)) {
          accountId = rule.suggestedAccountId;
          fc.accountId = 0.7;
        }
        if (intent === 'income' && rule.suggestedIncomeSourceId && ctx.sources.some((s) => s.id === rule.suggestedIncomeSourceId)) {
          incomeSourceId = rule.suggestedIncomeSourceId;
          fc.incomeSourceId = 0.9;
        }
      } else if (cats.size > 1) {
        questions.push('Your saved rules disagree about the category; please choose one.');
      }
    }
    if (!categoryId) {
      const names = merchantKey ? MERCHANTS[merchantKey]!.categories : keyword ? KEYWORDS[keyword]! : [];
      const hit = categoryByNames(names, intent, ctx.categories);
      if (hit) {
        categoryId = hit;
        fc.categoryId = 0.8;
        ruleMatches++;
      }
    }
  }

  if (intent === 'income') {
    const named = ctx.sources.filter((s) => significantTokens(s.name).some((t) => tokens.includes(t)));
    if (!incomeSourceId && named.length === 1) {
      incomeSourceId = named[0]!.id;
      fc.incomeSourceId = 0.95;
      explicit.add('incomeSourceId');
    } else if (!incomeSourceId) {
      const byType = tokens.includes('salary') ? ctx.sources.filter((s) => s.type === 'employer') : tokens.includes('freelance') ? ctx.sources.filter((s) => s.type === 'freelance') : [];
      if (byType.length === 1) {
        incomeSourceId = byType[0]!.id;
        fc.incomeSourceId = 0.7;
      }
    }
    if (!incomeSourceId) questions.push('Which income source did this come from?');
    if (!accountId && incomeSourceId) {
      const def = ctx.sources.find((s) => s.id === incomeSourceId)?.defaultAccountId;
      if (def && ctx.accounts.some((a) => a.id === def)) {
        accountId = def;
        fc.accountId = 0.7;
        const idx = questions.indexOf('Which account received this income?');
        if (idx >= 0) questions.splice(idx, 1);
      }
    }
    if (!categoryId) questions.push('Which income category fits?');
  }

  // Date.
  const date = extractDate(normalized, tokens, referenceNow, timeZone);
  if (date.ambiguous) questions.push('Which date? Use YYYY-MM-DD, "today" or "yesterday".');
  if (date.date) {
    fc.effectiveDate = date.explicit ? 0.95 : 0.8;
    if (date.explicit) explicit.add('effectiveDate');
  }

  // Description: the input minus amounts, account words and merchant token.
  const accountTokens = new Set(ctx.accounts.flatMap((a) => significantTokens(a.name)).concat(['cash']));
  const dropped = new Set([...amount.tokens, ...accountTokens, ...(merchantKey ? [merchantKey] : []), 'rs', 'lkr', 'from', 'to', 'into', 'today', 'yesterday']);
  const descWords = words(normalized).filter((w) => !dropped.has(w));
  const description = capitalize(descWords.join(' ')).slice(0, 500);

  return {
    intent,
    amountMinor: amount.minor,
    merchant,
    description,
    accountId,
    destinationAccountId,
    categoryId,
    incomeSourceId,
    effectiveDate: date.date,
    fieldConfidence: fc,
    questions: [...new Set(questions)].slice(0, 5),
    ruleMatches,
    explicit,
    amountAmbiguous: amount.ambiguous,
  };
}

/** Required fields are complete and unambiguous: the model call can be skipped. */
export function isSufficient(c: RuleCandidate): boolean {
  if (c.intent === 'unknown' || c.amountMinor === null || c.accountId === null || c.effectiveDate === null) return false;
  if (c.intent === 'transfer') return c.destinationAccountId !== null;
  if (c.intent === 'income') return c.categoryId !== null && c.incomeSourceId !== null;
  return c.categoryId !== null;
}

function capitalize(s: string): string {
  return s.length > 0 ? s[0]!.toUpperCase() + s.slice(1) : s;
}

function titleCase(s: string): string {
  return s.replace(/\b\p{L}/gu, (c) => c.toUpperCase());
}
