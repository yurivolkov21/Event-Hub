import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists whether the user has already seen the onboarding carousel, so it is
/// shown only on the first launch.
class OnboardingStorage {
  OnboardingStorage({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _completedKey = 'eventhub.onboarding.completed';

  final FlutterSecureStorage _secureStorage;

  Future<bool> isCompleted() async {
    try {
      final value = await _secureStorage.read(key: _completedKey);
      return value == 'true';
    } catch (_) {
      // Treat any storage error as "not completed" so onboarding still shows.
      return false;
    }
  }

  Future<void> setCompleted() async {
    try {
      await _secureStorage.write(key: _completedKey, value: 'true');
    } catch (_) {
      // Non-fatal: failing to persist just means onboarding may show again.
    }
  }
}
