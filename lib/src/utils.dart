import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';

///
/// ブラウザでURLを立ち上げる
///
void runBrowser(String url) {
  var fail = false;
  switch (Platform.operatingSystem) {
    case "linux":
      Process.run("x-www-browser", [url]);
      break;
    case "macos":
      Process.run("open", [url]);
      break;
    case "windows":
      Process.run("explorer", [url]);
      break;
    default:
      fail = true;
      break;
  }

  if (!fail) {
    print("Start browsing...");
  }
}

///
/// キーファイルを読み込む
///
String getRawKey(String path) {
  return File(path).readAsStringSync();
}

List<int> getKey(String path) {
  var raw = getRawKey(path);
  var l = raw.split("\n");
  var c = l.getRange(1, l.length - 2).join("");
  return base64Decode(c).toList();
}

///
/// openssl で作った ecc(prime256v1) の秘密鍵から d 部分を取り出す
///
List<List<int>> privateKey(List<int> pem) {
  int block = 7;
  int l = pem[6];

  var d = pem.getRange(block, l + block).toList();

  return [d];
}

///
/// openssl でつくった ecc(prime256v1) の公開鍵から x, y 部分を取り出す
///
List<List<int>> publicKey(List<int> pem) {
  int block = 25;
  int l = pem[24];

  var xy = pem.getRange(block, l + block).toList();
  var keySize = (xy.length - 2) ~/ 2;

  var x = xy.getRange(2, 2 + keySize).toList();
  var y = xy.getRange(2 + keySize, xy.length).toList();

  return [x, y];
}

// TODO: encode, decode の rename

//
// B64urlエンコード
//
String encode(List<int> bytes) {
  var str = base64UrlEncode(bytes);
  str = str.replaceAll('=', '');
  return str;
}

///
/// B64urlデコード
///
Uint8List decode(String text) {
  int add = text.length % 4;
  var str = text + ('=' * ((4 - add) % 4));
  return base64Decode(str);
}

///
/// HexString to Bytes
///
List<int> hexToBytes(String hex) {
  List<int> list = [];
  for (int i = 0; i < hex.length; i += 2) {
    list.add(int.parse(hex[i] + hex[i + 1], radix: 16));
  }
  return list;
}
