import 'package:city_guide_app/core/api/api_executor.dart';
import 'package:city_guide_app/core/api/api_result.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ApiManager {
  const ApiManager(this._dio, this._executor);

  final Dio _dio;
  final ApiExecutor _executor;

  Future<ApiResult<Map<String, dynamic>>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) => _executor.execute(() async {
    final response = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );
    return response.data ?? <String, dynamic>{};
  });

  Future<ApiResult<Map<String, dynamic>>> post(
    String path, {
    Object? data,
    CancelToken? cancelToken,
  }) => _executor.execute(() async {
    final response = await _dio.post<Map<String, dynamic>>(
      path,
      data: data,
      cancelToken: cancelToken,
    );
    return response.data ?? <String, dynamic>{};
  });
}
