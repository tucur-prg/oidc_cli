import 'package:ecdsa/ecdsa.dart' as ecdsa;
import 'package:elliptic/elliptic.dart';

import 'mixin.dart';
import '../extension.dart';
import '../b64.dart';

///
/// Base
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

///
/// EC
///
class ECVerifyLogic with ECLogic implements VerifyLogic {
  String algorithm = 'ES256';

  final PublicKey key;

  ECVerifyLogic(this.key);

  factory ECVerifyLogic.fromJwk(Map<String, dynamic> jwk) {
    BigInt x =
        BigInt.parse(B64.urldecode<List<int>>(jwk['x']).toHex(), radix: 16);
    BigInt y =
        BigInt.parse(B64.urldecode<List<int>>(jwk['y']).toHex(), radix: 16);
    return ECVerifyLogic(PublicKey(getP256(), x, y));
  }

  bool verify(String body, List<int> signature) {
    ecdsa.Signature sign = ecdsa.Signature.fromCompact(signature);
    return ecdsa.verify(key, createMessageHash(body), sign);
  }
}

///
/// Hmac
///
class HmacVerifyLogic implements VerifyLogic {
  String algorithm = 'HS256';

  bool verify(String body, List<int> signature) {
    // TODO: ロジック後で考える
    return true;
  }
}
