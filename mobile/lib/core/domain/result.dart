/// Explicit results (docs/02 "Results and failures"). Domain code never throws
/// for expected failures; callers switch on [Result].
sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>;

  T? get valueOrNull => switch (this) {
    Ok<T>(:final value) => value,
    Err<T>() => null,
  };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.error);
  final AppError error;
}

enum ErrorKind {
  // Domain
  validation,
  missingReference,
  archivedReference,
  conflict,
  overflow,
  staleProposal,
  // Infrastructure
  unauthenticated,
  forbidden,
  unavailable,
  rateLimited,
  storageFull,
  migrationFailed,
  incompatibleVersion,
  aiDisabled,
  privacyNotEligible,
}

/// A typed failure with field-level detail. Messages are user-safe summaries.
class AppError {
  const AppError(
    this.kind,
    this.message, {
    this.fields = const {},
    this.code,
    this.retryAfter,
  });

  final ErrorKind kind;
  final String message;

  /// Field name → short user-facing problem.
  final Map<String, String> fields;

  /// Server error code when the failure came from the API.
  final String? code;
  final Duration? retryAfter;

  factory AppError.validation(Map<String, String> fields) =>
      AppError(ErrorKind.validation, fields.values.first, fields: fields);

  @override
  String toString() => 'AppError($kind, $code, $message)';
}
