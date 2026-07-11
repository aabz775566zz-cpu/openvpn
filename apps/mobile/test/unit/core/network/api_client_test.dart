import 'package:flutter_test/flutter_test.dart';
import 'package:openworld_vpn_mobile/core/network/api_client.dart';
import 'package:openworld_vpn_mobile/core/network/api_exception.dart';
import 'package:openworld_vpn_mobile/core/network/http_transport.dart';

/// In-memory fake transport for exercising [ApiClient] without any real
/// network I/O.
class _FakeHttpTransport implements HttpTransport {
  _FakeHttpTransport(this.response);

  final HttpTransportResponse response;
  HttpTransportRequest? lastRequest;

  @override
  Future<HttpTransportResponse> send(HttpTransportRequest request) async {
    lastRequest = request;
    return response;
  }
}

void main() {
  group('ApiClient.buildUri', () {
    test('joins base url and path correctly', () {
      final uri = ApiClient.buildUri('https://api.example.com', '/api/v1/health', null);
      expect(uri.toString(), 'https://api.example.com/api/v1/health');
    });

    test('handles trailing slash on base url', () {
      final uri = ApiClient.buildUri('https://api.example.com/', 'api/v1/health', null);
      expect(uri.toString(), 'https://api.example.com/api/v1/health');
    });

    test('appends query parameters', () {
      final uri = ApiClient.buildUri(
        'https://api.example.com',
        '/search',
        {'q': 'vpn'},
      );
      expect(uri.queryParameters['q'], 'vpn');
    });
  });

  group('ApiClient.decodeResponse', () {
    test('decodes a JSON object body', () {
      final result = ApiClient.decodeResponse(
        const HttpTransportResponse(statusCode: 200, body: '{"ok":true}'),
      );
      expect(result['ok'], true);
    });

    test('wraps a JSON array body under a "data" key', () {
      final result = ApiClient.decodeResponse(
        const HttpTransportResponse(statusCode: 200, body: '[1,2,3]'),
      );
      expect(result['data'], [1, 2, 3]);
    });

    test('returns an empty map for an empty body', () {
      final result = ApiClient.decodeResponse(
        const HttpTransportResponse(statusCode: 204, body: ''),
      );
      expect(result, isEmpty);
    });

    test('throws ApiException for a non-2xx status code', () {
      expect(
        () => ApiClient.decodeResponse(
          const HttpTransportResponse(statusCode: 500, body: 'boom'),
        ),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('ApiClient requests', () {
    test('get() sends a GET request and returns decoded body', () async {
      final transport = _FakeHttpTransport(
        const HttpTransportResponse(statusCode: 200, body: '{"status":"ok"}'),
      );
      final client = ApiClient(baseUrl: 'https://api.example.com', transport: transport);

      final result = await client.get('/health');

      expect(result['status'], 'ok');
      expect(transport.lastRequest?.method, HttpMethod.get);
      expect(transport.lastRequest?.uri.path, '/health');
    });

    test('post() encodes the body as JSON', () async {
      final transport = _FakeHttpTransport(
        const HttpTransportResponse(statusCode: 201, body: '{"id":"1"}'),
      );
      final client = ApiClient(baseUrl: 'https://api.example.com', transport: transport);

      await client.post('/users', body: {'name': 'Ada'});

      expect(transport.lastRequest?.method, HttpMethod.post);
      expect(transport.lastRequest?.body, contains('Ada'));
    });

    test('propagates ApiException for failing requests', () async {
      final transport = _FakeHttpTransport(
        const HttpTransportResponse(statusCode: 404, body: 'not found'),
      );
      final client = ApiClient(baseUrl: 'https://api.example.com', transport: transport);

      expect(client.get('/missing'), throwsA(isA<ApiException>()));
    });
  });
}
