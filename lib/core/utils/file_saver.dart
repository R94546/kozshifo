import 'dart:typed_data';

import 'file_saver_io.dart' if (dart.library.js_interop) 'file_saver_web.dart' as impl;

/// Saves [bytes] as a downloadable file.
///
/// On web triggers a browser download and returns null; elsewhere writes to the
/// system temp directory and returns the absolute path.
Future<String?> saveBytes(Uint8List bytes, String filename, String mime) =>
    impl.saveBytes(bytes, filename, mime);
