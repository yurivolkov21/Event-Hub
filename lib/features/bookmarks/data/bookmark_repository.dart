import '../../../core/networking/api_client.dart';
import 'bookmark_models.dart';

class BookmarkRepository {
  BookmarkRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<void> createBookmark({
    required String authToken,
    required String eventId,
  }) async {
    await _apiClient.postJson(
      '/bookmarks/$eventId',
      authToken: authToken,
      body: {},
    );
  }

  Future<List<BookmarkItem>> listMyBookmarks({
    required String authToken,
  }) async {
    final response = await _apiClient.getJson(
      '/bookmarks/me',
      authToken: authToken,
    );

    return PaginatedBookmarks.fromJson(response).data;
  }

  Future<void> deleteBookmark({
    required String authToken,
    required String eventId,
  }) async {
    await _apiClient.deleteJson('/bookmarks/$eventId', authToken: authToken);
  }
}
