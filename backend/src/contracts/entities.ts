import { z } from 'zod';
import {
  AmountMinorSchema,
  CurrencySchema,
  DateSchema,
  DescriptionSchema,
  IdSchema,
  InstantSchema,
  MerchantSchema,
  MonthSchema,
  NameSchema,
  SignedOpeningMinorSchema,
  TimeZoneSchema,
  localDateOf,
  textSchema,
} from './primitives.js';

/**
 * Client-writable entity payloads (docs/04-DATA-MODEL.md). Strict objects:
 * unknown keys and server metadata (id, revision, timestamps) are rejected.
 */

export const EntityTypeSchema = z.enum([
  'profile',
  'account',
  'incomeSource',
  'category',
  'transaction',
  'categorizationRule',
  'budget',
  'appSettings',
  'aiInsight',
  'aiProposal',
]);
export type EntityType = z.infer<typeof EntityTypeSchema>;

export const COLLECTION_BY_ENTITY: Record<EntityType, string> = {
  profile: 'profiles',
  account: 'accounts',
  incomeSource: 'income_sources',
  category: 'categories',
  transaction: 'transactions',
  categorizationRule: 'categorization_rules',
  budget: 'budgets',
  appSettings: 'app_settings',
  aiInsight: 'ai_insights',
  aiProposal: 'ai_proposals',
};

export const PROFILE_ID = 'profile';
export const SETTINGS_ID = 'settings';

export const ProfilePayloadSchema = z.strictObject({
  displayName: NameSchema,
  baseCurrency: CurrencySchema,
  currencyExponent: z.number().int().min(0).max(4),
  timeZone: TimeZoneSchema,
  onboardingComplete: z.boolean(),
});
export type ProfilePayload = z.infer<typeof ProfilePayloadSchema>;

export const AccountPayloadSchema = z.strictObject({
  name: NameSchema,
  type: z.enum(['bank', 'cash', 'wallet', 'savings']),
  currency: CurrencySchema,
  archived: z.boolean(),
  sortOrder: z.number().int().min(0).max(100_000),
});
export type AccountPayload = z.infer<typeof AccountPayloadSchema>;

export const IncomeSourcePayloadSchema = z.strictObject({
  name: NameSchema,
  type: z.enum(['employer', 'freelance', 'business', 'investment', 'other']),
  defaultAccountId: IdSchema.nullable(),
  archived: z.boolean(),
});
export type IncomeSourcePayload = z.infer<typeof IncomeSourcePayloadSchema>;

export const CategoryPayloadSchema = z.strictObject({
  name: NameSchema,
  type: z.enum(['income', 'expense']),
  parentId: IdSchema.nullable(),
  icon: textSchema(40, 1).nullable(),
  sortOrder: z.number().int().min(0).max(100_000),
  isSystem: z.boolean(),
  archived: z.boolean(),
});
export type CategoryPayload = z.infer<typeof CategoryPayloadSchema>;

const TransactionBase = {
  amountMinor: AmountMinorSchema,
  currency: CurrencySchema,
  accountId: IdSchema,
  merchant: MerchantSchema.nullable(),
  description: DescriptionSchema,
  occurredAt: InstantSchema,
  effectiveDate: DateSchema,
  entryTimeZone: TimeZoneSchema,
};

export const ExpensePayloadSchema = z.strictObject({
  ...TransactionBase,
  type: z.literal('expense'),
  destinationAccountId: z.null(),
  incomeSourceId: z.null(),
  categoryId: IdSchema.nullable(),
  origin: z.enum(['manual', 'aiInput']),
  categorizationSource: z.enum(['manual', 'rule', 'ai']).nullable(),
  proposalId: IdSchema.nullable(),
  openingDirection: z.null(),
});

export const IncomePayloadSchema = z.strictObject({
  ...TransactionBase,
  type: z.literal('income'),
  destinationAccountId: z.null(),
  incomeSourceId: IdSchema,
  categoryId: IdSchema,
  origin: z.enum(['manual', 'aiInput']),
  categorizationSource: z.enum(['manual', 'rule', 'ai']).nullable(),
  proposalId: IdSchema.nullable(),
  openingDirection: z.null(),
});

export const TransferPayloadSchema = z.strictObject({
  ...TransactionBase,
  type: z.literal('transfer'),
  destinationAccountId: IdSchema,
  incomeSourceId: z.null(),
  categoryId: z.null(),
  origin: z.enum(['manual', 'aiInput']),
  categorizationSource: z.null(),
  proposalId: IdSchema.nullable(),
  openingDirection: z.null(),
});

export const OpeningPayloadSchema = z.strictObject({
  ...TransactionBase,
  amountMinor: z.number().int().min(0).max(1_000_000_000_000),
  type: z.literal('opening'),
  destinationAccountId: z.null(),
  incomeSourceId: z.null(),
  categoryId: z.null(),
  merchant: z.null(),
  origin: z.literal('opening'),
  categorizationSource: z.null(),
  proposalId: z.null(),
  openingDirection: z.enum(['credit', 'debit']),
});

export const TransactionPayloadSchema = z
  .discriminatedUnion('type', [ExpensePayloadSchema, IncomePayloadSchema, TransferPayloadSchema, OpeningPayloadSchema])
  .superRefine((t, ctx) => {
    if (t.type === 'transfer' && t.destinationAccountId === t.accountId) {
      ctx.addIssue({ code: 'custom', path: ['destinationAccountId'], message: 'SAME_ACCOUNT' });
    }
    if (localDateOf(new Date(t.occurredAt), t.entryTimeZone) !== t.effectiveDate) {
      ctx.addIssue({ code: 'custom', path: ['effectiveDate'], message: 'DATE_TIMEZONE_MISMATCH' });
    }
  });
export type TransactionPayload = z.infer<typeof TransactionPayloadSchema>;

export const CategorizationRulePayloadSchema = z.strictObject({
  matchKind: z.enum(['merchantExact', 'keyword']),
  normalizedPattern: textSchema(120, 1).refine((s) => s === s.toLowerCase(), 'NOT_NORMALIZED'),
  transactionType: z.enum(['income', 'expense']),
  categoryId: IdSchema,
  suggestedAccountId: IdSchema.nullable(),
  suggestedIncomeSourceId: IdSchema.nullable(),
  priority: z.number().int().min(0).max(1000),
  enabled: z.boolean(),
  origin: z.enum(['user', 'acceptedSuggestion']),
  evidenceTransactionIds: z.array(IdSchema).max(5),
});
export type CategorizationRulePayload = z.infer<typeof CategorizationRulePayloadSchema>;

export const BudgetPayloadSchema = z.strictObject({
  month: MonthSchema,
  categoryId: IdSchema,
  limitMinor: AmountMinorSchema,
  currency: CurrencySchema,
});
export type BudgetPayload = z.infer<typeof BudgetPayloadSchema>;

export const AppSettingsPayloadSchema = z.strictObject({
  theme: z.enum(['system', 'light', 'dark']),
  aiEnabled: z.boolean(),
  dailyReviewEnabled: z.boolean(),
  learningEnabled: z.boolean(),
  fallbackEnabled: z.boolean(),
  privacyPolicyVersion: z.string().min(1).max(40).nullable(),
  providerConsentAt: InstantSchema.nullable(),
  defaultExpenseAccountId: IdSchema.nullable(),
});
export type AppSettingsPayload = z.infer<typeof AppSettingsPayloadSchema>;

export const DismissInsightPayloadSchema = z.strictObject({ status: z.literal('dismissed') });
export const RejectProposalPayloadSchema = z.strictObject({ status: z.literal('rejected') });

/** Payload schema for ordinary create/update by entity type (null = not client-writable). */
export const WRITABLE_PAYLOAD_SCHEMA: Record<EntityType, z.ZodType | null> = {
  profile: ProfilePayloadSchema,
  account: AccountPayloadSchema,
  incomeSource: IncomeSourcePayloadSchema,
  category: CategoryPayloadSchema,
  transaction: TransactionPayloadSchema,
  categorizationRule: CategorizationRulePayloadSchema,
  budget: BudgetPayloadSchema,
  appSettings: AppSettingsPayloadSchema,
  aiInsight: null,
  aiProposal: null,
};

export const CreateAccountWithOpeningPayloadSchema = z.strictObject({
  account: AccountPayloadSchema,
  opening: z.strictObject({
    signedOpeningMinor: SignedOpeningMinorSchema,
    occurredAt: InstantSchema,
    effectiveDate: DateSchema,
    entryTimeZone: TimeZoneSchema,
  }),
});
export type CreateAccountWithOpeningPayload = z.infer<typeof CreateAccountWithOpeningPayloadSchema>;

/** Server metadata present on every replicated record. */
export interface RecordMeta {
  id: string;
  schemaVersion: 1;
  revision: number;
  createdAt: string;
  serverUpdatedAt: string;
  deletedAt: string | null;
}

export type CanonicalRecord = RecordMeta & Record<string, unknown>;

export interface CanonicalMutation {
  entityType: string;
  id: string;
  revision: number;
  record: CanonicalRecord;
}

export interface Change {
  seq: number;
  ledgerChanged: boolean;
  mutations: CanonicalMutation[];
  committedAt: string;
}
