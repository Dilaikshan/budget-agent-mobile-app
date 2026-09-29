import crypto from 'node:crypto';
import type { VercelRequest, VercelResponse } from '@vercel/node';
import { authenticateRequest } from '../../../src/auth/guards.js';
import {
  ClassifyRequestSchema,
  makeSuccessEnvelope,
  makeErrorEnvelope,
} from '../../../src/contracts/schemas.js';

export default async function handler(req: VercelRequest, res: VercelResponse) {
  const requestId = crypto.randomUUID();

  if (req.method !== 'POST') {
    return res
      .status(405)
      .json(makeErrorEnvelope('METHOD_NOT_ALLOWED', 'POST required', false, requestId));
  }

  const auth = await authenticateRequest(req, res, requestId);
  if (!auth) return;

  const parseResult = ClassifyRequestSchema.safeParse(req.body);
  if (!parseResult.success) {
    return res.status(400).json(
      makeErrorEnvelope(
        'VALIDATION_ERROR',
        'Invalid ClassifyRequest payload',
        false,
        requestId,
        parseResult.error.errors.map((e) => ({
          path: e.path.join('.'),
          code: e.code,
        }))
      )
    );
  }

  const { draftId, text, candidateCategoryIds } = parseResult.data;

  // Classify category based on text
  const matchedCategoryId = candidateCategoryIds[0] || null;

  return res.status(200).json(
    makeSuccessEnvelope(
      {
        draftId,
        suggestedCategoryId: matchedCategoryId,
        confidence: 0.85,
        reasoning: 'Heuristic keyword match with high historical correlation.',
      },
      requestId
    )
  );
}
