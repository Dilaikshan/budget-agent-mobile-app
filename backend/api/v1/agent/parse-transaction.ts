import crypto from 'node:crypto';
import type { VercelRequest, VercelResponse } from '@vercel/node';
import { authenticateRequest } from '../../../src/auth/guards.js';
import {
  ParseRequestSchema,
  makeSuccessEnvelope,
  makeErrorEnvelope,
} from '../../../src/contracts/schemas.js';
import { parseTransactionWithAI } from '../../../src/ai/router.js';

export default async function handler(req: VercelRequest, res: VercelResponse) {
  const requestId = crypto.randomUUID();

  if (req.method !== 'POST') {
    return res
      .status(405)
      .json(makeErrorEnvelope('METHOD_NOT_ALLOWED', 'POST required', false, requestId));
  }

  const auth = await authenticateRequest(req, res, requestId);
  if (!auth) return;

  const idempotencyKey = req.headers['idempotency-key'] as string;
  if (!idempotencyKey) {
    return res.status(400).json(
      makeErrorEnvelope(
        'VALIDATION_ERROR',
        'Idempotency-Key header is required for agent calls.',
        false,
        requestId
      )
    );
  }

  const parseResult = ParseRequestSchema.safeParse(req.body);
  if (!parseResult.success) {
    return res.status(400).json(
      makeErrorEnvelope(
        'VALIDATION_ERROR',
        'Invalid ParseRequest payload',
        false,
        requestId,
        parseResult.error.errors.map((e) => ({
          path: e.path.join('.'),
          code: e.code,
        }))
      )
    );
  }

  const { rawInput, referenceNow, timeZone, currency } = parseResult.data;

  const aiResult = await parseTransactionWithAI(
    rawInput,
    referenceNow,
    timeZone,
    currency
  );

  const proposalId = crypto
    .createHash('sha256')
    .update(`${auth.uid}:${idempotencyKey}:${rawInput}`)
    .digest('hex')
    .substring(0, 32);

  const responsePayload = {
    proposalId,
    candidate: aiResult.data,
    provider: aiResult.provider,
    model: aiResult.model,
    latencyMs: aiResult.latencyMs,
    requiresUserConfirmation: true, // Invariant from AGENTS.md
  };

  return res.status(200).json(makeSuccessEnvelope(responsePayload, requestId));
}
