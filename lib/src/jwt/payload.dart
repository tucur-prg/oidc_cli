import '../generate.dart';

///
/// Base
///
abstract class JWTBase {
  String type = 'unknwon';
  Map<String, dynamic> payload();
}

///
/// DPoP
///
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

///
/// PrivateKeyJWT
///
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
