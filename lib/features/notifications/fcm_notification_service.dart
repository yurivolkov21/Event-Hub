import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class FcmNotificationService {
  FcmNotificationService({
    FirebaseMessaging? messaging,
    void Function(RemoteMessage message)? onForegroundMessage,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _onForegroundMessage = onForegroundMessage;

  final FirebaseMessaging _messaging;
  final void Function(RemoteMessage message)? _onForegroundMessage;

  Future<String?> initialize() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((message) {
      _onForegroundMessage?.call(message);
    });

    return _messaging.getToken();
  }

  Future<String?> getCurrentToken() {
    return _messaging.getToken();
  }

  Future<void> registerCurrentToken({required String authToken}) async {
    final fcmToken = await getCurrentToken();

    if (fcmToken == null) {
      return;
    }

    await registerToken(authToken: authToken, fcmToken: fcmToken);
  }

  Future<void> registerToken({
    required String authToken,
    required String fcmToken,
  }) async {
    final client = http.Client();

    try {
      final response = await client.post(
        Uri.parse('${AppConfig.apiBaseUrl}/notifications/register-token'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'token': fcmToken, 'platform': 'android'}),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to register FCM token');
      }
    } finally {
      client.close();
    }
  }
}
