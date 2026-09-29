import 'package:unorm_dart/unorm_dart.dart' as unorm;

import 'result.dart';

/// Text limits (docs/02): names 80, merchant 120, description 500 code points;
/// NFC-normalized and trimmed before confirmation; never silently truncated.
const int nameLimit = 80;
const int merchantLimit = 120;
const int descriptionLimit = 500;
const int rawInputLimit = 1000;

String normalizeText(String s) => unorm.nfc(s).trim();

int codePointLength(String s) => s.runes.length;

/// Returns the normalized text or a field error.
Result<String> boundedText(
  String field,
  String input,
  int max, {
  bool required = false,
}) {
  final s = normalizeText(input);
  if (required && s.isEmpty) {
    return Err(AppError.validation({field: 'Required.'}));
  }
  if (codePointLength(s) > max) {
    return Err(AppError.validation({field: 'At most $max characters.'}));
  }
  return Ok(s);
}

/// Merchant normalization for rules: lowercase NFC with collapsed whitespace; digits kept.
String normalizeMerchant(String s) =>
    normalizeText(s).toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
