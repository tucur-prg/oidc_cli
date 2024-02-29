import 'dart:math';
import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'extension.dart';
import 'B64.dart';

const _CHARSET =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-.,';

var _rand = Random.secure();

///
/// PKCE
/// https://tex2e.github.io/rfc-translater/html/rfc7636.html
///
String createVerifier() {
  List<int> bytes = List.generate(48, (_) => _rand.nextInt(256));
  return B64.urlencode(bytes);
}

String createCodeChallenge(String verifier) {
  return B64.urlencode(sha256.convert(utf8.encode(verifier)).bytes);
}

///
/// state
///
String createState() {
  List<int> bytes = List.generate(32, (_) => _rand.nextInt(256));
  return sha256.convert(bytes).bytes.toHex();
}

///
/// ランダム文字列
///
String createRandomString([int length = 32]) {
  final randomStr =
      List.generate(length, (_) => _CHARSET[_rand.nextInt(_CHARSET.length)])
          .join();
  return randomStr;
}
