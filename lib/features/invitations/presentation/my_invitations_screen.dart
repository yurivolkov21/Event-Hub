import 'package:flutter/material.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/theme/eventhub_theme.dart';
import '../../events/presentation/event_detail_screen.dart';
import '../data/invitation_models.dart';
import '../data/invitation_repository.dart';

/// Inbox of invitations the current user has received. Lets them accept or
/// reject a pending invitation and open the related event. This is the
/// "receive" half of the invitation loop (the "send" half lives in the event
/// detail invite sheet).
class MyInvitationsScreen extends StatefulWidget {
  const MyInvitationsScreen({
    required this.authToken,
    required this.currentUserId,
    required this.currentUserRole,
    this.invitationRepository,
    super.key,
  });

  final String authToken;
  final String currentUserId;
  final String currentUserRole;
  final InvitationRepository? invitationRepository;

  @override
  State<MyInvitationsScreen> createState() => _MyInvitationsScreenState();
}

class _MyInvitationsScreenState extends State<MyInvitationsScreen> {
  late final InvitationRepository _invitationRepository;

  List<InvitationItem> _invitations = [];
  bool _isLoading = true;
  String? _errorMessage;
  final Set<String> _busyIds = {};

  @override
  void initState() {
    super.initState();
    _invitationRepository =
        widget.invitationRepository ?? InvitationRepository();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final invitations = await _invitationRepository.listMyInvitations(
        authToken: widget.authToken,
      );
      if (!mounted) return;
      setState(() => _invitations = invitations);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Unable to load invitations');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _respond(
    InvitationItem invitation, {
    required bool accept,
  }) async {
    setState(() => _busyIds.add(invitation.id));

    try {
      final updated = accept
          ? await _invitationRepository.acceptInvitation(
              authToken: widget.authToken,
              invitationId: invitation.id,
            )
          : await _invitationRepository.rejectInvitation(
              authToken: widget.authToken,
              invitationId: invitation.id,
            );

      if (!mounted) return;
      setState(() {
        _invitations = _invitations
            .map(
              (item) => item.id == invitation.id
                  ? item.copyWith(status: updated.status)
                  : item,
            )
            .toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            accept
                ? 'Invitation accepted. See you there!'
                : 'Invitation declined.',
          ),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to respond')));
    } finally {
      if (mounted) {
        setState(() => _busyIds.remove(invitation.id));
      }
    }
  }

  void _openEvent(InvitationItem invitation) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EventDetailScreen(
          eventId: invitation.eventId,
          authToken: widget.authToken,
          currentUserId: widget.currentUserId,
          currentUserRole: widget.currentUserRole,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invitations')),
      body: RefreshIndicator(onRefresh: _load, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Center(
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 42,
                  color: EventHubTheme.primary,
                ),
                const SizedBox(height: 12),
                Text(_errorMessage!),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (_invitations.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 140),
          Center(child: Text('No invitations yet')),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _invitations.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final invitation = _invitations[index];

        return _InvitationCard(
          invitation: invitation,
          isBusy: _busyIds.contains(invitation.id),
          onOpen: () => _openEvent(invitation),
          onAccept: () => _respond(invitation, accept: true),
          onReject: () => _respond(invitation, accept: false),
        );
      },
    );
  }
}

class _InvitationCard extends StatelessWidget {
  const _InvitationCard({
    required this.invitation,
    required this.isBusy,
    required this.onOpen,
    required this.onAccept,
    required this.onReject,
  });

  final InvitationItem invitation;
  final bool isBusy;
  final VoidCallback onOpen;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final title = invitation.eventTitle ?? 'An event';
    final inviter = invitation.fromUserName ?? 'Someone';

    return Material(
      color: Colors.white,
      elevation: 6,
      shadowColor: const Color(0x106F73A8),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: EventHubTheme.softBlue,
                    foregroundColor: EventHubTheme.primary,
                    child: Icon(Icons.mail_outline, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: inviter,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const TextSpan(text: ' invited you to'),
                        ],
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  _StatusChip(status: invitation.status),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              if (invitation.eventVenueName != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 15,
                      color: EventHubTheme.muted,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        invitation.eventVenueName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ],
              if (invitation.isPending) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isBusy ? null : onReject,
                        child: const Text('Decline'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: isBusy ? null : onAccept,
                        child: isBusy
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (Color color, String label) = switch (status) {
      'accepted' => (EventHubTheme.green, 'Accepted'),
      'rejected' => (EventHubTheme.coral, 'Declined'),
      _ => (EventHubTheme.orange, 'Pending'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}
