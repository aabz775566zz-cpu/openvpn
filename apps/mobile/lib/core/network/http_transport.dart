/// HTTP method used for an [HttpTransportRequest].
enum HttpMethod { get, post, put, patch, delete }

/// A transport-agnostic description of an outgoing HTTP request.
///
/// Abstracting the request/response shape away from any concrete HTTP
/// library keeps [ApiClient] easy to unit test (see [HttpTransport]) and
/// keeps the door open to swap the underlying transport (e.g. `dart:io`,
/// `package:http`, or a mocked implementation) without touching feature
/// code.
class HttpTransportRequest {
  const HttpTransportRequest({
    required this.method,
    required this.uri,
    this.headers = const {},
    this.body,
  });

  final HttpMethod method;
  final Uri uri;
  final Map<String, String> headers;
  final String? body;
}

/// A transport-agnostic description of an HTTP response.
class HttpTransportResponse {
  const HttpTransportResponse({
    required this.statusCode,
    required this.body,
    this.headers = const {},
  });

  final int statusCode;
  final String body;
  final Map<String, String> headers;
}

/// Abstraction over the underlying HTTP transport mechanism.
///
/// Production code uses [IoHttpTransport] (backed by `dart:io`'s
/// `HttpClient`); tests can supply a lightweight fake implementation.
abstract class HttpTransport {
  Future<HttpTransportResponse> send(HttpTransportRequest request);
}
