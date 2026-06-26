import '../../../core/networking/api_client.dart';
import 'review_models.dart';

class ReviewEligibility {
  const ReviewEligibility({required this.canReview, this.reason});

  final bool canReview;
  final String? reason;

  factory ReviewEligibility.fromJson(Map<String, dynamic> json) {
    return ReviewEligibility(
      canReview: json['canReview'] as bool? ?? false,
      reason: json['reason'] as String?,
    );
  }
}

class ReviewRepository {
  ReviewRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ReviewEligibility> getReviewEligibility({
    required String authToken,
    required String eventId,
  }) async {
    final response = await _apiClient.getJson(
      '/events/$eventId/reviews/eligibility',
      authToken: authToken,
    );

    return ReviewEligibility.fromJson(response);
  }

  Future<List<ReviewItem>> listReviews(String eventId) async {
    final response = await _apiClient.getJson('/events/$eventId/reviews');

    return (response['data'] as List<dynamic>)
        .map((json) => ReviewItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<ReviewItem>> listOrganizerReviews(String organizerId) async {
    final response = await _apiClient.getJson('/users/$organizerId/reviews');

    return (response['data'] as List<dynamic>)
        .map((json) => ReviewItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<ReviewItem> createReview({
    required String authToken,
    required String eventId,
    required int rating,
    required String comment,
  }) async {
    final response = await _apiClient.postJson(
      '/events/$eventId/reviews',
      authToken: authToken,
      body: {'rating': rating, 'comment': comment},
    );

    return ReviewItem.fromJson(response['review'] as Map<String, dynamic>);
  }
}
