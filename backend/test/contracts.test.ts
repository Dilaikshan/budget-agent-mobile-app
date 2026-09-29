import { describe, it, expect } from 'vitest';
import {
  PushRequestSchema,
  ParseRequestSchema,
  OperationSchema,
} from '../src/contracts/schemas.js';

describe('API Contract Schemas', () => {
  it('validates a valid Operation', () => {
    const validOp = {
      opId: '123e4567-e89b-12d3-a456-426614174000',
      entityType: 'transaction',
      entityId: 'tx-1',
      action: 'create',
      baseRevision: 0,
      dependsOnOpId: null,
      payload: {
        type: 'expense',
        amountMinor: 150000,
        currency: 'LKR',
      },
      confirmation: {
        confirmedAt: '2026-09-28T23:00:00.000Z',
        payloadHash: 'a'.repeat(64),
        expectedLocalVersion: 1,
        predecessorOpId: null,
      },
    };

    const result = OperationSchema.safeParse(validOp);
    expect(result.success).toBe(true);
  });

  it('rejects an invalid PushRequest with unknown action or entityType', () => {
    const invalidOp = {
      opId: 'not-a-uuid',
      entityType: 'invalidType',
      entityId: 'tx-1',
      action: 'unsupportedAction',
      baseRevision: -1,
      dependsOnOpId: null,
      payload: null,
      confirmation: null,
    };

    const result = PushRequestSchema.safeParse({ operations: [invalidOp] });
    expect(result.success).toBe(false);
  });

  it('validates ParseRequest schema strictly', () => {
    const parseReq = {
      draftId: '123e4567-e89b-12d3-a456-426614174000',
      rawInput: 'Keells supermarket 4500 LKR from ComBank',
      referenceNow: '2026-09-28T23:00:00.000Z',
      timeZone: 'Asia/Colombo',
      currency: 'LKR',
    };

    const result = ParseRequestSchema.safeParse(parseReq);
    expect(result.success).toBe(true);
  });
});
