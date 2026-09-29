import crypto from 'node:crypto';
import { authenticateUser, type AuthContext } from '../auth/guards.js';
import { ConfigError } from '../config/env.js';
import { UuidSchema } from '../contracts/primitives.js';
import { getDeps, type Deps } from './deps.js';
import { ApiError, type ErrorCode } from './errors.js';

/** Minimal request/response surface satisfied by VercelRequest/VercelResponse. */
export interface HttpRequest {
  method?: string;
  headers: Record<string, string | string[] | undefined>;
  query?: Record<string, string | string[] | undefined>;
  readonly body?: unknown;
}

export interface HttpResponse {
  status(code: number): HttpResponse;
  setHeader(name: string, value: string): unknown;
  json(body: unknown): unknown;
}

export interface RouteContext {
  deps: Deps;
  auth: AuthContext | null;
  body: unknown;
  query: Record<string, string>;
  headers: HttpRequest['headers'];
  requestId: string;
}

export interface RouteSpec {
  name: string;
  method: 'GET' | 'POST';
  auth: 'user' | 'custom';
  maxBodyBytes?: number;
  /** 503 code used when configuration or storage is unavailable. */
  unavailableCode: ErrorCode;
  handle(ctx: RouteContext): Promise<{ status?: number; data: unknown }>;
}

const DEFAULT_MAX_BODY = 64 * 1024;

export function route(spec: RouteSpec) {
  return async function handler(req: HttpRequest, res: HttpResponse): Promise<void> {
    const started = Date.now();
    const requestId = crypto.randomUUID();
    const clientRequestId = header(req, 'x-client-request-id');
    const correlation = clientRequestId && UuidSchema.safeParse(clientRequestId).success ? clientRequestId : null;
    res.setHeader('Cache-Control', 'no-store');
    res.setHeader('Content-Type', 'application/json; charset=utf-8');
    let deps: Deps | null = null;

    try {
      if (req.method !== spec.method) {
        res.setHeader('Allow', spec.method);
        throw new ApiError('METHOD_NOT_ALLOWED');
      }
      const maxBody = spec.maxBodyBytes ?? DEFAULT_MAX_BODY;
      if (spec.method === 'POST') {
        const ct = header(req, 'content-type') ?? '';
        if (!/^application\/json(\s*;.*)?$/i.test(ct)) throw new ApiError('INVALID_JSON');
        const len = Number(header(req, 'content-length') ?? '0');
        if (!Number.isFinite(len) || len > maxBody) throw new ApiError('PAYLOAD_TOO_LARGE');
      }

      try {
        deps = getDeps();
      } catch (e) {
        if (e instanceof ConfigError) {
          console.error(JSON.stringify({ level: 'error', event: 'config_invalid', route: spec.name, keys: e.keys }));
          throw new ApiError(spec.unavailableCode);
        }
        throw e;
      }

      const auth = spec.auth === 'user' ? await authenticateUser(req.headers, deps.core, deps.verifier) : null;

      let body: unknown = null;
      if (spec.method === 'POST') {
        try {
          body = req.body;
        } catch {
          throw new ApiError('INVALID_JSON');
        }
        if (body === null || typeof body !== 'object' || Array.isArray(body)) throw new ApiError('INVALID_JSON');
        if (Buffer.byteLength(JSON.stringify(body), 'utf8') > maxBody) throw new ApiError('PAYLOAD_TOO_LARGE');
      }

      const query: Record<string, string> = {};
      for (const [k, v] of Object.entries(req.query ?? {})) {
        if (typeof v !== 'string') throw new ApiError('VALIDATION_ERROR', [{ path: k, code: 'REPEATED_PARAMETER' }]);
        query[k] = v;
      }

      const result = await spec.handle({ deps, auth, body, query, headers: req.headers, requestId });
      res.status(result.status ?? 200).json({ data: result.data, requestId });
      deps.log.info('request_completed', { requestId, clientRequestId: correlation, route: spec.name, status: result.status ?? 200, durationMs: Date.now() - started });
    } catch (e) {
      const err = e instanceof ApiError ? e : new ApiError(spec.unavailableCode);
      if (!(e instanceof ApiError)) {
        // Never log raw exception messages: they can contain provider/user content.
        console.error(JSON.stringify({ level: 'error', event: 'unexpected_error', route: spec.name, requestId, errorCode: errorName(e) }));
      } else if (err.status === 401 || err.status === 403) {
        deps?.log.info('authorization_denied', { requestId, route: spec.name, code: err.code });
      }
      if (err.retryAfterSeconds !== null) res.setHeader('Retry-After', String(err.retryAfterSeconds));
      res.status(err.status).json({
        error: { code: err.code, message: err.message, retryable: err.retryable, fields: err.fields },
        requestId,
      });
    }
  };
}

function header(req: HttpRequest, name: string): string | undefined {
  const v = req.headers[name];
  return Array.isArray(v) ? v[0] : v;
}

function errorName(e: unknown): string {
  if (e && typeof e === 'object' && 'code' in e && typeof (e as { code: unknown }).code === 'string') {
    return String((e as { code: string }).code).slice(0, 60);
  }
  return e instanceof Error ? e.name : 'unknown';
}
