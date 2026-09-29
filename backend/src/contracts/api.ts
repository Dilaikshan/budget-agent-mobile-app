import { z } from 'zod';
import { EntityTypeSchema } from './entities.js';
import {
  CurrencySchema,
  DateSchema,
  IdSchema,
  InstantSchema,
  TimeZoneSchema,
  UuidSchema,
  codePointLength,
} from './primitives.js';

/** HTTP request/response contracts, docs/05-API-CONTRACTS.md (contract version 1). */

export const ActionSchema = z.enum([
  'create',
  'update',
  'delete',
  'createAccountWithOpening',
  'dismissInsight',
  'rejectProposal',
]);
export type Action = z.infer<typeof ActionSchema>;

export const ConfirmationSchema = z.strictObject({
  confirmedAt: InstantSchema,
  payloadHash: z.string().regex(/^[0-9a-f]{64}$/, 'INVALID_HASH'),
  expectedLocalVersion: z.number().int().min(1).max(Number.MAX_SAFE_INTEGER),
  predecessorOpId: UuidSchema.nullable(),
});
export type Confirmation = z.infer<typeof ConfirmationSchema>;

/** Payload is validated per entity/action by the sync validator after envelope checks. */
export const OperationSchema = z.strictObject({
  opId: UuidSchema,
  entityType: EntityTypeSchema,
  entityId: IdSchema,
  action: ActionSchema,
  baseRevision: z.number().int().min(0).max(Number.MAX_SAFE_INTEGER).nullable(),
  dependsOnOpId: UuidSchema.nullable(),
  payload: z.record(z.string(), z.unknown()).nullable(),
  confirmation: ConfirmationSchema.nullable(),
});
export type Operation = z.infer<typeof OperationSchema>;

export const PushRequestSchema = z.strictObject({
  operations: z.array(OperationSchema).min(1).max(20),
});
export type PushRequest = z.infer<typeof PushRequestSchema>;

const nonNegIntString = z.string().regex(/^(0|[1-9][0-9]{0,15})$/).transform(Number).pipe(z.number().int().min(0).max(Number.MAX_SAFE_INTEGER));

export const ChangesQuerySchema = z.strictObject({
  afterSeq: nonNegIntString,
  watermark: nonNegIntString.optional(),
  limit: nonNegIntString.pipe(z.number().min(1).max(100)).optional(),
});

export const ParseRequestSchema = z.strictObject({
  draftId: UuidSchema,
  rawInput: z
    .string()
    .refine((s) => s.trim().length > 0, 'EMPTY')
    .refine((s) => codePointLength(s) <= 1000, 'TOO_LONG'),
  referenceNow: InstantSchema,
  timeZone: TimeZoneSchema,
  currency: CurrencySchema,
});
export type ParseRequest = z.infer<typeof ParseRequestSchema>;

export const ParseCandidateSchema = z.strictObject({
  intent: z.enum(['income', 'expense', 'transfer', 'unknown']),
  amountMinor: z.number().int().min(1).max(1_000_000_000_000).nullable(),
  currency: CurrencySchema,
  merchant: z.string().max(120).nullable(),
  description: z.string().max(500),
  accountId: IdSchema.nullable(),
  destinationAccountId: IdSchema.nullable(),
  categoryId: IdSchema.nullable(),
  incomeSourceId: IdSchema.nullable(),
  occurredAt: InstantSchema.nullable(),
  effectiveDate: DateSchema.nullable(),
  entryTimeZone: TimeZoneSchema,
});
export type ParseCandidate = z.infer<typeof ParseCandidateSchema>;

export type ProposalSource = 'rule' | 'history' | 'gemini' | 'openrouter' | 'manual';

export interface ParseResponse {
  proposalId: string | null;
  candidate: ParseCandidate;
  confidence: number;
  fieldConfidence: Record<string, number>;
  questions: string[];
  requiresConfirmation: true;
  source: ProposalSource;
  agentRunId: string;
  sourceWatermark: number;
  expiresAt: string | null;
}

export const ClassifyRequestSchema = z.strictObject({
  transactionId: IdSchema,
  baseRevision: z.number().int().min(1).max(Number.MAX_SAFE_INTEGER),
});
export type ClassifyRequest = z.infer<typeof ClassifyRequestSchema>;

export interface ClassifyResponse {
  proposalId: string;
  candidate: { transactionId: string; baseRevision: number; categoryId: string | null };
  confidence: number;
  questions: string[];
  requiresConfirmation: true;
  source: ProposalSource;
  agentRunId: string;
  sourceWatermark: number;
  expiresAt: string;
}

export const InsightsQuerySchema = z.strictObject({
  from: DateSchema,
  to: DateSchema,
  cursor: z.string().max(512).optional(),
  limit: nonNegIntString.pipe(z.number().min(1).max(50)).optional(),
});

export const IdempotencyKeySchema = UuidSchema;
