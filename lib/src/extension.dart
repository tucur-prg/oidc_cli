import 'dart:typed_data';

extension ExUint8List on Uint8List {
  String toHex() {
    return this.map((v) => v.toRadixString(16).padLeft(2, '0')).join('');
  }
}

extension ExList on List {
  String toHex() {
    return this.map((v) => v.toRadixString(16).padLeft(2, '0')).join('');
  }
}

extension ExMap on Map {
  String toQueryString() {
    return entries.map((e) {
      if (e.value is List) {
        List<String> l = [];
        for (var v in e.value) {
          l.add(
              '${Uri.encodeQueryComponent(e.key)}[]=${Uri.encodeQueryComponent(v)}');
        }
        return l.join('&');
      }

      return '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}';
    }).join('&');
  }

  String toCookie() {
    return entries.map((e) => "${e.key}=${e.value}").join('; ');
  }
}
