import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'core/theme/eventhub_theme.dart';
import 'features/auth/application/auth_controller.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'features/auth/presentation/signed_in_home_screen.dart';
import 'features/notifications/fcm_notification_service.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void _showForegroundNotification(RemoteMessage message) {
  final notification = message.notification;
  final messenger = rootScaffoldMessengerKey.currentState;

  if (notification == null || messenger == null) {
    return;
  }

  messenger
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        backgroundColor: EventHubTheme.primary,
        content: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title ?? 'EventHub',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (notification.body != null && notification.body!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        notification.body!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FcmNotificationService? fcmNotificationService;

  if (!kIsWeb) {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    fcmNotificationService = FcmNotificationService(
      onForegroundMessage: _showForegroundNotification,
    );
    await fcmNotificationService.initialize();
  }

  runApp(EventHubApp(fcmNotificationService: fcmNotificationService));
}

class EventHubApp extends StatefulWidget {
  const EventHubApp({
    this.fcmNotificationService,
    this.restoreSession = true,
    super.key,
  });

  final FcmNotificationService? fcmNotificationService;
  final bool restoreSession;

  @override
  State<EventHubApp> createState() => _EventHubAppState();
}

class _EventHubAppState extends State<EventHubApp> {
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();

    _authController = AuthController(
      fcmNotificationService: widget.fcmNotificationService,
      startLoading: widget.restoreSession,
    );

    if (widget.restoreSession) {
      Future.microtask(_authController.restoreSession);
    }
  }

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      title: 'EventHub',
      theme: EventHubTheme.light(),
      home: AuthGate(controller: _authController),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({required this.controller, super.key});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (controller.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (controller.isAuthenticated) {
          return SignedInHomeScreen(controller: controller);
        }

        return AuthScreen(controller: controller);
      },
    );
  }
}
