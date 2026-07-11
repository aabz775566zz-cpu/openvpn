import 'dart:convert';

import 'api_exception.dart';
import 'http_transport.dart';
import 'io_http_transport.dart';

/// Foundation API client used across the app for communicating with the
/// OpenWorld VPN backend REST API.
///
/// This client is intentionally minimal: it knows how to build requests,
/// attach an auth token, and decode JSON responses, raising an
/// [ApiException] for non-2xx responses. Feature-specific data sources
/// build on top of this foundation (e.g. `AuthRemoteDataSource`,
/// `ServerRemoteDataSource`).
class ApiClient {
  ApiClient({
    required this.baseUrl,
    HttpTransport? transport,
    this.defaultHeaders = const {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  }) : _transport = transport ?? IoHttpTransport();

  /// Base URL for the backend, e.g. `https://api.openworldvpn.com`.
  final String baseUrl;

  /// Headers attached to every request unless overridden.
  final Map<String, String> defaultHeaders;

  final HttpTransport _transport;

  /// ****** attached to authenticated requests, set after login.
  String? _authToken;

  void setAuthToken(String? token) => _authToken = token;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? queryParameters,
  }) {
    return _send(
      method: HttpMethod.get,
      path: path,
      queryParameters: queryParameters,
    );
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) {
    return _send(method: HttpMethod.post, path: path, body: body);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
  }) {
    return _send(method: HttpMethod.put, path: path, body: body);
  }

  Future<Map<String, dynamic>> delete(String path) {
    return _send(method: HttpMethod.delete, path: path);
  }

  Future<Map<String, dynamic>> _send({
    required HttpMethod method,
    required String path,
    Map<String, String>? queryParameters,
    Map<String, dynamic>? body,
  }) async {
    final uri = buildUri(baseUrl, path, queryParameters);
    final headers = <String, String>{...defaultHeaders};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer ' + _authToken!;
    }

    final response = await _transport.send(
      HttpTransportRequest(
        method: method,
        uri: uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      ),
    );

    return decodeResponse(response);
  }

  /// Builds the full request [Uri] from a base URL, a relative path, and
  /// optional query parameters. Exposed as a pure static method so it can be
  /// unit tested without performing any I/O.
  static Uri buildUri(
    String baseUrl,
    String path,
    Map<String, String>? queryParameters,
  ) {
    final normalizedBase =
        baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final fullUrl = '$normalizedBase$normalizedPath';
    final uri = Uri.parse(fullUrl);
    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }
    return uri.replace(queryParameters: {
      ...uri.queryParameters,
      ...queryParameters,
    });
  }

  /// Decodes a transport response into a JSON map, throwing an
  /// [ApiException] for non-2xx status codes or invalid payloads. Exposed
  /// as a pure static method so it can be unit tested without performing
  /// any I/O.
  static Map<String, dynamic> decodeResponse(HttpTransportResponse response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        message: 'Request failed with status ${response.statusCode}',
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    if (response.body.isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is List) {
      return <String, dynamic>{'data': decoded};
    }

    throw const ApiException(
      message: 'Unexpected response payload shape',
    );
  }
}
