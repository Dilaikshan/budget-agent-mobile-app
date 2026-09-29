import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'money.dart';

/// Canonical JSON shared with the backend (docs/02 "Versioning"; golden
/// vectors in docs/contracts/hash-vectors.json): recursively key-sorted objects,
/// arrays in order, no whitespace, standard JSON escapes, safe integers only.
class CanonicalJsonException implements Exception {
  CanonicalJsonException(this.message);
  final String message;
  @override
  String toString() => 'CanonicalJsonException: $message';
}

String canonicalJson(Object? value) {
  final out = StringBuffer();
  _write(value, out);
  return out.toString();
}

void _write(Object? value, StringBuffer out) {
  if (value == null) {
    out.write('null');
  } else if (value is bool) {
    out.write(value ? 'true' : 'false');
  } else if (value is String) {
    out.write(jsonEncode(value));
  } else if (value is int) {
    if (value > maxSafeInteger || value < -maxSafeInteger) {
      throw CanonicalJsonException('unsafe integer');
    }
    out.write(value.toString());
  } else if (value is double) {
    throw CanonicalJsonException('non-integer number');
  } else if (value is List) {
    out.write('[');
    for (var i = 0; i < value.length; i++) {
      if (i > 0) out.write(',');
      _write(value[i], out);
    }
    out.write(']');
  } else if (value is Map) {
    // Dart String.compareTo orders by UTF-16 code units, matching JavaScript.
    final keys = value.keys.cast<String>().toList()..sort();
    out.write('{');
    var first = true;
    for (final k in keys) {
      if (!first) out.write(',');
      first = false;
      out.write(jsonEncode(k));
      out.write(':');
      _write(value[k], out);
    }
    out.write('}');
  } else {
    throw CanonicalJsonException('unsupported ${value.runtimeType}');
  }
}

String sha256Hex(String text) => sha256.convert(utf8.encode(text)).toString();

String canonicalHash(Object? value) => sha256Hex(canonicalJson(value));

/// Opening transaction ID = SHA-256("opening:" + accountId) (docs/04).
String openingTransactionId(String accountId) =>
    sha256Hex('opening:$accountId');
