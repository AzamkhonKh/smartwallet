import 'dart:convert';

/// Thrown by [ApiService] for any non-2xx response.
/// Parses the backend's standard ErrorResponseDto body so that
/// callers get a clean, human-readable [message].
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  /// Try to extract the `message` field from a Spring Boot ErrorResponseDto JSON body.
  /// Falls back gracefully if the body is not JSON or missing the field.
  factory ApiException.fromResponse(int statusCode, String body) {
    String msg = _defaultMessage(statusCode);
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      if (decoded['message'] != null && (decoded['message'] as String).isNotEmpty) {
        msg = decoded['message'] as String;
      }
    } catch (_) {
      // body was not JSON – use the default message
    }
    return ApiException(statusCode, msg);
  }

  static String _defaultMessage(int code) {
    switch (code) {
      case 400:
        return 'Invalid request. Please check your input and try again.';
      case 401:
        return 'You are not signed in. Please log in and try again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 409:
        return 'This receipt has already been uploaded.';
      case 413:
        return 'The file is too large. Please use an image under 10 MB.';
      case 500:
        return 'Something went wrong on our end. Please try again later.';
      default:
        return 'An unexpected error occurred (HTTP $code).';
    }
  }

  @override
  String toString() => message;
}
