import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/data/auth_models.dart';

class SessionStorage {
  SessionStorage({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _tokenKey = 'eventhub.auth.token';
  static const _userKey = 'eventhub.auth.user';

  final FlutterSecureStorage _secureStorage;

  Future<AuthSession?> read() async {
    final token = await _secureStorage.read(key: _tokenKey);
    final userJson = await _secureStorage.read(key: _userKey);

    if (token == null || userJson == null) {
      return null;
    }

    return AuthSession(
      token: token,
      user: AuthUser.fromJson(jsonDecode(userJson) as Map<String, dynamic>),
    );
  }

  Future<void> write(AuthSession session) async {
    await Future.wait([
      _secureStorage.write(key: _tokenKey, value: session.token),
      _secureStorage.write(
        key: _userKey,
        value: jsonEncode(session.user.toJson()),
      ),
    ]);
  }

  Future<void> clear() async {
    await Future.wait([
      _secureStorage.delete(key: _tokenKey),
      _secureStorage.delete(key: _userKey),
    ]);
  }
}
