enum AppEnvironment { development, staging, production }

final class AppConfig {
  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.enableLogging,
    this.appName = 'CityGuide',
  });

  factory AppConfig.fromEnvironment() {
    const environmentValue = String.fromEnvironment(
      'APP_ENV',
      defaultValue: 'development',
    );

    final environment = switch (environmentValue.toLowerCase()) {
      'production' || 'prod' => AppEnvironment.production,
      'staging' || 'stage' => AppEnvironment.staging,
      _ => AppEnvironment.development,
    };

    return AppConfig(
      environment: environment,
      apiBaseUrl: const String.fromEnvironment('API_BASE_URL'),
      enableLogging: environment != AppEnvironment.production,
    );
  }

  final String appName;
  final AppEnvironment environment;
  final String apiBaseUrl;
  final bool enableLogging;

  bool get hasApiBaseUrl => apiBaseUrl.trim().isNotEmpty;
}
