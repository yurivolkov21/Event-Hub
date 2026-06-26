import 'package:flutter/material.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/widgets/empty_state.dart';
import '../../events/presentation/event_detail_screen.dart';
import '../data/notification_models.dart';
import '../data/notification_repository.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({
    required this.authToken,
    required this.currentUserId,
    required this.currentUserRole,
    this.notificationRepository,
    super.key,
  });

  final String authToken;
  final String currentUserId;
  final String currentUserRole;
  final NotificationRepository? notificationRepository;

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  late final NotificationRepository _notificationRepository;
  List<NotificationItem> _notifications = [];
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _notificationRepository =
        widget.notificationRepository ?? NotificationRepository();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final notifications = await _notificationRepository.listNotifications(
        authToken: widget.authToken,
      );
      setState(() => _notifications = notifications);
    } on ApiException catch (error) {
      setState(() => _errorMessage = error.message);
    } catch (_) {
      setState(() => _errorMessage = 'Unable to load notifications');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleTap(NotificationItem notification) async {
    await _markRead(notification);
    if (!mounted) return;

    // Deep-link: most notifications carry the related eventId so tapping opens
    // the event. This is what makes notifications actionable instead of inert.
    final eventId = notification.data['eventId'];
    if (eventId != null && eventId.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => EventDetailScreen(
            eventId: eventId,
            authToken: widget.authToken,
            currentUserId: widget.currentUserId,
            currentUserRole: widget.currentUserRole,
          ),
        ),
      );
    }
  }

  Future<void> _markRead(NotificationItem notification) async {
    if (notification.isRead) {
      return;
    }

    try {
      final updated = await _notificationRepository.markAsRead(
        authToken: widget.authToken,
        notificationId: notification.id,
      );
      if (!mounted) return;
      setState(() {
        _notifications = _notifications
            .map((item) => item.id == updated.id ? updated : item)
            .toList();
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Unable to mark notification read');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 96),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_errorMessage != null)
              _NotificationMessage(
                icon: Icons.error_outline,
                message: _errorMessage!,
                onRetry: _loadNotifications,
              )
            else if (_notifications.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: EmptyState(
                  icon: Icons.notifications_none,
                  badge: '0',
                  title: 'No Notifications!',
                  message:
                      'Your booking updates and event invitations will show up here.',
                ),
              )
            else
              ..._notifications.map(
                (notification) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _NotificationTile(
                    notification: notification,
                    onTap: () => _handleTap(notification),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final NotificationItem notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      color: notification.isRead ? null : colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          notification.isRead
              ? Icons.notifications_none
              : Icons.notifications_active,
        ),
        title: Text(notification.title),
        subtitle: Text(notification.body),
        trailing: notification.isRead
            ? null
            : const Icon(Icons.mark_email_read_outlined),
      ),
    );
  }
}

class _NotificationMessage extends StatelessWidget {
  const _NotificationMessage({
    required this.icon,
    required this.message,
    required this.onRetry,
  });

  final IconData icon;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 96),
      child: Center(
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(message),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
