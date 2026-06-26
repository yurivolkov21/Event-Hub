import '../../../core/networking/api_client.dart';
import 'user_models.dart';

class UserRepository {
  UserRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<UserSummary>> listUsers({
    required String authToken,
    String? search,
  }) async {
    final response = await _apiClient.getJson(
      '/users',
      authToken: authToken,
      queryParameters: {
        'limit': '20',
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );

    return UserListResponse.fromJson(response).data;
  }

  Future<UserProfile> getMyProfile({required String authToken}) async {
    final response = await _apiClient.getJson('/auth/me', authToken: authToken);

    return UserProfile.fromJson(response['user'] as Map<String, dynamic>);
  }

  Future<UserProfile> updateProfile({
    required String authToken,
    String? fullName,
    String? phone,
    String? bio,
    List<String>? interests,
  }) async {
    final body = <String, dynamic>{};

    if (fullName != null) {
      body['fullName'] = fullName;
    }
    if (phone != null) {
      body['phone'] = phone;
    }
    if (bio != null) {
      body['bio'] = bio;
    }
    if (interests != null) {
      body['interests'] = interests;
    }

    final response = await _apiClient.putJson(
      '/users/me',
      authToken: authToken,
      body: body,
    );

    return UserProfile.fromJson(response['user'] as Map<String, dynamic>);
  }
}
