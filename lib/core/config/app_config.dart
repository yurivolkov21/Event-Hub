import 'package:flutter/foundation.dart';

class AppConfig {
  static String get apiBaseUrl {
    const override = String.fromEnvironment('API_BASE_URL');

    if (override.isNotEmpty) {
      return override;
    }

    if (kIsWeb) {
      return 'http://localhost:4000/api';
    }

    return 'http://10.0.2.2:4000/api';
  }
}
