import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'core/theme/eventhub_theme.dart';
import 'features/auth/application/auth_controller.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'features/auth/presentation/signed_in_home_screen.dart';
import 'features/notifications/fcm_notification_service.dart';
import 'features/notifications/local_notification_service.dart';
import 'features/onboarding/data/onboarding_storage.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/onboarding/presentation/splash_screen.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FcmNotificationService? fcmNotificationService;

  if (!kIsWeb) {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    final localNotifications = LocalNotificationService();
    await localNotifications.initialize();

    fcmNotificationService = FcmNotificationService(
      // Post incoming foreground messages to the Android system notification
      // shade (FCM does not do this automatically while the app is open).
      onForegroundMessage: localNotifications.showFromMessage,
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
  final OnboardingStorage _onboardingStorage = OnboardingStorage();

  bool _booting = true;
  bool _showOnboarding = false;

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

    Future.microtask(_boot);
  }

  Future<void> _boot() async {
    final completed = await _onboardingStorage.isCompleted();

    if (!mounted) {
      return;
    }

    setState(() {
      _showOnboarding = !completed;
      _booting = false;
    });
  }

  Future<void> _completeOnboarding() async {
    await _onboardingStorage.setCompleted();

    if (!mounted) {
      return;
    }

    setState(() => _showOnboarding = false);
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
      home: AnimatedBuilder(
        animation: _authController,
        builder: (context, _) {
          if (_booting || _authController.isLoading) {
            return const SplashScreen();
          }

          if (_showOnboarding) {
            return OnboardingScreen(onCompleted: _completeOnboarding);
          }

          if (_authController.isAuthenticated) {
            return SignedInHomeScreen(controller: _authController);
          }

          return AuthScreen(controller: _authController);
        },
      ),
    );
  }
}
