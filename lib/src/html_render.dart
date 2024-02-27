import 'dart:io';

String render(String filepath, Map<String, String> values) {
  String html = File(filepath).readAsStringSync();
  values.entries.forEach((e) {
    html = html.replaceAll("{{${e.key}}}", e.value);
  });
  return html;
}
