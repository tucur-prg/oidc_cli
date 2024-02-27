import 'dart:convert';

import 'package:oidc_cli/src/extension.dart';

enum ApiMethod {
  GET,
  POST,
  PUT,
  DELETE,
}

enum ApiContentType {
  Form("application/x-www-form-urlencoded"),
  Json("application/json"),
  ;

  final String value;

  const ApiContentType(this.value);

  bool isJson() {
    return this == ApiContentType.Json;
  }
}

class Request {
  String uri = "";
  ApiMethod _method = ApiMethod.GET;
  Map<String, String> header = {};
  Map<String, dynamic> body = {};

  ApiContentType contentType = ApiContentType.Json;

  Request(this.uri, ApiMethod method) {
    _method = method;

    header['Content-Type'] = contentType.value;
  }

  String get method => _method.name.toUpperCase();

  String convertBody() {
    if (contentType.isJson()) {
      return json.encode(body);
    } else {
      return body.toQueryString();
    }
  }

  void setAuthorization(String accessToken, [String? dpop]) {
    if (dpop == null) {
      header['Authorization'] = 'Bearer $accessToken';
    } else {
      header['Authorization'] = 'DPoP $accessToken';
      header['DPoP'] = dpop;
    }
  }
}
