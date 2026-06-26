import '../../../core/networking/api_client.dart';
import 'auth_models.dart';

class AuthRepository {
  AuthRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.postJson(
      '/auth/login',
      body: {'email': email, 'password': password},
    );

    return AuthSession.fromJson(response);
  }

  Future<AuthSession> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await _apiClient.postJson(
      '/auth/register',
      body: {
        'fullName': fullName,
        'email': email,
        'password': password,
        'role': role,
      },
    );

    return AuthSession.fromJson(response);
  }

  Future<AuthSession> googleSignIn({required String firebaseIdToken}) async {
    final response = await _apiClient.postJson(
      '/auth/google',
      body: {'idToken': firebaseIdToken},
    );

    return AuthSession.fromJson(response);
  }

  Future<String> requestPasswordReset({required String email}) async {
    final response = await _apiClient.postJson(
      '/auth/forgot-password',
      body: {'email': email},
    );

    return response['message'] as String? ??
        'If an account exists for that email, password reset instructions have been sent.';
  }

  Future<AuthUser> me(String token) async {
    final response = await _apiClient.getJson('/auth/me', authToken: token);

    return AuthUser.fromJson(response['user'] as Map<String, dynamic>);
  }
}
