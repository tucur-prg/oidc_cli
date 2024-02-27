import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:ecdsa/ecdsa.dart' as ecdsa;
import 'package:elliptic/elliptic.dart';
import 'package:http/http.dart' as http;

import 'extension.dart';
import 'generate.dart';
import 'utils.dart';
import 'api_client.dart';
import 'request.dart';

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
/// ====================
///
enum Kty {
  EC,
  ;

  String toJson() {
    return toString();
  }

  @override
  String toString() {
    return this.name;
  }
}

enum Crv {
  P256('P-256'),
  ;

  final String value;

  const Crv(this.value);

  String toJson() {
    return toString();
  }

  @override
  String toString() {
    return this.value;
  }
}

///
/// ==================
///
abstract class JWTBase {
  String type = 'unknwon';
  Map<String, dynamic> payload();
}

class DPoP implements JWTBase {
  String type = 'dpop+jwt';

  final String endpoint;
  final String method;
  DPoP(this.endpoint, this.method);

  Map<String, dynamic> payload() {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;

    return {
      'jti': createRandomString(16),
      'htm': method,
      'htu': endpoint,
      'iat': now,
    };
  }
}

class PrivateKeyJWT implements JWTBase {
  String type = 'JWT';

  final String endpoint;
  final String clientId;
  PrivateKeyJWT(this.endpoint, this.clientId);

  Map<String, dynamic> payload() {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;

    return {
      'jti': createRandomString(16),
      'sub': clientId,
      'iss': clientId,
      'aud': endpoint,
      'exp': now + 600,
      'iat': now
    };
  }
}

///
/// ===================
///
mixin ECLogic {
  List<int> createMessageHash(String message) {
    return sha256.convert(utf8.encode(message)).bytes;
  }
}

///
/// ===================
///
abstract class SignatureLogic {
  String algorithm = 'unknown';
  List<int> doCompact(String body);
  Map<String, dynamic> createJwk();
}

class ECSignatureLogic with ECLogic implements SignatureLogic {
  String algorithm = 'ES256';

  final PrivateKey key;

  ECSignatureLogic(this.key);

  List<int> doCompact(String body) {
    ecdsa.Signature sign = ecdsa.signature(key, createMessageHash(body));
    return sign.toCompact();
  }

  Map<String, dynamic> createJwk() {
    List<int> x = hexToBytes(key.publicKey.X.toRadixString(16));
    List<int> y = hexToBytes(key.publicKey.Y.toRadixString(16));

    return {
      'kty': Kty.EC,
      'crv': Crv.P256,
      'x': encode(x),
      'y': encode(y),
    };
  }
}

///
/// ==================
///
abstract class VerifyLogic {
  String algorithm = 'unknown';
  bool verify(String body, List<int> signature);

  static fromName(String name, Map<String, dynamic> jwk) {
    switch (name) {
      case 'ES256':
        return ECVerifyLogic.fromJwk(jwk);
      case 'HS256':
        return HmacVerifyLogic();
      default:
        throw Exception('Not supported algorithm "$name"');
    }
  }
}

class ECVerifyLogic with ECLogic implements VerifyLogic {
  String algorithm = 'ES256';

  final PublicKey key;

  ECVerifyLogic(this.key);

  factory ECVerifyLogic.fromJwk(Map<String, dynamic> jwk) {
    BigInt x = BigInt.parse(decode(jwk['x']).toHex(), radix: 16);
    BigInt y = BigInt.parse(decode(jwk['y']).toHex(), radix: 16);
    return ECVerifyLogic(PublicKey(getP256(), x, y));
  }

  bool verify(String body, List<int> signature) {
    ecdsa.Signature sign = ecdsa.Signature.fromCompact(signature);
    return ecdsa.verify(key, createMessageHash(body), sign);
  }
}

class HmacVerifyLogic implements VerifyLogic {
  String algorithm = 'HS256';

  bool verify(String body, List<int> signature) {
    // TODO: ロジック後で考える
    return true;
  }
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

  final b64Header = encode(jsonEncode(header).codeUnits);
  final b64Payload = encode(jsonEncode(obj.payload()).codeUnits);

  String message = "$b64Header.$b64Payload";

  final b64Sign = encode(logic.doCompact(message));

  return "$message.$b64Sign";
}

Map<String, dynamic> parseJWT(String jwt, {List<dynamic>? jwks}) {
  var [b64Header, b64Payload, b64Sign] = jwt.split('.');
  var header = jsonDecode(utf8.decode(decode(b64Header)));
  var payload = jsonDecode(utf8.decode(decode(b64Payload)));
  var signature = decode(b64Sign);

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
