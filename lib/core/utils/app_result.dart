import 'package:city_guide_app/core/error/failure.dart';

sealed class AppResult<T> {
  const AppResult();

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    return switch (this) {
      Success<T>(:final data) => onSuccess(data),
      Error<T>(:final failure) => onFailure(failure),
    };
  }
}

final class Success<T> extends AppResult<T> {
  const Success(this.data);

  final T data;
}

final class Error<T> extends AppResult<T> {
  const Error(this.failure);

  final Failure failure;
}
