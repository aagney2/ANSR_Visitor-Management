class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException(this.message, {this.code, this.originalError});

  String get userMessage => message;

  @override
  String toString() => message;
}

String userFriendlyError(dynamic e) {
  if (e is AppException) return e.userMessage;
  final msg = e.toString();
  if (msg.contains('SocketException') || msg.contains('Connection refused')) {
    return 'Unable to connect. Please check your internet connection.';
  }
  if (msg.contains('TimeoutException') || msg.contains('timed out')) {
    return 'Request timed out. Please try again.';
  }
  return 'Something went wrong. Please try again.';
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
