/// Public build configuration from `--dart-define-from-file=env/<env>.json`
/// (docs/12 "Configuration inventory"). No model keys, service accounts or cron
/// secrets ever belong here.
enum AppEnv { development, preview, production }

class AppConfig {
  const AppConfig({
    required this.env,
    required this.apiBaseUrl,
    required this.firebaseApiKey,
    required this.firebaseAppId,
    required this.firebaseMessagingSenderId,
    required this.firebaseProjectId,
    required this.googleServerClientId,
    required this.appCheckDebug,
  });

  final AppEnv env;
  final Uri apiBaseUrl;
  final String firebaseApiKey;
  final String firebaseAppId;
  final String firebaseMessagingSenderId;
  final String firebaseProjectId;
  final String googleServerClientId;

  /// Debug App Check provider: development only, never in release builds.
  final bool appCheckDebug;

  static const _env = String.fromEnvironment('APP_ENV');
  static const _api = String.fromEnvironment('API_BASE_URL');
  static const _apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const _appId = String.fromEnvironment('FIREBASE_APP_ID');
  static const _sender = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static const _project = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const _googleClient = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );
  static const _appCheckDebug = bool.fromEnvironment('APP_CHECK_DEBUG');
  static const _isRelease = bool.fromEnvironment('dart.vm.product');

  /// Validates build defines; returns the list of problems instead of throwing.
  static ({AppConfig? config, List<String> problems}) load() {
    final problems = <String>[];
    final env = AppEnv.values.where((e) => e.name == _env).firstOrNull;
    if (env == null) {
      problems.add('APP_ENV must be development, preview or production');
    }
    final api = Uri.tryParse(_api);
    if (api == null || !api.hasScheme || api.host.isEmpty) {
      problems.add('API_BASE_URL is missing or invalid');
    }
    if (api != null && env == AppEnv.production && api.scheme != 'https') {
      problems.add('API_BASE_URL must use HTTPS in production');
    }
    for (final (name, value) in [
      ('FIREBASE_API_KEY', _apiKey),
      ('FIREBASE_APP_ID', _appId),
      ('FIREBASE_MESSAGING_SENDER_ID', _sender),
      ('FIREBASE_PROJECT_ID', _project),
      ('GOOGLE_SERVER_CLIENT_ID', _googleClient),
    ]) {
      if (value.isEmpty) problems.add('$name is missing');
    }
    if (_appCheckDebug && (env == AppEnv.production || _isRelease)) {
      problems.add(
        'APP_CHECK_DEBUG is not allowed in production/release builds',
      );
    }
    if (problems.isNotEmpty) return (config: null, problems: problems);
    return (
      config: AppConfig(
        env: env!,
        apiBaseUrl: api!,
        firebaseApiKey: _apiKey,
        firebaseAppId: _appId,
        firebaseMessagingSenderId: _sender,
        firebaseProjectId: _project,
        googleServerClientId: _googleClient,
        appCheckDebug: _appCheckDebug,
      ),
      problems: const <String>[],
    );
  }
}
