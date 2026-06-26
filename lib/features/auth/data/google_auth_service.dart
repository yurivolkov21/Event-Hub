import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/config/app_config.dart';

/// Wraps Google Sign-In (v7) + Firebase Authentication.
///
/// Flow: pick a Google account -> sign in to Firebase with the Google credential
/// -> return the Firebase ID token so the backend can verify it and issue an
/// app JWT.
class GoogleAuthService {
  GoogleAuthService({FirebaseAuth? firebaseAuth})
    : _injectedAuth = firebaseAuth;

  // Resolved lazily so constructing this service never touches
  // FirebaseAuth.instance before Firebase is initialized (e.g. in widget tests).
  final FirebaseAuth? _injectedAuth;
  FirebaseAuth get _firebaseAuth => _injectedAuth ?? FirebaseAuth.instance;
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }

    final serverClientId = AppConfig.googleServerClientId;

    await GoogleSignIn.instance.initialize(
      serverClientId: serverClientId.isEmpty ? null : serverClientId,
    );

    _initialized = true;
  }

  /// Returns the Firebase ID token on success, or `null` if the user cancelled.
  Future<String?> signIn() async {
    await _ensureInitialized();

    final GoogleSignInAccount account;
    try {
      account = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      rethrow;
    }

    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw Exception('Google did not return an ID token');
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final userCredential = await _firebaseAuth.signInWithCredential(credential);

    return userCredential.user?.getIdToken();
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Best-effort; ignore Google sign-out failures.
    }
    try {
      await _firebaseAuth.signOut();
    } catch (_) {
      // Best-effort; ignore Firebase sign-out failures.
    }
  }
}
