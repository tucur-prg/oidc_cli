import 'dart:convert';

import 'package:elliptic/elliptic.dart';
import 'package:http/http.dart' as http;

import 'utils.dart';
import 'api_client.dart';
import 'request.dart';
import 'b64.dart';
import 'jwt/payload.dart';
import 'jwt/signature.dart';
import 'jwt/verify.dart';

export 'jwt/payload.dart';
export 'jwt/signature.dart';
export 'jwt/verify.dart';

main() async {
  var [d] = privateKey(getKey('files/ES256_private.pem'));
  PrivateKey priv = PrivateKey.fromBytes(getP256(), d);

  ECSignatureLogic logic = ECSignatureLogic(priv);

  var dpopJwt =
      createJWT(DPoP("http://localhost/api/hoge", "POST"), logic, isJwk: true);
  print(dpopJwt);
  print(await parseJWT(dpopJwt));

  print("=====");

  print(createJWT(PrivateKeyJWT("http://localhost/", "A000001"), logic));

  print("=====");

  ApiClient cli = ApiClient();

  // openid-configuration
  String realms = "sample";
  String issuer = "http://localhost:8080/auth/realms/$realms";
  ConfigurationRequest req = ConfigurationRequest.issuer(issuer);
  http.Response res = await cli.execute(req);
  var json = jsonDecode(res.body);

  // jwks-uri
  JwksRequest req2 = JwksRequest(json['jwks_uri']);
  http.Response res2 = await cli.execute(req2);
  var json2 = jsonDecode(res2.body);

  List<dynamic> keys = json2['keys'];

  String keycloakJwt =
      'eyJhbGciOiJFUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJ4NEZCUVZWekdCTVZnSEtlc0hwRkVuM05GcENZeW1fa1VJTTc2WkxIRUpzIn0.eyJleHAiOjE3MDg0MTU4MDMsImlhdCI6MTcwODQxNTUwMywiYXV0aF90aW1lIjoxNzA4NDExMzc2LCJqdGkiOiJhNWU4NTYzMi1hNjBiLTQ4NmItYTEyZC00ZWE0YTVlZTU5NGEiLCJpc3MiOiJodHRwOi8vbG9jYWxob3N0OjgwODAvYXV0aC9yZWFsbXMvc2FtcGxlIiwiYXVkIjoiYWNjb3VudCIsInN1YiI6ImRkZGVhMzk3LWYzMjktNGYzNS1iZDE2LTczM2I0NTMzNzlmNSIsInR5cCI6IkJlYXJlciIsImF6cCI6ImFlNjE4YjczLTJhY2UtNGY3My1hNjBlLWFlMDNlZTM5ZWM3OSIsInNlc3Npb25fc3RhdGUiOiI3MjE3MzhhZC00MDIxLTRjYWEtOGEyOS1kYjk0OTgyYTVlOWQiLCJhY3IiOiIwIiwiYWxsb3dlZC1vcmlnaW5zIjpbImh0dHA6Ly9sb2NhbGhvc3Q6ODA4MiJdLCJyZWFsbV9hY2Nlc3MiOnsicm9sZXMiOlsiZGVmYXVsdC1yb2xlcy1zYW1wbGUiLCJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsiYWNjb3VudCI6eyJyb2xlcyI6WyJtYW5hZ2UtYWNjb3VudCIsIm1hbmFnZS1hY2NvdW50LWxpbmtzIiwidmlldy1wcm9maWxlIl19fSwic2NvcGUiOiJlbWFpbCBwcm9maWxlIiwic2lkIjoiNzIxNzM4YWQtNDAyMS00Y2FhLThhMjktZGI5NDk4MmE1ZTlkIiwiZW1haWxfdmVyaWZpZWQiOmZhbHNlLCJuYW1lIjoidGVzdCB0YXJvdSIsInByZWZlcnJlZF91c2VybmFtZSI6InRlc3RlciIsImdpdmVuX25hbWUiOiJ0ZXN0IiwiZmFtaWx5X25hbWUiOiJ0YXJvdSIsImVtYWlsIjoidGVzdGVyQGV4YW1wbGUuY29tIn0.IzNKGBkfVzBGphMu2A-AY9RaSeiXbCQX7YiMQwGCO33o7jYfUlqP0M4mwTnxYYDQjuvmp9NlM2LN_hC4u-Yxjg';
  print(await parseJWT(keycloakJwt, jwks: keys));
}

///
/// ================
///
String createJWT(JWTBase obj, SignatureLogic logic, {bool isJwk = false}) {
  Map<String, dynamic> header = {
    'typ': obj.type,
    'alg': logic.algorithm,
    if (isJwk) 'jwk': logic.createJwk(),
  };

  final b64Header = B64.urlencode(jsonEncode(header));
  final b64Payload = B64.urlencode(jsonEncode(obj.payload()));

  String message = "$b64Header.$b64Payload";

  final b64Sign = B64.urlencode(logic.doCompact(message));

  return "$message.$b64Sign";
}

Map<String, dynamic> parseJWT(String jwt, {List<dynamic>? jwks}) {
  var [b64Header, b64Payload, b64Sign] = jwt.split('.');
  var header = jsonDecode(B64.urldecode<String>(b64Header));
  var payload = jsonDecode(B64.urldecode<String>(b64Payload));
  var signature = B64.urldecode(b64Sign);

  Map<String, dynamic> jwk;
  if (header.containsKey('kid')) {
    jwk = jwks?.firstWhere((k) => k['kid'] == header['kid'],
        orElse: () => <String, dynamic>{});
  } else if (header.containsKey('jwk')) {
    jwk = header['jwk'];
  } else {
    throw Exception('PublicKey is empty');
  }

  VerifyLogic logic = VerifyLogic.fromName(header['alg'], jwk);

  if (!logic.verify("$b64Header.$b64Payload", signature)) {
    throw Exception('jwt signature verification faild');
  }

  return payload;
}
