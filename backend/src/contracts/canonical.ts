import crypto from 'node:crypto';

/**
 * Canonical JSON (docs/02-TECHNICAL-SPECIFICATION.md "Versioning"): recursively
 * key-sorted objects, arrays in order, UTF-8, no whitespace, standard JSON string
 * escapes, shortest safe-integer numbers. Negative zero, non-integers, unsafe
 * integers and non-JSON values are rejected so Dart and TypeScript agree.
 */
export class CanonicalJsonError extends Error {}

export function canonicalJson(value: unknown): string {
  if (value === null) return 'null';
  switch (typeof value) {
    case 'boolean':
      return value ? 'true' : 'false';
    case 'string':
      return JSON.stringify(value);
    case 'number':
      if (!Number.isSafeInteger(value) || Object.is(value, -0)) {
        throw new CanonicalJsonError('Only safe integers are canonical numbers');
      }
      return String(value);
    case 'object': {
      if (Array.isArray(value)) return `[${value.map(canonicalJson).join(',')}]`;
      const proto = Object.getPrototypeOf(value);
      if (proto !== Object.prototype && proto !== null) {
        throw new CanonicalJsonError('Only plain objects are canonical');
      }
      const entries = Object.keys(value as Record<string, unknown>)
        .filter((k) => (value as Record<string, unknown>)[k] !== undefined)
        .sort(compareCodeUnits)
        .map((k) => `${JSON.stringify(k)}:${canonicalJson((value as Record<string, unknown>)[k])}`);
      return `{${entries.join(',')}}`;
    }
    default:
      throw new CanonicalJsonError('Unsupported value in canonical JSON');
  }
}

/** Sort keys by UTF-16 code units, identical to Dart's String.compareTo. */
function compareCodeUnits(a: string, b: string): number {
  return a < b ? -1 : a > b ? 1 : 0;
}

export function sha256Hex(text: string): string {
  return crypto.createHash('sha256').update(text, 'utf8').digest('hex');
}

export function canonicalHash(value: unknown): string {
  return sha256Hex(canonicalJson(value));
}

/** Deterministic server output ID (docs/06 "Insight ID=hash(...)"). */
export function deterministicId(...parts: string[]): string {
  return sha256Hex(parts.join('\u001f'));
}

/** Opening transaction ID = SHA-256("opening:" + accountId) (docs/04). */
export function openingTransactionId(accountId: string): string {
  return sha256Hex(`opening:${accountId}`);
}
