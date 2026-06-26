import 'dart:typed_data';

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

  Future<UserProfile> getUserById(String userId) async {
    final response = await _apiClient.getJson('/users/$userId');

    return UserProfile.fromJson(response['user'] as Map<String, dynamic>);
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
    DateTime? dateOfBirth,
    String? location,
    String? gender,
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
    if (dateOfBirth != null) {
      body['dateOfBirth'] = dateOfBirth.toUtc().toIso8601String();
    }
    if (location != null) {
      body['location'] = location;
    }
    if (gender != null) {
      body['gender'] = gender;
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

  Future<UserProfile> uploadAvatar({
    required String authToken,
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  }) async {
    final response = await _apiClient.postMultipart(
      '/users/me/avatar',
      authToken: authToken,
      fields: const {},
      file: ApiMultipartFile(
        fieldName: 'image',
        fileName: fileName,
        bytes: bytes,
        mimeType: mimeType,
      ),
    );

    return UserProfile.fromJson(response['user'] as Map<String, dynamic>);
  }
}
