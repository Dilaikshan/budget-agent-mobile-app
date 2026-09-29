import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import '../config/app_config.dart';

class ApiClient {
  final Dio dio;
  final AppConfig config;

  ApiClient({required this.config, Dio? customDio})
      : dio = customDio ??
            Dio(
              BaseOptions(
                baseUrl: config.backendBaseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                headers: {
                  'Content-Type': 'application/json',
                  'Cache-Control': 'no-store',
                },
              ),
            ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 1. Attach Firebase ID token
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            final idToken = await user.getIdToken();
            if (idToken != null) {
              options.headers['Authorization'] = 'Bearer $idToken';
            }
          }

          // 2. Attach Firebase App Check token if available
          try {
            final appCheckToken = await FirebaseAppCheck.instance.getToken();
            if (appCheckToken != null) {
              options.headers['X-Firebase-AppCheck'] = appCheckToken;
            }
          } catch (_) {
            // App check in dev or unsupported platform
          }

          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            // Attempt token refresh once
            try {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                final newToken = await user.getIdToken(true);
                if (newToken != null) {
                  final opts = error.requestOptions;
                  opts.headers['Authorization'] = 'Bearer $newToken';
                  final cloneReq = await dio.fetch(opts);
                  return handler.resolve(cloneReq);
                }
              }
            } catch (_) {}
          }
          return handler.next(error);
        },
      ),
    );
  }

  // Push local outbox operations to backend
  Future<Response> pushOperations(List<Map<String, dynamic>> operations) {
    return dio.post(
      '/api/v1/sync/push',
      data: {'operations': operations},
    );
  }

  // Pull remote changes sequence
  Future<Response> getChanges({required int afterSeq, int limit = 100}) {
    return dio.get(
      '/api/v1/sync/changes',
      queryParameters: {
        'afterSeq': afterSeq,
        'limit': limit,
      },
    );
  }

  // Natural language transaction parse with AI
  Future<Response> parseTransaction({
    required String draftId,
    required String rawInput,
    required String referenceNow,
    required String timeZone,
    required String currency,
    required String idempotencyKey,
  }) {
    return dio.post(
      '/api/v1/agent/parse-transaction',
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
      data: {
        'draftId': draftId,
        'rawInput': rawInput,
        'referenceNow': referenceNow,
        'timeZone': timeZone,
        'currency': currency,
      },
    );
  }
}
