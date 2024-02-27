import 'dart:io';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:http/http.dart' as http;

import 'package:oidc_cli/oidc_cli.dart';

String clientId = "ae618b73-2ace-4f73-a60e-ae03ee39ec79";
String secret = "vgVA5KLmpKOZ9gomdJvYWobyF6FpJso1";

main(List<String> args) async {
  var server = await HttpServer.bind(InternetAddress.anyIPv4, 8082);
  print('Listeningf on localhost:8082');

  ApiClient cli = ApiClient();

  // OpenID Configuration
  String realms = "sample";
  String issuer = "http://localhost:8080/auth/realms/$realms";

  ConfigurationRequest configurationReq = ConfigurationRequest.issuer(issuer);

  http.Response configurationRes = await cli.execute(configurationReq);
  if (configurationRes.hasErrorResponse()) {
    print(configurationRes.statusCode);
    print(configurationRes.body);
    return;
  }

  var configration = jsonDecode(configurationRes.body);

  String redirectUri = "http://localhost:8082";
  String codeVerifier = createVerifier();

  CancelableOperation timeoutOpe = CancelableOperation.fromFuture(
      Future.delayed(const Duration(seconds: 60), () {
    print("request timeout.");
    server.close();
  }));

  Future.delayed(const Duration(seconds: 1), () async {
    // Authorization
    AuthorizationRequest authorizationReq =
        AuthorizationRequest(configration['authorization_endpoint']);
    authorizationReq.setBody(
        clientId: clientId,
        redirectUri: redirectUri,
        codeVerifier: codeVerifier);

    String endpoint =
        "${authorizationReq.uri}?${authorizationReq.convertBody()}";

    print("jump: $endpoint");
    runBrowser(endpoint);
  });

  await server.forEach((HttpRequest request) async {
    var parameter = request.requestedUri.queryParameters;

    print(parameter);

    // Token
    TokenRequest tokenReq = TokenRequest(configration['token_endpoint']);
    tokenReq.setBody(
        clientId: clientId,
        secret: secret,
        redirectUri: redirectUri,
        code: parameter['code'],
        codeVerifier: codeVerifier);

    http.Response tokenRes = await cli.execute(tokenReq);
    if (tokenRes.hasErrorResponse()) {
      print(tokenRes.statusCode);
    }

    var token = jsonDecode(tokenRes.body);
    if (token.containsKey("error")) {
      request.response
        ..statusCode = HttpStatus.badRequest
        ..headers.set("Content-Type", ContentType.html.mimeType)
        ..write(render("templates/error.html", {
          "error": token["error"],
          "description": token["error_description"],
        }))
        ..close();
    } else {
      // jwks-uri
      JwksRequest jwksReq = JwksRequest(configration['jwks_uri']);
      http.Response jwksRes = await cli.execute(jwksReq);
      var jwks = jsonDecode(jwksRes.body);

      var atPayload = await parseJWT(token['access_token'], jwks: jwks['keys']);
      var rtPayload =
          await parseJWT(token['refresh_token'], jwks: jwks['keys']);

      request.response
        ..statusCode = HttpStatus.ok
        ..headers.set("Content-Type", ContentType.html.mimeType)
        ..write(render("templates/callback.html", {
          "accessToken": token['access_token'],
          "refreshToken": token['refresh_token'],
          "scope": token['scope'],
          "atPayload": jsonEncode(atPayload),
          "rtPayload": jsonEncode(rtPayload),
        }))
        ..close();
    }

    server.close();
    timeoutOpe.cancel();
  });
}
