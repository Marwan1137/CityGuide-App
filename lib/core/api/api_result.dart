import 'package:equatable/equatable.dart';

sealed class ApiResult<T> extends Equatable {
  const ApiResult();

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(ApiError error) onFailure,
  }) => switch (this) {
    ApiSuccess<T>(:final data) => onSuccess(data),
    ApiFailure<T>(:final error) => onFailure(error),
  };
}

final class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data);

  final T data;

  @override
  List<Object?> get props => [data];
}

final class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure(this.error);

  final ApiError error;

  @override
  List<Object?> get props => [error];
}

enum ApiErrorType {
  cancelled,
  network,
  timeout,
  unauthorized,
  server,
  quota,
  parsing,
  unknown,
}

final class ApiError extends Equatable {
  const ApiError({required this.type, required this.message, this.statusCode});

  final ApiErrorType type;
  final String message;
  final int? statusCode;

  @override
  List<Object?> get props => [type, message, statusCode];
}
