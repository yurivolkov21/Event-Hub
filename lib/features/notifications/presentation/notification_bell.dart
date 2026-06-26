import 'package:flutter/material.dart';

import '../data/notification_repository.dart';
import 'notification_list_screen.dart';

/// Header bell with an unread-count badge. Tapping opens the notification list
/// and refreshes the count on return. Used in the signed-in home header.
class NotificationBell extends StatefulWidget {
  const NotificationBell({
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
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  late final NotificationRepository _repository;
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    _repository = widget.notificationRepository ?? NotificationRepository();
    _loadCount();
  }

  Future<void> _loadCount() async {
    try {
      final count = await _repository.unreadCount(authToken: widget.authToken);
      if (!mounted) return;
      setState(() => _unread = count);
    } catch (_) {
      // Badge is best-effort; ignore failures.
    }
  }

  Future<void> _openNotifications() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NotificationListScreen(
          authToken: widget.authToken,
          currentUserId: widget.currentUserId,
          currentUserRole: widget.currentUserRole,
        ),
      ),
    );
    // Reading/clearing notifications changes the unread count.
    await _loadCount();
  }

  @override
  Widget build(BuildContext context) {
    return Badge.count(
      count: _unread,
      isLabelVisible: _unread > 0,
      child: IconButton.filled(
        tooltip: 'Notifications',
        onPressed: _openNotifications,
        style: IconButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.18),
          foregroundColor: Colors.white,
        ),
        icon: const Icon(Icons.notifications_none),
      ),
    );
  }
}
