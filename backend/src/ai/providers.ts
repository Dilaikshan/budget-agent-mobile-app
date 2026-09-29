import { createGoogle } from '@ai-sdk/google';
import { APICallError } from '@ai-sdk/provider';
import { createOpenRouter } from '@openrouter/ai-sdk-provider';
import { generateText, NoObjectGeneratedError, Output, type LanguageModel } from 'ai';
import type { z } from 'zod';
import type { ProviderConfig } from '../config/env.js';

/**
 * ModelProvider abstraction (docs/06-AI-AGENT-DESIGN.md "Provider abstraction").
 * Adapters make exactly one bounded attempt: SDK retries are disabled.
 */

export type ProviderErrorKind = 'timeout' | 'rateLimited' | 'unavailable' | 'invalidOutput' | 'authError' | 'refused';

export class ProviderError extends Error {
  constructor(
    readonly kind: ProviderErrorKind,
    readonly usage: TokenUsage = { inputTokens: null, outputTokens: null },
  ) {
    super(kind);
  }
}

export interface TokenUsage {
  inputTokens: number | null;
  outputTokens: number | null;
}

export interface StructuredRequest<T> {
  system: string;
  prompt: string;
  schema: z.ZodType<T>;
  schemaName: string;
  maxOutputTokens: number;
  timeoutMs: number;
}

export interface StructuredResult<T> {
  output: T;
  usage: TokenUsage;
}

export interface ModelProvider {
  readonly provider: ProviderConfig['provider'];
  readonly model: string;
  generateStructured<T>(req: StructuredRequest<T>): Promise<StructuredResult<T>>;
}

export type ModelFactory = (cfg: ProviderConfig) => ModelProvider;

function usageOf(u: { inputTokens: number | undefined; outputTokens: number | undefined } | undefined): TokenUsage {
  return { inputTokens: u?.inputTokens ?? null, outputTokens: u?.outputTokens ?? null };
}

export function classifyProviderError(e: unknown): ProviderError {
  if (e instanceof ProviderError) return e;
  if (e instanceof Error && (e.name === 'AbortError' || e.name === 'TimeoutError')) return new ProviderError('timeout');
  if (NoObjectGeneratedError.isInstance(e)) {
    const usage = usageOf(e.usage);
    return new ProviderError(e.finishReason === 'content-filter' ? 'refused' : 'invalidOutput', usage);
  }
  if (APICallError.isInstance(e)) {
    const s = e.statusCode ?? 0;
    if (s === 429) return new ProviderError('rateLimited');
    if (s === 401 || s === 403) return new ProviderError('authError');
    if (s === 408) return new ProviderError('timeout');
    if (s === 400 && /safety|blocked|prohibited/i.test(e.message)) return new ProviderError('refused');
    if (s >= 500 || s === 0) return new ProviderError('unavailable');
    return new ProviderError('invalidOutput');
  }
  if (e instanceof Error && /abort|timeout/i.test(e.name + e.message)) return new ProviderError('timeout');
  return new ProviderError('unavailable');
}

class SdkProvider implements ModelProvider {
  constructor(
    readonly provider: 'gemini' | 'openrouter',
    readonly model: string,
    private readonly languageModel: LanguageModel,
  ) {}

  async generateStructured<T>(req: StructuredRequest<T>): Promise<StructuredResult<T>> {
    try {
      const result = await generateText({
        model: this.languageModel,
        system: req.system,
        prompt: req.prompt,
        output: Output.object({ schema: req.schema, name: req.schemaName }),
        maxRetries: 0,
        maxOutputTokens: req.maxOutputTokens,
        temperature: 0,
        abortSignal: AbortSignal.timeout(req.timeoutMs),
      });
      if (result.finishReason === 'content-filter') throw new ProviderError('refused', usageOf(result.usage));
      // Runtime validation after structured mode, even when the provider claims success.
      const parsed = req.schema.safeParse(result.output);
      if (!parsed.success) throw new ProviderError('invalidOutput', usageOf(result.usage));
      return { output: parsed.data, usage: usageOf(result.usage) };
    } catch (e) {
      throw classifyProviderError(e);
    }
  }
}

/** Deterministic adapter for CI/preview smoke tests; never enabled in production config. */
export class FakeProvider implements ModelProvider {
  readonly provider = 'fake' as const;
  constructor(
    readonly model: string,
    private readonly respond: (req: StructuredRequest<unknown>) => unknown = () => {
      throw new ProviderError('unavailable');
    },
  ) {}

  async generateStructured<T>(req: StructuredRequest<T>): Promise<StructuredResult<T>> {
    const raw = this.respond(req as StructuredRequest<unknown>);
    const parsed = req.schema.safeParse(raw);
    if (!parsed.success) throw new ProviderError('invalidOutput');
    return { output: parsed.data, usage: { inputTokens: 0, outputTokens: 0 } };
  }
}

export const defaultModelFactory: ModelFactory = (cfg) => {
  switch (cfg.provider) {
    case 'gemini': {
      const google = createGoogle({ apiKey: cfg.apiKey! });
      return new SdkProvider('gemini', cfg.model, google(cfg.model));
    }
    case 'openrouter': {
      const openrouter = createOpenRouter({ apiKey: cfg.apiKey! });
      // Restrict upstream routing to the reviewed allowlist; no uncontrolled fallback.
      const model = openrouter.chat(cfg.model, {
        provider: { only: cfg.allowedUpstreams, allow_fallbacks: false, data_collection: 'deny', require_parameters: true },
      });
      return new SdkProvider('openrouter', cfg.model, model);
    }
    case 'fake':
      return new FakeProvider(cfg.model);
  }
};
