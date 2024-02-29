import 'dart:convert';

import 'package:crypto/crypto.dart';

mixin ECLogic {
  List<int> createMessageHash(String message) {
    return sha256.convert(utf8.encode(message)).bytes;
  }
}
