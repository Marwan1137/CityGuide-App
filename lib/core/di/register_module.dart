import 'package:city_guide_app/core/api/redacted_log_interceptor.dart';
import 'package:city_guide_app/core/config/app_config.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  Connectivity get connectivity => Connectivity();
  @lazySingleton
  AppConfig get appConfig => AppConfig.fromEnvironment();

  @lazySingleton
  Dio dio(AppConfig config) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        responseType: ResponseType.json,
      ),
    );
    dio.interceptors.add(RedactedLogInterceptor(enabled: config.enableLogging));
    return dio;
  }
}
