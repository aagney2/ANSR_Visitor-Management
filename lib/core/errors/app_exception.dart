class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'AppException($code): $message';
}

class NetworkException extends AppException {
  final int? statusCode;

  const NetworkException(
    super.message, {
    this.statusCode,
    super.code,
    super.originalError,
  });
}

class TimeoutException extends AppException {
  const TimeoutException([super.message = 'Request timed out']);
}

class DraftPollingException extends AppException {
  const DraftPollingException([super.message = 'Draft polling timed out']);
}

class ValidationException extends AppException {
  final Map<String, String> fieldErrors;

  const ValidationException(
    super.message, {
    this.fieldErrors = const {},
  });
}
