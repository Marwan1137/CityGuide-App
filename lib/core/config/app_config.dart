enum AppEnvironment { development, staging, production }

final class AppConfig {
  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.supabaseUrl,
    required this.supabasePublishableKey,
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
      supabaseUrl: const String.fromEnvironment(
        'SUPABASE_URL',
        defaultValue: 'https://cwqewqnyeamsjjkuhdht.supabase.co',
      ),
      supabasePublishableKey: const String.fromEnvironment(
        'SUPABASE_PUBLISHABLE_KEY',
        defaultValue: 'sb_publishable_R5yYy2g7nlh2bcAkzvLHWg_pGCGabjy',
      ),
      enableLogging: environment != AppEnvironment.production,
    );
  }

  final String appName;
  final AppEnvironment environment;
  final String apiBaseUrl;
  final String supabaseUrl;
  final String supabasePublishableKey;
  final bool enableLogging;

  bool get hasApiBaseUrl => apiBaseUrl.trim().isNotEmpty;

  bool get hasSupabaseConfiguration =>
      supabaseUrl.trim().isNotEmpty && supabasePublishableKey.trim().isNotEmpty;
}
