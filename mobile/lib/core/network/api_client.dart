import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../domain/result.dart';

/// Authenticated HTTP client for /api/v1 (docs/05). Tokens come from injected
/// sources so tests never touch Firebase; bodies are never logged.
abstract interface class CredentialSource {
  Future<String?> idToken({bool forceRefresh = false});
  Future<String?> appCheckToken();
}

class ApiFailure implements Exception {
  ApiFailure(
    this.status,
    this.code, {
    this.retryable = false,
    this.retryAfter,
    this.fields = const [],
  });

  /// HTTP status; 0 for network failures.
  final int status;
  final String code;
  final bool retryable;
  final Duration? retryAfter;
  final List<Map<String, Object?>> fields;

  bool get isNetwork => status == 0;
  bool get isTransient =>
      status == 0 || status == 408 || status == 429 || status >= 500;
  bool get isAuth => status == 401 || status == 403;

  AppError toAppError() {
    final kind = switch (code) {
      'UNAUTHENTICATED' => ErrorKind.unauthenticated,
      'FORBIDDEN' ||
      'EMAIL_UNVERIFIED' ||
      'APP_CHECK_FAILED' => ErrorKind.forbidden,
      'AI_DISABLED' => ErrorKind.aiDisabled,
      'PRIVACY_NOT_ELIGIBLE' => ErrorKind.privacyNotEligible,
      'RATE_LIMITED' || 'AI_BUDGET_EXHAUSTED' => ErrorKind.rateLimited,
      'REVISION_CONFLICT' => ErrorKind.conflict,
      'STALE_PROPOSAL' => ErrorKind.staleProposal,
      'NOT_FOUND' || 'MISSING_REFERENCE' => ErrorKind.missingReference,
      'VALIDATION_ERROR' || 'AMBIGUOUS_INPUT' => ErrorKind.validation,
      _ => ErrorKind.unavailable,
    };
    return AppError(kind, _message(code), code: code, retryAfter: retryAfter);
  }

  static String _message(String code) => switch (code) {
    'UNAUTHENTICATED' => 'Sign in again to sync.',
    'EMAIL_UNVERIFIED' => 'Verify your email to sync.',
    'FORBIDDEN' => 'This account is not allowed on this server.',
    'APP_CHECK_FAILED' => 'App verification failed; sync is paused.',
    'AI_DISABLED' => 'AI assistance is off. Enter details manually.',
    'PRIVACY_NOT_ELIGIBLE' =>
      'AI needs your consent in Settings. Enter details manually.',
    'RATE_LIMITED' => 'Too many requests; try again shortly.',
    'AI_BUDGET_EXHAUSTED' => 'Daily AI limit reached. Enter details manually.',
    'AI_UNAVAILABLE' => 'AI unavailable — enter details.',
    'NETWORK' => 'You are offline. Everything is saved on this device.',
    _ => 'Service unavailable; your data is safe on this device.',
  };

  @override
  String toString() => 'ApiFailure($status, $code)';
}

abstract interface class SyncApi {
  Future<List<Map<String, Object?>>> push(
    List<Map<String, Object?>> operations,
  );
  Future<Map<String, Object?>> changes({
    required int afterSeq,
    int? watermark,
    int limit = 100,
  });
}

class ApiClient implements SyncApi {
  ApiClient({
    required Uri baseUrl,
    required this.credentials,
    Dio? dio,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid(),
       dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl.toString(),
               connectTimeout: const Duration(seconds: 10),
               sendTimeout: const Duration(seconds: 15),
               receiveTimeout: const Duration(seconds: 30),
               headers: {
                 'Content-Type': 'application/json',
                 'Cache-Control': 'no-store',
               },
               responseType: ResponseType.json,
             ),
           );

  final Dio dio;
  final CredentialSource credentials;
  final Uuid _uuid;

  Future<Map<String, Object?>> _send(
    String method,
    String path, {
    Object? body,
    Map<String, Object?>? query,
    Map<String, String>? headers,
    CancelToken? cancel,
  }) async {
    Future<Response<Object?>> attempt(bool forceRefresh) async {
      final token = await credentials.idToken(forceRefresh: forceRefresh);
      if (token == null) throw ApiFailure(401, 'UNAUTHENTICATED');
      final appCheck = await credentials.appCheckToken();
      return dio.request<Object?>(
        path,
        data: body,
        queryParameters: query,
        cancelToken: cancel,
        options: Options(
          method: method,
          headers: {
            'Authorization': 'Bearer $token',
            'X-Firebase-AppCheck': ?appCheck,
            'X-Client-Request-Id': _uuid.v4(),
            ...?headers,
          },
        ),
      );
    }

    try {
      Response<Object?> res;
      try {
        res = await attempt(false);
      } on DioException catch (e) {
        // Refresh the ID token once after an auth-expiry response; never loop.
        if (e.response?.statusCode != 401) rethrow;
        res = await attempt(true);
      }
      final data = (res.data as Map).cast<String, Object?>();
      return (data['data'] as Map).cast<String, Object?>();
    } on DioException catch (e) {
      throw _failure(e);
    }
  }

  ApiFailure _failure(DioException e) {
    final r = e.response;
    if (r == null) return ApiFailure(0, 'NETWORK', retryable: true);
    final retryAfterHeader = int.tryParse(r.headers.value('retry-after') ?? '');
    final body = r.data;
    if (body is Map && body['error'] is Map) {
      final err = (body['error'] as Map).cast<String, Object?>();
      return ApiFailure(
        r.statusCode ?? 0,
        err['code'] as String? ?? 'UNKNOWN',
        retryable: err['retryable'] == true,
        retryAfter: retryAfterHeader == null
            ? null
            : Duration(seconds: retryAfterHeader.clamp(0, 3600)),
        fields: ((err['fields'] as List?) ?? const [])
            .cast<Map>()
            .map((m) => m.cast<String, Object?>())
            .toList(),
      );
    }
    return ApiFailure(
      r.statusCode ?? 0,
      'UNKNOWN',
      retryable: (r.statusCode ?? 0) >= 500,
    );
  }

  @override
  Future<List<Map<String, Object?>>> push(
    List<Map<String, Object?>> operations,
  ) async {
    final data = await _send(
      'POST',
      '/api/v1/sync/push',
      body: {'operations': operations},
    );
    return (data['results'] as List)
        .cast<Map>()
        .map((m) => m.cast<String, Object?>())
        .toList();
  }

  @override
  Future<Map<String, Object?>> changes({
    required int afterSeq,
    int? watermark,
    int limit = 100,
  }) => _send(
    'GET',
    '/api/v1/sync/changes',
    query: {
      'afterSeq': '$afterSeq',
      if (watermark != null) 'watermark': '$watermark',
      'limit': '$limit',
    },
  );

  Future<Map<String, Object?>> parseTransaction(
    Map<String, Object?> request, {
    required String idempotencyKey,
    CancelToken? cancel,
  }) => _send(
    'POST',
    '/api/v1/agent/parse-transaction',
    body: request,
    headers: {'Idempotency-Key': idempotencyKey},
    cancel: cancel,
  );

  Future<Map<String, Object?>> classifyTransaction(
    String transactionId,
    int baseRevision, {
    required String idempotencyKey,
  }) => _send(
    'POST',
    '/api/v1/agent/classify-transaction',
    body: {'transactionId': transactionId, 'baseRevision': baseRevision},
    headers: {'Idempotency-Key': idempotencyKey},
  );
}
