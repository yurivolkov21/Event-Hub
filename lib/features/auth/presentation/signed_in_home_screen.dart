import 'package:flutter/material.dart';

import '../../../core/theme/eventhub_theme.dart';
import '../../bookings/presentation/my_tickets_screen.dart';
import '../../events/presentation/event_list_screen.dart';
import '../../notifications/presentation/notification_list_screen.dart';
import '../../users/presentation/profile_screen.dart';
import '../application/auth_controller.dart';

class SignedInHomeScreen extends StatelessWidget {
  const SignedInHomeScreen({required this.controller, super.key});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    final user = controller.user!;
    final session = controller.session!;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _HomeHeader(
            fullName: user.fullName,
            email: user.email,
            role: user.role,
            onLogout: controller.logout,
            onTapProfile: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ProfileScreen(authToken: session.token),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore EventHub',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 14),
                _HomeActionTile(
                  icon: Icons.explore_outlined,
                  iconColor: EventHubTheme.primary,
                  title: 'Events',
                  subtitle: 'Upcoming events near you',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => EventListScreen(
                          authToken: session.token,
                          currentUserId: user.id,
                          currentUserRole: user.role,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                _HomeActionTile(
                  icon: Icons.confirmation_number_outlined,
                  iconColor: EventHubTheme.orange,
                  title: 'My Tickets',
                  subtitle: 'Confirmed and cancelled tickets',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            MyTicketsScreen(authToken: session.token),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                _HomeActionTile(
                  icon: Icons.notifications_none,
                  iconColor: EventHubTheme.green,
                  title: 'Notifications',
                  subtitle: 'Invitations and booking updates',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            NotificationListScreen(authToken: session.token),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.fullName,
    required this.email,
    required this.role,
    required this.onLogout,
    required this.onTapProfile,
  });

  final String fullName;
  final String email;
  final String role;
  final VoidCallback onLogout;
  final VoidCallback onTapProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: EventHubTheme.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        MediaQuery.paddingOf(context).top + 18,
        24,
        30,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                  foregroundColor: Colors.white,
                ),
                tooltip: 'Menu',
                onPressed: () {},
                icon: const Icon(Icons.menu),
              ),
              const Spacer(),
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                  foregroundColor: Colors.white,
                ),
                tooltip: 'Sign out',
                onPressed: onLogout,
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Current Location',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                'EventHub, Android',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              GestureDetector(
                onTap: onTapProfile,
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  foregroundColor: EventHubTheme.primary,
                  child: Text(
                    _initialsFromName(fullName),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.76),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  role == 'organizer'
                      ? Icons.storefront_outlined
                      : Icons.person_outline,
                  size: 18,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  role == 'organizer' ? 'Organizer' : 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeActionTile extends StatelessWidget {
  const _HomeActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 10,
      shadowColor: const Color(0x146F73A8),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.chevron_right, color: EventHubTheme.muted),
            ],
          ),
        ),
      ),
    );
  }
}

String _initialsFromName(String value) {
  final words = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList();

  if (words.isEmpty) {
    return '?';
  }

  return words
      .take(2)
      .map((word) => word.characters.first)
      .join()
      .toUpperCase();
}
