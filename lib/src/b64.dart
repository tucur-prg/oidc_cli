import 'dart:convert';

main() {
  var encStr1 = B64.urlencode<String>("hoge");
  print(encStr1);
  print(B64.urldecode<String>(encStr1));
  print(B64.urldecode<List<int>>(encStr1));
  print(B64.urldecode(encStr1));

  var encStr2 = B64.urlencode<List<int>>([104, 112, 103, 101]);
  print(encStr2);
  print(B64.urldecode<String>(encStr2));
  print(B64.urldecode<List<int>>(encStr2));
  print(B64.urldecode(encStr2));
}

///
/// Base64 拡張
///
class B64 {
  static String urlencode<T>(T value) {
    String str;
    switch (T) {
      case String:
        str = base64UrlEncode((value as String).codeUnits);
        break;
      case const (List<int>):
        str = base64Encode(value as List<int>);
        break;
      default:
        throw Exception("Not supported type '${T}'");
    }

    str = str.replaceAll('=', '');
    return str;
  }

  static T urldecode<T>(String source) {
    int pad = (4 - source.length % 4) % 4;
    List<int> value = base64Decode(source + '=' * pad);

    switch (T) {
      case String:
        return utf8.decode(value) as T;
      default:
        return value as T;
    }
  }
}
