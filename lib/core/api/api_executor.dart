import 'dart:async';

import 'package:city_guide_app/core/api/api_result.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ApiExecutor {
  const ApiExecutor();

  Future<ApiResult<T>> execute<T>(Future<T> Function() request) async {
    try {
      return ApiSuccess(await request());
    } on DioException catch (error) {
      return ApiFailure(_mapDioError(error));
    } on TimeoutException {
      return const ApiFailure(
        ApiError(type: ApiErrorType.timeout, message: 'The request timed out.'),
      );
    } on FormatException {
      return const ApiFailure(
        ApiError(
          type: ApiErrorType.parsing,
          message: 'The server returned an unexpected response.',
        ),
      );
    } catch (_) {
      return const ApiFailure(
        ApiError(
          type: ApiErrorType.unknown,
          message: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  ApiError _mapDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    if (error.type == DioExceptionType.cancel) {
      return const ApiError(
        type: ApiErrorType.cancelled,
        message: 'The request was cancelled.',
      );
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const ApiError(
        type: ApiErrorType.timeout,
        message: 'The request timed out. Please try again.',
      );
    }
    if (error.type == DioExceptionType.connectionError) {
      return const ApiError(
        type: ApiErrorType.network,
        message: 'Check your internet connection and try again.',
      );
    }
    if (statusCode == 401 || statusCode == 403) {
      return ApiError(
        type: ApiErrorType.unauthorized,
        message: 'Your session is not authorized for this request.',
        statusCode: statusCode,
      );
    }
    if (statusCode == 429) {
      return ApiError(
        type: ApiErrorType.quota,
        message: "You've hit today's usage limit. Please try again later.",
        statusCode: statusCode,
      );
    }
    if (statusCode != null) {
      return ApiError(
        type: ApiErrorType.server,
        message: 'The service is temporarily unavailable.',
        statusCode: statusCode,
      );
    }
    return const ApiError(
      type: ApiErrorType.unknown,
      message: 'Something went wrong. Please try again.',
    );
  }
}
