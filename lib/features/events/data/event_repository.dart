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

  Future<EventItem> createEvent({
    required String authToken,
    required EventFormInput input,
    EventImageUpload? image,
  }) async {
    if (image != null) {
      final response = await _apiClient.postMultipart(
        '/events',
        authToken: authToken,
        fields: input.toMultipartFields(),
        file: ApiMultipartFile(
          fieldName: 'image',
          fileName: image.fileName,
          bytes: image.bytes,
          mimeType: image.mimeType,
        ),
      );

      return EventItem.fromJson(response['event'] as Map<String, dynamic>);
    }

    final response = await _apiClient.postJson(
      '/events',
      authToken: authToken,
      body: input.toJson(),
    );

    return EventItem.fromJson(response['event'] as Map<String, dynamic>);
  }

  Future<EventItem> updateEvent({
    required String eventId,
    required String authToken,
    required EventFormInput input,
    EventImageUpload? image,
  }) async {
    if (image != null) {
      final response = await _apiClient.putMultipart(
        '/events/$eventId',
        authToken: authToken,
        fields: input.toMultipartFields(),
        file: ApiMultipartFile(
          fieldName: 'image',
          fileName: image.fileName,
          bytes: image.bytes,
          mimeType: image.mimeType,
        ),
      );

      return EventItem.fromJson(response['event'] as Map<String, dynamic>);
    }

    final response = await _apiClient.putJson(
      '/events/$eventId',
      authToken: authToken,
      body: input.toJson(),
    );

    return EventItem.fromJson(response['event'] as Map<String, dynamic>);
  }

  Future<void> deleteEvent({
    required String eventId,
    required String authToken,
  }) async {
    await _apiClient.deleteJson('/events/$eventId', authToken: authToken);
  }
}
