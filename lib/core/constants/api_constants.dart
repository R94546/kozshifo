import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  ApiConstants._();

  static const String _envBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  /// Backend base URL, resolved in priority order:
  /// 1. `--dart-define=API_BASE_URL=...` — explicit override wins on any platform.
  /// 2. On **web** with no override: the origin that served the page
  ///    (`Uri.base.origin`). The backend serves the web build itself, so the
  ///    client always talks to the same host it was opened from —
  ///    `localhost`, a LAN IP (e.g. http://10.34.93.194:8000), or a hostname —
  ///    with no rebuild when the IP changes.
  /// 3. Desktop/mobile dev fallback: http://127.0.0.1:8000
  ///    (Android emulator: pass `--dart-define=API_BASE_URL=http://10.0.2.2:8000`).
  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
    if (kIsWeb) return Uri.base.origin;
    return 'http://127.0.0.1:8000';
  }

  static const String apiPrefix = '/api/v1';

  static String get apiBase => '$baseUrl$apiPrefix';
}
