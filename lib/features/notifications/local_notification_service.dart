import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Shows notifications in the Android system notification shade (status bar),
/// including when the app is in the foreground — FCM does not post a system
/// notification automatically while the app is open, so we do it ourselves.
class LocalNotificationService {
  LocalNotificationService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'eventhub_default',
    'EventHub Notifications',
    description: 'Bookings, invitations and event updates',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidSettings),
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(_channel);
    await androidPlugin?.requestNotificationsPermission();
  }

  /// Posts a system-tray notification for an incoming FCM message.
  Future<void> showFromMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) {
      return;
    }

    await _plugin.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}
