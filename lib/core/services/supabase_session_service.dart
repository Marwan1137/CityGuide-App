import 'package:city_guide_app/core/config/app_config.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@lazySingleton
class SupabaseSessionService {
  SupabaseSessionService(this._config);

  final AppConfig _config;
  bool _initialized = false;
  bool _hasSession = false;

  bool get isInitialized => _initialized;
  bool get hasSession => _hasSession;

  Future<String?> getAccessToken() async {
    await initialize();
    return _initialized
        ? Supabase.instance.client.auth.currentSession?.accessToken
        : null;
  }

  Future<void> initialize() async {
    if (_initialized || !_config.hasSupabaseConfiguration) return;

    await Supabase.initialize(
      url: _config.supabaseUrl,
      publishableKey: _config.supabasePublishableKey,
    );
    _initialized = true;

    final client = Supabase.instance.client;
    if (client.auth.currentSession != null) {
      _hasSession = true;
      return;
    }

    try {
      await client.auth.signInAnonymously();
      _hasSession = client.auth.currentSession != null;
    } on AuthException {
      // Authentication readiness is handled by remote features. A disabled
      // anonymous provider must not prevent offline features from launching.
      _hasSession = false;
    }
  }
}
