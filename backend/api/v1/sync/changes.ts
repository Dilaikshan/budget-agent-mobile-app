import crypto from 'node:crypto';
import type { VercelRequest, VercelResponse } from '@vercel/node';
import { authenticateRequest } from '../../../src/auth/guards.js';
import { makeSuccessEnvelope, makeErrorEnvelope } from '../../../src/contracts/schemas.js';
import { ScopedFirestoreRepository } from '../../../src/firestore/repositories.js';

export default async function handler(req: VercelRequest, res: VercelResponse) {
  const requestId = crypto.randomUUID();

  if (req.method !== 'GET') {
    return res
      .status(405)
      .json(makeErrorEnvelope('METHOD_NOT_ALLOWED', 'GET required', false, requestId));
  }

  const auth = await authenticateRequest(req, res, requestId);
  if (!auth) return;

  const afterSeq = parseInt((req.query.afterSeq as string) || '0', 10);
  const limit = Math.min(parseInt((req.query.limit as string) || '100', 10), 100);

  if (isNaN(afterSeq) || afterSeq < 0) {
    return res
      .status(400)
      .json(makeErrorEnvelope('INVALID_CURSOR', 'afterSeq must be an integer >= 0', false, requestId));
  }

  const repo = new ScopedFirestoreRepository(auth);
  const changeData = await repo.getChanges(afterSeq, limit);

  return res.status(200).json(makeSuccessEnvelope(changeData, requestId));
}
