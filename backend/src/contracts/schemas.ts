import { z } from 'zod';

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

export const ActionSchema = z.enum([
  'create',
  'update',
  'delete',
  'createAccountWithOpening',
  'dismissInsight',
  'rejectProposal',
]);

export type Action = z.infer<typeof ActionSchema>;

export const ConfirmationSchema = z.object({
  confirmedAt: z.string().datetime(),
  payloadHash: z.string().length(64), // SHA256 hex
  expectedLocalVersion: z.number().int().min(1),
  predecessorOpId: z.string().uuid().nullable(),
});

export type Confirmation = z.infer<typeof ConfirmationSchema>;

export const OperationSchema = z.object({
  opId: z.string().uuid(),
  entityType: EntityTypeSchema,
  entityId: z.string().min(1).max(80),
  action: ActionSchema,
  baseRevision: z.number().int().min(0).nullable(),
  dependsOnOpId: z.string().uuid().nullable(),
  payload: z.record(z.unknown()).nullable(),
  confirmation: ConfirmationSchema.nullable(),
});

export type Operation = z.infer<typeof OperationSchema>;

export const PushRequestSchema = z.object({
  operations: z.array(OperationSchema).min(1).max(20),
});

export type PushRequest = z.infer<typeof PushRequestSchema>;

export const ParseRequestSchema = z.object({
  draftId: z.string().uuid(),
  rawInput: z.string().min(1).max(1000),
  referenceNow: z.string().datetime(),
  timeZone: z.string().min(1),
  currency: z.string().length(3),
});

export type ParseRequest = z.infer<typeof ParseRequestSchema>;

export const ClassifyRequestSchema = z.object({
  draftId: z.string().uuid(),
  text: z.string().min(1).max(1000),
  candidateCategoryIds: z.array(z.string().uuid()).max(30),
  referenceNow: z.string().datetime(),
});

export type ClassifyRequest = z.infer<typeof ClassifyRequestSchema>;

export const SafeErrorSchema = z.object({
  code: z.string().max(80),
  message: z.string().max(500),
  retryable: z.boolean(),
  fields: z
    .array(
      z.object({
        path: z.string(),
        code: z.string(),
      })
    )
    .optional(),
});

export function makeSuccessEnvelope<T>(data: T, requestId: string) {
  return {
    data,
    requestId,
  };
}

export function makeErrorEnvelope(
  code: string,
  message: string,
  retryable: boolean,
  requestId: string,
  fields?: Array<{ path: string; code: string }>
) {
  return {
    error: {
      code,
      message,
      retryable,
      fields: fields || [],
    },
    requestId,
  };
}
