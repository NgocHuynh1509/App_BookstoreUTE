import 'package:flutter/foundation.dart';

/// Cấu hình URL backend dùng chung cho toàn app.
///
/// Có thể override bằng:
/// flutter run --dart-define=API_BASE_URL=http://YOUR_IP:8080
class ApiConfig {
  static const String _envBaseUrl =
	  String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static String get baseUrl {
	if (_envBaseUrl.trim().isNotEmpty) {
	  return _normalize(_envBaseUrl);
	}

	if (kIsWeb) {
	  return 'http://localhost:8080';
	}

	switch (defaultTargetPlatform) {
	  case TargetPlatform.android:
		// Android emulator map localhost host machine -> 10.0.2.2
		return 'http://10.0.2.2:8080';
	  case TargetPlatform.iOS:
		return 'http://127.0.0.1:8080';
	  default:
		// Windows/macOS/Linux desktop
		return 'http://localhost:8080';
	}
  }

  static String _normalize(String url) {
	return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }
}

