import '../../../core/networking/api_client.dart';
import 'booking_models.dart';

class BookingRepository {
  BookingRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<BookingItem> createBooking({
    required String authToken,
    required String eventId,
    int quantity = 1,
  }) async {
    final response = await _apiClient.postJson(
      '/bookings',
      authToken: authToken,
      body: {'eventId': eventId, 'quantity': quantity},
    );

    return BookingItem.fromJson(response['booking'] as Map<String, dynamic>);
  }

  Future<List<BookingItem>> listMyBookings({required String authToken}) async {
    final response = await _apiClient.getJson(
      '/bookings/me',
      authToken: authToken,
    );

    return PaginatedBookings.fromJson(response).data;
  }

  Future<void> cancelBooking({
    required String authToken,
    required String bookingId,
  }) async {
    await _apiClient.deleteJson('/bookings/$bookingId', authToken: authToken);
  }
}
