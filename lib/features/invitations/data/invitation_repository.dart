import '../../../core/networking/api_client.dart';
import 'invitation_models.dart';

class InvitationRepository {
  InvitationRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<InvitationItem>> createInvitations({
    required String authToken,
    required String eventId,
    required List<String> userIds,
  }) async {
    final response = await _apiClient.postJson(
      '/events/$eventId/invitations',
      authToken: authToken,
      body: {'userIds': userIds},
    );

    return (response['invitations'] as List<dynamic>)
        .map(
          (invitationJson) =>
              InvitationItem.fromJson(invitationJson as Map<String, dynamic>),
        )
        .toList();
  }
}
