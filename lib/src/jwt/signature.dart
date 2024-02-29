import 'package:ecdsa/ecdsa.dart' as ecdsa;
import 'package:elliptic/elliptic.dart';

import 'mixin.dart';
import 'type.dart';
import '../b64.dart';
import '../utils.dart';

///
/// Base
///
abstract class SignatureLogic {
  String algorithm = 'unknown';
  List<int> doCompact(String body);
  Map<String, dynamic> createJwk();
}

///
/// EC
///
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
      'x': B64.urlencode(x),
      'y': B64.urlencode(y),
    };
  }
}
