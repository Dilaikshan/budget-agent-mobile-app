import { z } from 'zod';

/** Shared value conventions from docs/02-TECHNICAL-SPECIFICATION.md. */

export const MAX_AMOUNT_MINOR = 1_000_000_000_000;

/** Opaque ID: UUID, SHA-256 hex or fixed singleton; no path separators or dots. */
export const IdSchema = z.string().regex(/^[A-Za-z0-9-]{1,64}$/, 'INVALID_ID');
export const UuidSchema = z.uuid();

/** RFC3339 UTC instant with exactly millisecond precision and Z. */
export const InstantSchema = z.iso.datetime({ offset: false, local: false, precision: 3 });
export const DateSchema = z.iso.date();
export const MonthSchema = z.string().regex(/^[0-9]{4}-(0[1-9]|1[0-2])$/, 'INVALID_MONTH');
export const CurrencySchema = z.string().regex(/^[A-Z]{3}$/, 'INVALID_CURRENCY');

export const AmountMinorSchema = z.number().int().min(1).max(MAX_AMOUNT_MINOR);
export const SignedOpeningMinorSchema = z.number().int().min(-MAX_AMOUNT_MINOR).max(MAX_AMOUNT_MINOR);

export function isValidTimeZone(tz: string): boolean {
  if (!/^[A-Za-z_]+(\/[A-Za-z0-9_+-]+){0,2}$/.test(tz) && tz !== 'UTC') return false;
  try {
    new Intl.DateTimeFormat('en-US', { timeZone: tz });
    return true;
  } catch {
    return false;
  }
}

export const TimeZoneSchema = z.string().max(64).refine(isValidTimeZone, 'INVALID_TIME_ZONE');

/** Unicode code-point length, the unit the specification limits are expressed in. */
export function codePointLength(s: string): number {
  return [...s].length;
}

/** NFC-normalized, trimmed text; financial input is never silently truncated. */
export function textSchema(maxCodePoints: number, minCodePoints = 0) {
  return z
    .string()
    .refine((s) => s === s.normalize('NFC'), 'NOT_NFC')
    .refine((s) => s === s.trim(), 'NOT_TRIMMED')
    .refine((s) => codePointLength(s) <= maxCodePoints, 'TOO_LONG')
    .refine((s) => codePointLength(s) >= minCodePoints, 'TOO_SHORT');
}

export const NameSchema = textSchema(80, 1);
export const MerchantSchema = textSchema(120, 1);
export const DescriptionSchema = textSchema(500);

/** Calendar date of an instant in an IANA zone, YYYY-MM-DD. */
export function localDateOf(instant: Date, timeZone: string): string {
  const parts = new Intl.DateTimeFormat('en-CA', {
    timeZone,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  }).formatToParts(instant);
  const get = (t: string) => parts.find((p) => p.type === t)?.value ?? '';
  return `${get('year')}-${get('month')}-${get('day')}`;
}

export function toInstantString(d: Date): string {
  return d.toISOString();
}
