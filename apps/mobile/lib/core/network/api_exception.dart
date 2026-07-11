/// Exception thrown by [ApiClient] when a backend request fails, either
/// because of a non-2xx HTTP status code or because the response body could
/// not be decoded as expected.
class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.body,
  });

  /// A human-readable description of the failure.
  final String message;

  /// The HTTP status code, if the failure originated from a response.
  final int? statusCode;

  /// The raw response body, if available, useful for debugging.
  final String? body;

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';
}
