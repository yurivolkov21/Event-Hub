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

  /// OAuth Web client ID used as `serverClientId` for Google Sign-In on Android.
  /// Provide it at build/run time:
  ///   --dart-define=GOOGLE_SERVER_CLIENT_ID=<web-client-id>.apps.googleusercontent.com
  static String get googleServerClientId {
    return const String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
  }
}
