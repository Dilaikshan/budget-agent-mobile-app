import crypto from 'node:crypto';
import type { CoreConfig } from '../config/env.js';
import { ApiError } from '../http/errors.js';
import type { VerifiedOwner } from '../store/scope.js';
import type { TokenVerifier } from './verifier.js';

export interface AuthContext extends VerifiedOwner {
  readonly source: 'idToken';
  readonly appId: string;
}

type Headers = Record<string, string | string[] | undefined>;

function header(headers: Headers, name: string): string | undefined {
  const v = headers[name];
  return Array.isArray(v) ? undefined : v;
}

/**
 * User API guard, in the order required by docs/07-SECURITY.md:
 * ID token → owner/email → App Check. UID comes only from the verified token.
 * There is no environment bypass; development uses App Check debug tokens.
 */
export async function authenticateUser(headers: Headers, core: CoreConfig, verifier: TokenVerifier): Promise<AuthContext> {
  const authz = header(headers, 'authorization');
  const match = authz?.match(/^Bearer ([A-Za-z0-9._-]{20,4096})$/);
  if (!match) throw new ApiError('UNAUTHENTICATED');

  let identity: { uid: string; emailVerified: boolean };
  try {
    identity = await verifier.verifyIdToken(match[1]!);
  } catch {
    throw new ApiError('UNAUTHENTICATED');
  }

  if (!safeEqual(identity.uid, core.ownerUid)) throw new ApiError('FORBIDDEN');
  if (!identity.emailVerified) throw new ApiError('EMAIL_UNVERIFIED');

  const appCheck = header(headers, 'x-firebase-appcheck');
  if (!appCheck || appCheck.length > 4096) throw new ApiError('APP_CHECK_FAILED');
  let appId: string;
  try {
    ({ appId } = await verifier.verifyAppCheck(appCheck));
  } catch {
    throw new ApiError('APP_CHECK_FAILED');
  }
  if (!core.allowedAppIds.includes(appId)) throw new ApiError('APP_CHECK_FAILED');

  return { uid: identity.uid, source: 'idToken', appId };
}

/** Cron guard: Authorization must equal "Bearer CRON_SECRET", compared in constant time. */
export function authenticateCron(headers: Headers, cronSecret: string): void {
  const authz = header(headers, 'authorization') ?? '';
  if (!safeEqual(authz, `Bearer ${cronSecret}`)) throw new ApiError('UNAUTHENTICATED');
}

export function safeEqual(a: string, b: string): boolean {
  const ha = crypto.createHash('sha256').update(a).digest();
  const hb = crypto.createHash('sha256').update(b).digest();
  return crypto.timingSafeEqual(ha, hb) && a.length === b.length;
}
