import crypto from 'node:crypto';
import type { VercelRequest, VercelResponse } from '@vercel/node';
import { authenticateRequest } from '../../../src/auth/guards.js';
import {
  PushRequestSchema,
  makeSuccessEnvelope,
  makeErrorEnvelope,
} from '../../../src/contracts/schemas.js';
import { ScopedFirestoreRepository } from '../../../src/firestore/repositories.js';

export default async function handler(req: VercelRequest, res: VercelResponse) {
  const requestId = crypto.randomUUID();

  if (req.method !== 'POST') {
    return res
      .status(405)
      .json(makeErrorEnvelope('METHOD_NOT_ALLOWED', 'POST required', false, requestId));
  }

  // 1. Authenticate user
  const auth = await authenticateRequest(req, res, requestId);
  if (!auth) return;

  // 2. Validate request body
  const parseResult = PushRequestSchema.safeParse(req.body);
  if (!parseResult.success) {
    return res.status(400).json(
      makeErrorEnvelope(
        'VALIDATION_ERROR',
        'Malformed sync push payload',
        false,
        requestId,
        parseResult.error.errors.map((e) => ({
          path: e.path.join('.'),
          code: e.code,
        }))
      )
    );
  }

  const { operations } = parseResult.data;
  const repo = new ScopedFirestoreRepository(auth);
  const results = [];

  // Process operations sequentially
  for (const op of operations) {
    // Compute requestHash of Operation (excluding transport headers)
    const requestHash = crypto
      .createHash('sha256')
      .update(JSON.stringify(op))
      .digest('hex');

    const result = await repo.executeOperation(op, requestHash);
    results.push({
      opId: op.opId,
      ...result,
    });
  }

  return res.status(200).json(makeSuccessEnvelope({ results }, requestId));
}
