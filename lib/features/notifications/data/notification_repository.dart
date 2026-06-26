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

  Future<int> unreadCount({required String authToken}) async {
    final response = await _apiClient.getJson(
      '/notifications',
      authToken: authToken,
      queryParameters: {'unreadOnly': 'true', 'limit': '1'},
    );

    final pagination = response['pagination'] as Map<String, dynamic>?;
    return (pagination?['total'] as num?)?.toInt() ?? 0;
  }

  Future<void> deleteNotification({
    required String authToken,
    required String notificationId,
  }) async {
    await _apiClient.deleteJson(
      '/notifications/$notificationId',
      authToken: authToken,
    );
  }

  Future<void> clearReadNotifications({required String authToken}) async {
    await _apiClient.deleteJson(
      '/notifications/clear-read',
      authToken: authToken,
    );
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
