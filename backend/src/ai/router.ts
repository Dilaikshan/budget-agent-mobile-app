import { generateText, Output } from 'ai';
import { google } from '@ai-sdk/google';
import { createOpenRouter } from '@openrouter/ai-sdk-provider';
import { z } from 'zod';

export interface AIProviderResult<T> {
  data: T;
  provider: 'gemini' | 'openrouter' | 'local_fallback';
  model: string;
  latencyMs: number;
}

const ParseCandidateSchema = z.object({
  intent: z.enum(['income', 'expense', 'transfer', 'unknown']),
  amountMinor: z.number().int().nullable(),
  currency: z.string().length(3),
  merchant: z.string().nullable(),
  description: z.string(),
  suggestedAccountName: z.string().nullable(),
  suggestedCategoryName: z.string().nullable(),
  suggestedIncomeSourceName: z.string().nullable(),
  confidence: z.number().min(0).max(1),
  reasoning: z.string().max(500),
});

export type ParseCandidate = z.infer<typeof ParseCandidateSchema>;

export async function parseTransactionWithAI(
  rawInput: string,
  referenceNow: string,
  timeZone: string,
  currency: string
): Promise<AIProviderResult<ParseCandidate>> {
  const startTime = Date.now();
  const prompt = `Parse this financial transaction input strictly adhering to personal budget domain rules:
Input: "${rawInput}"
Reference current time: ${referenceNow} (${timeZone})
Currency: ${currency}

Rules:
1. Intent: 'income' (money received from employer/client), 'expense' (spending), 'transfer' (moving between user's own accounts or ATM cash withdrawal).
2. amountMinor must be an integer minor unit (e.g. 500 -> 50000; 12.50 -> 1250).
3. Do not assume or guess ambiguous numbers; if missing set amountMinor: null.
4. Return only structured candidate with clear reasoning.`;

  // Attempt 1: Gemini Primary
  if (process.env.GEMINI_API_KEY) {
    try {
      const result = await generateText({
        model: google('gemini-2.5-flash'),
        output: Output.object({
          schema: ParseCandidateSchema,
        }),
        prompt,
        abortSignal: AbortSignal.timeout(8000), // 8s bounded timeout
      });

      if (result.output) {
        return {
          data: result.output,
          provider: 'gemini',
          model: 'gemini-2.5-flash',
          latencyMs: Date.now() - startTime,
        };
      }
    } catch (err: unknown) {
      console.warn('Gemini primary attempt failed, evaluating fallback:', (err as Error)?.message);
    }
  }

  // Attempt 2: OpenRouter Fallback
  if (process.env.OPENROUTER_API_KEY) {
    try {
      const openrouter = createOpenRouter({
        apiKey: process.env.OPENROUTER_API_KEY,
      });

      const fallbackModel = process.env.OPENROUTER_MODEL || 'meta-llama/llama-3.3-70b-instruct';
      const result = await generateText({
        model: openrouter(fallbackModel),
        output: Output.object({
          schema: ParseCandidateSchema,
        }),
        prompt,
        abortSignal: AbortSignal.timeout(10000), // 10s bounded timeout
      });

      if (result.output) {
        return {
          data: result.output,
          provider: 'openrouter',
          model: fallbackModel,
          latencyMs: Date.now() - startTime,
        };
      }
    } catch (err: unknown) {
      console.warn('OpenRouter fallback failed:', (err as Error)?.message);
    }
  }

  // Local Rule Fallback if no provider keys or both providers fail
  const isTransfer = /\b(transfer|transferred|moved|withdraw|withdrew|atm)\b/i.test(rawInput);
  const isIncome = !isTransfer && /\b(salary|received|income|freelance|bonus|credited)\b/i.test(rawInput);
  const intent = isTransfer ? 'transfer' : isIncome ? 'income' : 'expense';

  const amountMatch = rawInput.match(/(?:[0-9]{1,3}(?:,[0-9]{3})+|[0-9]+)(?:\.[0-9]{1,2})?/);
  let amountMinor: number | null = null;
  if (amountMatch) {
    const num = parseFloat(amountMatch[0].replace(/,/g, ''));
    if (!isNaN(num) && num > 0) {
      amountMinor = Math.round(num * 100);
    }
  }

  return {
    data: {
      intent,
      amountMinor,
      currency,
      merchant: null,
      description: rawInput.trim(),
      suggestedAccountName: null,
      suggestedCategoryName: null,
      suggestedIncomeSourceName: null,
      confidence: amountMinor ? 0.75 : 0.5,
      reasoning: 'Parsed using deterministic fallback parser. Review and confirm exact fields before ledger commitment.',
    },
    provider: 'local_fallback',
    model: 'heuristic_v1',
    latencyMs: Date.now() - startTime,
  };
}
