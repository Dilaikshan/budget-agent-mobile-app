import type { z } from 'zod';
import type { Action, Operation } from '../contracts/api.js';
import { CanonicalJsonError, canonicalHash } from '../contracts/canonical.js';
import {
  CreateAccountWithOpeningPayloadSchema,
  DismissInsightPayloadSchema,
  PROFILE_ID,
  RejectProposalPayloadSchema,
  SETTINGS_ID,
  WRITABLE_PAYLOAD_SCHEMA,
  type EntityType,
} from '../contracts/entities.js';
import { UuidSchema } from '../contracts/primitives.js';
import type { FieldError } from '../http/errors.js';

/**
 * Batch-level static validation (docs/05 "Validate all schemas before processing
 * a batch so malformed input does not partly execute").
 */

const ALLOWED: Record<Action, ReadonlySet<EntityType>> = {
  create: new Set(['profile', 'incomeSource', 'category', 'transaction', 'categorizationRule', 'budget', 'appSettings']),
  update: new Set([
    'profile',
    'account',
    'incomeSource',
    'category',
    'transaction',
    'categorizationRule',
    'budget',
    'appSettings',
  ]),
  delete: new Set(['transaction', 'categorizationRule', 'budget']),
  createAccountWithOpening: new Set(['account']),
  dismissInsight: new Set(['aiInsight']),
  rejectProposal: new Set(['aiProposal']),
};

const SINGLETON_ID: Partial<Record<EntityType, string>> = { profile: PROFILE_ID, appSettings: SETTINGS_ID };

export interface ValidatedOperation {
  op: Operation;
  /** Parsed, schema-validated payload (null for delete). */
  payload: unknown;
}

/** confirmation.payloadHash input: exactly these six fields (docs/05). */
export function confirmationHashInput(op: Operation) {
  return {
    action: op.action,
    entityType: op.entityType,
    entityId: op.entityId,
    baseRevision: op.baseRevision,
    dependsOnOpId: op.dependsOnOpId,
    payload: op.payload,
  };
}

/** Receipt requestHash: the complete immutable Operation including confirmation. */
export function operationRequestHash(op: Operation): string {
  return canonicalHash(op);
}

function payloadSchemaFor(op: Operation): z.ZodType | 'null' | null {
  switch (op.action) {
    case 'delete':
      return 'null';
    case 'createAccountWithOpening':
      return CreateAccountWithOpeningPayloadSchema;
    case 'dismissInsight':
      return DismissInsightPayloadSchema;
    case 'rejectProposal':
      return RejectProposalPayloadSchema;
    default:
      return WRITABLE_PAYLOAD_SCHEMA[op.entityType];
  }
}

export function validateOperation(op: Operation, index: number): { ok: ValidatedOperation } | { errors: FieldError[] } {
  const at = (p: string) => `operations.${index}${p ? `.${p}` : ''}`;
  const errors: FieldError[] = [];

  if (!ALLOWED[op.action].has(op.entityType)) errors.push({ path: at('action'), code: 'ACTION_NOT_ALLOWED' });

  const singleton = SINGLETON_ID[op.entityType];
  if (singleton !== undefined && op.entityId !== singleton) {
    errors.push({ path: at('entityId'), code: 'SINGLETON_ID_REQUIRED' });
  }
  const isNew = op.action === 'create' || op.action === 'createAccountWithOpening';
  if (isNew && singleton === undefined && !UuidSchema.safeParse(op.entityId).success) {
    errors.push({ path: at('entityId'), code: 'UUID_REQUIRED' });
  }

  // Revision/dependency exclusivity.
  if (isNew) {
    if (op.baseRevision !== 0 || op.dependsOnOpId !== null) errors.push({ path: at('baseRevision'), code: 'NEW_ENTITY_REVISION' });
  } else if (op.dependsOnOpId !== null) {
    if (op.baseRevision !== null) errors.push({ path: at('baseRevision'), code: 'DEPENDENCY_REVISION_EXCLUSIVE' });
    if (op.dependsOnOpId === op.opId) errors.push({ path: at('dependsOnOpId'), code: 'SELF_DEPENDENCY' });
  } else if (op.baseRevision === null || op.baseRevision < 1) {
    errors.push({ path: at('baseRevision'), code: 'BASE_REVISION_REQUIRED' });
  }

  // Payload.
  let payload: unknown = null;
  const schema = payloadSchemaFor(op);
  if (schema === null) {
    errors.push({ path: at('payload'), code: 'ACTION_NOT_ALLOWED' });
  } else if (schema === 'null') {
    if (op.payload !== null) errors.push({ path: at('payload'), code: 'PAYLOAD_MUST_BE_NULL' });
  } else {
    const parsed = schema.safeParse(op.payload);
    if (!parsed.success) {
      for (const issue of parsed.error.issues.slice(0, 10)) {
        errors.push({
          path: at(['payload', ...issue.path.map(String)].join('.')),
          code: issue.code === 'custom' ? issue.message : issue.code === 'unrecognized_keys' ? 'UNKNOWN_FIELD' : issue.code.toUpperCase(),
        });
      }
    } else {
      payload = parsed.data;
      if (op.action === 'create' && op.entityType === 'transaction' && (payload as { type: string }).type === 'opening') {
        errors.push({ path: at('payload.type'), code: 'OPENING_REQUIRES_ACCOUNT_OPERATION' });
      }
    }
  }

  // Confirmation: required for every write except narrow dismiss/reject actions.
  const confirmationOptional = op.action === 'dismissInsight' || op.action === 'rejectProposal';
  if (op.confirmation === null) {
    if (!confirmationOptional) errors.push({ path: at('confirmation'), code: 'CONFIRMATION_REQUIRED' });
  } else {
    if (op.confirmation.predecessorOpId !== op.dependsOnOpId) {
      errors.push({ path: at('confirmation.predecessorOpId'), code: 'PREDECESSOR_MISMATCH' });
    }
    try {
      if (canonicalHash(confirmationHashInput(op)) !== op.confirmation.payloadHash) {
        errors.push({ path: at('confirmation.payloadHash'), code: 'PAYLOAD_HASH_MISMATCH' });
      }
    } catch (e) {
      if (!(e instanceof CanonicalJsonError)) throw e;
      errors.push({ path: at('payload'), code: 'NON_CANONICAL_VALUE' });
    }
  }

  // The receipt hash covers the whole operation; reject values it cannot encode (e.g. -0).
  try {
    operationRequestHash(op);
  } catch (e) {
    if (!(e instanceof CanonicalJsonError)) throw e;
    errors.push({ path: at(''), code: 'NON_CANONICAL_VALUE' });
  }

  return errors.length > 0 ? { errors } : { ok: { op, payload } };
}

export function validateBatch(ops: Operation[]): { ok: ValidatedOperation[] } | { errors: FieldError[] } {
  const errors: FieldError[] = [];
  const ok: ValidatedOperation[] = [];
  const seen = new Set<string>();
  ops.forEach((op, i) => {
    if (seen.has(op.opId)) errors.push({ path: `operations.${i}.opId`, code: 'DUPLICATE_OP_ID' });
    seen.add(op.opId);
    const r = validateOperation(op, i);
    if ('errors' in r) errors.push(...r.errors);
    else ok.push(r.ok);
  });
  return errors.length > 0 ? { errors: errors.slice(0, 50) } : { ok };
}
