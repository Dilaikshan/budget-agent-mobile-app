class AppConfig {
  final String backendBaseUrl;
  final String defaultCurrency;
  final int currencyExponent;
  final String defaultTimeZone;

  const AppConfig({
    required this.backendBaseUrl,
    this.defaultCurrency = 'LKR',
    this.currencyExponent = 2,
    this.defaultTimeZone = 'Asia/Colombo',
  });

  // Environment variables passed via --dart-define
  factory AppConfig.fromEnvironment() {
    return const AppConfig(
      backendBaseUrl: String.fromEnvironment(
        'BACKEND_BASE_URL',
        defaultValue: 'https://your-vercel-deployment.vercel.app',
      ),
      defaultCurrency: String.fromEnvironment(
        'DEFAULT_CURRENCY',
        defaultValue: 'LKR',
      ),
      currencyExponent: int.fromEnvironment(
        'CURRENCY_EXPONENT',
        defaultValue: 2,
      ),
      defaultTimeZone: String.fromEnvironment(
        'DEFAULT_TIMEZONE',
        defaultValue: 'Asia/Colombo',
      ),
    );
  }
}
