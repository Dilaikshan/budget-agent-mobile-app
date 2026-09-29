import { MAX_AMOUNT_MINOR } from '../contracts/primitives.js';

/**
 * Exact decimal-to-minor-unit parsing with string arithmetic (docs/02). Rejects
 * excess fractional digits, ambiguous separators and out-of-range values.
 */
export type DecimalParse = { ok: true; minor: number } | { ok: false; reason: 'INVALID' | 'EXCESS_PRECISION' | 'AMBIGUOUS_SEPARATOR' | 'OUT_OF_RANGE' };

export function parseDecimalToMinor(text: string, exponent: number): DecimalParse {
  const s = text.trim();
  // Thousands grouping must be exact 3-digit groups; a comma is never a decimal point.
  const m = s.match(/^([0-9]{1,3}(?:,[0-9]{3})+|[0-9]+)(?:\.([0-9]+))?$/);
  if (!m) {
    if (/^[0-9]+,[0-9]{1,2}$/.test(s) || /^[0-9]{1,3}(\.[0-9]{3})+(,[0-9]+)?$/.test(s)) {
      return { ok: false, reason: 'AMBIGUOUS_SEPARATOR' };
    }
    return { ok: false, reason: 'INVALID' };
  }
  const whole = m[1]!.replace(/,/g, '');
  const frac = m[2] ?? '';
  if (frac.length > exponent) return { ok: false, reason: 'EXCESS_PRECISION' };
  const digits = (whole + frac.padEnd(exponent, '0')).replace(/^0+(?=[0-9])/, '');
  if (digits.length > 16) return { ok: false, reason: 'OUT_OF_RANGE' };
  const minor = Number(digits);
  if (!Number.isSafeInteger(minor) || minor > MAX_AMOUNT_MINOR) return { ok: false, reason: 'OUT_OF_RANGE' };
  return { ok: true, minor };
}

/** Balances must stay within the safe-integer range; BigInt intermediates catch overflow. */
export function checkedSum(values: Iterable<number>): number {
  let total = 0n;
  for (const v of values) total += BigInt(v);
  if (total > BigInt(Number.MAX_SAFE_INTEGER) || total < BigInt(Number.MIN_SAFE_INTEGER)) {
    throw new RangeError('Balance overflow');
  }
  return Number(total);
}
