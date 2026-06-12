import '../../../core/networking/api_client.dart';
import 'notification_models.dart';

class NotificationRepository {
  NotificationRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<NotificationItem>> listNotifications({
    required String authToken,
  }) async {
    final response = await _apiClient.getJson(
      '/notifications',
      authToken: authToken,
    );

    return PaginatedNotifications.fromJson(response).data;
  }

  Future<NotificationItem> markAsRead({
    required String authToken,
    required String notificationId,
  }) async {
    final response = await _apiClient.putJson(
      '/notifications/$notificationId/read',
      authToken: authToken,
      body: {},
    );

    return NotificationItem.fromJson(
      response['notification'] as Map<String, dynamic>,
    );
  }
}
