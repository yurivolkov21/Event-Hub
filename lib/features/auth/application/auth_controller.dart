import 'package:flutter/foundation.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/storage/session_storage.dart';
import '../../notifications/fcm_notification_service.dart';
import '../data/auth_models.dart';
import '../data/auth_repository.dart';
import '../data/google_auth_service.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    AuthRepository? authRepository,
    SessionStorage? sessionStorage,
    GoogleAuthService? googleAuthService,
    this.fcmNotificationService,
    bool startLoading = true,
  }) : _authRepository = authRepository ?? AuthRepository(),
       _sessionStorage = sessionStorage ?? SessionStorage(),
       _googleAuthService = googleAuthService ?? GoogleAuthService(),
       _isLoading = startLoading;

  final AuthRepository _authRepository;
  final SessionStorage _sessionStorage;
  final GoogleAuthService _googleAuthService;
  final FcmNotificationService? fcmNotificationService;

  AuthSession? _session;
  bool _isLoading;
  String? _errorMessage;

  AuthSession? get session => _session;
  AuthUser? get user => _session?.user;
  bool get isAuthenticated => _session != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> restoreSession() async {
    _setLoading(true);

    try {
      final savedSession = await _sessionStorage.read();

      if (savedSession == null) {
        _session = null;
        return;
      }

      final user = await _authRepository.me(savedSession.token);
      _session = AuthSession(token: savedSession.token, user: user);
      await _sessionStorage.write(_session!);
      await _registerFcmToken();
    } catch (_) {
      _session = null;
      await _sessionStorage.clear();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> login({required String email, required String password}) async {
    await _authenticate(
      () => _authRepository.login(email: email, password: password),
    );
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    await _authenticate(
      () => _authRepository.register(
        fullName: fullName,
        email: email,
        password: password,
        role: role,
      ),
    );
  }

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final firebaseIdToken = await _googleAuthService.signIn();

      if (firebaseIdToken == null) {
        // User cancelled the Google account picker.
        return;
      }

      final nextSession = await _authRepository.googleSignIn(
        firebaseIdToken: firebaseIdToken,
      );
      _session = nextSession;
      await _sessionStorage.write(nextSession);
      await _registerFcmToken();
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Google sign-in failed. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _session = null;
    _errorMessage = null;
    await _sessionStorage.clear();
    await _googleAuthService.signOut();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _authenticate(Future<AuthSession> Function() action) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final nextSession = await action();
      _session = nextSession;
      await _sessionStorage.write(nextSession);
      await _registerFcmToken();
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to connect to EventHub API';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _registerFcmToken() async {
    final token = _session?.token;

    if (token == null || fcmNotificationService == null) {
      return;
    }

    try {
      await fcmNotificationService!.registerCurrentToken(authToken: token);
    } catch (_) {
      // Auth must remain usable even if FCM token registration fails.
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
