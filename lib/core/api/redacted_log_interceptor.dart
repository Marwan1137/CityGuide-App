import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

final class RedactedLogInterceptor extends Interceptor {
  RedactedLogInterceptor({required this.enabled});

  final bool enabled;
  static const _sensitiveNames = {
    'authorization',
    'apikey',
    'api_key',
    'key',
    'token',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (enabled) {
      final safeQuery = Map<String, dynamic>.from(options.queryParameters);
      for (final key in safeQuery.keys.toList()) {
        if (_isSensitive(key)) safeQuery[key] = '[REDACTED]';
      }
      debugPrint('${options.method} ${options.uri.path} query=$safeQuery');
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (enabled) {
      debugPrint(
        '${err.requestOptions.method} ${err.requestOptions.uri.path} '
        'failed status=${err.response?.statusCode}',
      );
    }
    handler.next(err);
  }

  bool _isSensitive(String value) {
    final normalized = value.toLowerCase();
    return _sensitiveNames.any(normalized.contains);
  }
}
