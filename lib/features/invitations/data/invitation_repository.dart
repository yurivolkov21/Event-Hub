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

  Future<List<InvitationItem>> listMyInvitations({
    required String authToken,
    String? status,
  }) async {
    final response = await _apiClient.getJson(
      '/invitations/me',
      authToken: authToken,
      queryParameters: {
        'limit': '50',
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );

    return PaginatedInvitations.fromJson(response).data;
  }

  Future<InvitationItem> acceptInvitation({
    required String authToken,
    required String invitationId,
  }) async {
    final response = await _apiClient.putJson(
      '/invitations/$invitationId/accept',
      authToken: authToken,
      body: const {},
    );

    return InvitationItem.fromJson(
      response['invitation'] as Map<String, dynamic>,
    );
  }

  Future<InvitationItem> rejectInvitation({
    required String authToken,
    required String invitationId,
  }) async {
    final response = await _apiClient.putJson(
      '/invitations/$invitationId/reject',
      authToken: authToken,
      body: const {},
    );

    return InvitationItem.fromJson(
      response['invitation'] as Map<String, dynamic>,
    );
  }
}
