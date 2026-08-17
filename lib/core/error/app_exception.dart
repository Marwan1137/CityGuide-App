sealed class AppException implements Exception {
  const AppException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message';
}

final class ServerException extends AppException {
  const ServerException(super.message, {super.cause});
}

final class CacheException extends AppException {
  const CacheException(super.message, {super.cause});
}

final class UnauthorizedException extends AppException {
  const UnauthorizedException([
    super.message = 'Authentication is required to continue.',
  ]);
}

final class ValidationException extends AppException {
  const ValidationException(super.message, {this.errors = const {}});

  final Map<String, String> errors;
}
