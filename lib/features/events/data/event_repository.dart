import '../../../core/networking/api_client.dart';
import 'event_models.dart';

class EventRepository {
  EventRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<PaginatedEvents> listEvents({
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiClient.getJson(
      '/events',
      queryParameters: {
        'page': '$page',
        'limit': '$limit',
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );

    return PaginatedEvents.fromJson(response);
  }

  Future<EventItem> getEventById(String eventId) async {
    final response = await _apiClient.getJson('/events/$eventId');

    return EventItem.fromJson(response['event'] as Map<String, dynamic>);
  }
}
