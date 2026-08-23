sealed class Failure {
  const Failure(this.message, {this.code, this.cause});

  final String message;
  final String? code;
  final Object? cause;
}

final class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'Check your internet connection and try again.',
  ]);
}

final class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code, super.cause});
}

final class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.cause});
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'The request took too long. Please try again.']);
}

final class QuotaFailure extends Failure {
  const QuotaFailure(super.message, {super.code});
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
}

final class UnknownFailure extends Failure {
  const UnknownFailure({
    String message = 'Something went wrong. Please try again.',
    Object? cause,
  }) : super(message, cause: cause);
}
