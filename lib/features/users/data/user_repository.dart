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
}
