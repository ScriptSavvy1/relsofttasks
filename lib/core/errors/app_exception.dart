/// Application-specific exceptions
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException($code): $message';
}

class AppAuthException extends AppException {
  const AppAuthException({required super.message, super.code, super.originalError});
}

class NetworkException extends AppException {
  const NetworkException({required super.message, super.code, super.originalError});
}

class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    required super.message,
    super.code,
    this.fieldErrors,
  });
}

class PermissionException extends AppException {
  const PermissionException({
    super.message = 'You do not have permission to perform this action.',
    super.code = 'PERMISSION_DENIED',
  });
}

class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'The requested resource was not found.',
    super.code = 'NOT_FOUND',
  });
}

/// Represents a failure from either the data or domain layer
class Failure {
  final String message;
  final String? code;
  final StackTrace? stackTrace;

  const Failure({
    required this.message,
    this.code,
    this.stackTrace,
  });

  @override
  String toString() => 'Failure($code): $message';

  factory Failure.fromException(Object error, [StackTrace? stackTrace]) {
    if (error is AppException) {
      return Failure(
        message: error.message,
        code: error.code,
        stackTrace: stackTrace,
      );
    }
    return Failure(
      message: error.toString(),
      stackTrace: stackTrace,
    );
  }
}
