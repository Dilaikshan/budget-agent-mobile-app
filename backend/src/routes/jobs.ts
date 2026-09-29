import { runDaily } from '../agents/daily.js';
import { authenticateCron } from '../auth/guards.js';
import { ConfigError, loadJobConfig } from '../config/env.js';
import { ApiError } from '../http/errors.js';
import { route } from '../http/route.js';

/** GET /api/jobs/daily-agent: CRON_SECRET bearer only; configured owner only. */
export const dailyAgentRoute = route({
  name: 'jobs.daily',
  method: 'GET',
  auth: 'custom',
  unavailableCode: 'JOB_UNAVAILABLE',
  async handle({ deps, headers, query, requestId }) {
    let secret: string;
    try {
      secret = loadJobConfig(deps.env).cronSecret;
    } catch (e) {
      if (e instanceof ConfigError) throw new ApiError('JOB_UNAVAILABLE');
      throw e;
    }
    authenticateCron(headers, secret);
    // No query parameters: no secret in URLs and no UID/date overrides.
    if (Object.keys(query).length > 0) throw new ApiError('VALIDATION_ERROR', [{ path: 'query', code: 'NOT_ALLOWED' }]);
    const result = await runDaily({ core: deps.core, ai: deps.ai, store: deps.store, models: deps.models, clock: deps.clock, log: deps.log, requestId });
    return { data: result };
  },
});
