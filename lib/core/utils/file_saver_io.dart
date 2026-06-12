import 'dart:io';
import 'dart:typed_data';

Future<String?> saveBytes(Uint8List bytes, String filename, String mime) async {
  final file = File('${Directory.systemTemp.path}${Platform.pathSeparator}$filename');
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}
