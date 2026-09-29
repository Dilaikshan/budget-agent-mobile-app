import type { VercelRequest, VercelResponse } from '@vercel/node';

/** Liveness only: no external calls, secrets, provider names or readiness details. */
export default function handler(_req: VercelRequest, res: VercelResponse) {
  res.setHeader('Cache-Control', 'no-store');
  res.status(200).json({ status: 'ok', version: '1' });
}
