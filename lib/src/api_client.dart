import 'package:http/http.dart' as http;

import 'request.dart';

class ApiClient {
  http.Client _client = http.Client();

  Future<http.Response> execute(Request req) async {
    final http.Request request = _build(req);

    return http.Response.fromStream(
        await _client.send(request).timeout(const Duration(seconds: 30)));
  }

  http.Request _build(Request req) {
    return http.Request(req.method, Uri.parse(req.uri))
      ..headers.addAll(req.header)
      ..body = req.convertBody();
  }
}

extension ExResponse on http.Response {
  bool hasErrorResponse() {
    return this.statusCode != 200 && this.statusCode != 201;
  }
}
