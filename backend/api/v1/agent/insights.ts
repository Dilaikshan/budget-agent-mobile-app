import crypto from 'node:crypto';
import type { VercelRequest, VercelResponse } from '@vercel/node';
import { authenticateRequest } from '../../../src/auth/guards.js';
import { makeSuccessEnvelope, makeErrorEnvelope } from '../../../src/contracts/schemas.js';
import { getFirebaseAdmin } from '../../../src/auth/guards.js';

export default async function handler(req: VercelRequest, res: VercelResponse) {
  const requestId = crypto.randomUUID();

  if (req.method !== 'GET') {
    return res
      .status(405)
      .json(makeErrorEnvelope('METHOD_NOT_ALLOWED', 'GET required', false, requestId));
  }

  const auth = await authenticateRequest(req, res, requestId);
  if (!auth) return;

  const db = getFirebaseAdmin().firestore();
  const snap = await db
    .collection('users')
    .doc(auth.uid)
    .collection('ai_insights')
    .where('status', '==', 'active')
    .limit(20)
    .get();

  const insights = snap.docs.map((d) => d.data());

  return res.status(200).json(makeSuccessEnvelope({ insights }, requestId));
}
