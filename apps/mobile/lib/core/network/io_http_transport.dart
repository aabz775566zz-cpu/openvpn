import 'dart:convert';
import 'dart:io';

import 'http_transport.dart';

/// Default [HttpTransport] implementation backed by `dart:io`'s
/// [HttpClient]. This is the transport used by the app at runtime.
class IoHttpTransport implements HttpTransport {
  IoHttpTransport({HttpClient? client, this.timeout = const Duration(seconds: 15)})
      : _client = client ?? HttpClient();

  final HttpClient _client;
  final Duration timeout;

  @override
  Future<HttpTransportResponse> send(HttpTransportRequest request) async {
    late final HttpClientRequest ioRequest;
    switch (request.method) {
      case HttpMethod.get:
        ioRequest = await _client.getUrl(request.uri);
        break;
      case HttpMethod.post:
        ioRequest = await _client.postUrl(request.uri);
        break;
      case HttpMethod.put:
        ioRequest = await _client.putUrl(request.uri);
        break;
      case HttpMethod.patch:
        ioRequest = await _client.patchUrl(request.uri);
        break;
      case HttpMethod.delete:
        ioRequest = await _client.deleteUrl(request.uri);
        break;
    }

    request.headers.forEach(ioRequest.headers.set);

    if (request.body != null) {
      final bytes = utf8.encode(request.body!);
      ioRequest.headers.contentLength = bytes.length;
      ioRequest.add(bytes);
    }

    final ioResponse = await ioRequest.close().timeout(timeout);
    final responseBody = await ioResponse.transform(utf8.decoder).join();

    final headers = <String, String>{};
    ioResponse.headers.forEach((name, values) {
      headers[name] = values.join(',');
    });

    return HttpTransportResponse(
      statusCode: ioResponse.statusCode,
      body: responseBody,
      headers: headers,
    );
  }

  void close() => _client.close(force: true);
}
