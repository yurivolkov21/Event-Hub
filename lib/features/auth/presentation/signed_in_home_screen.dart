import 'package:flutter/material.dart';

import '../../../core/theme/eventhub_theme.dart';
import '../../bookings/presentation/my_tickets_screen.dart';
import '../../events/presentation/event_list_screen.dart';
import '../../invitations/presentation/my_invitations_screen.dart';
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
      drawer: _HomeDrawer(controller: controller),
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
                        builder: (_) => NotificationListScreen(
                          authToken: session.token,
                          currentUserId: user.id,
                          currentUserRole: user.role,
                        ),
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
                onPressed: () => Scaffold.of(context).openDrawer(),
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

class _HomeDrawer extends StatelessWidget {
  const _HomeDrawer({required this.controller});

  final AuthController controller;

  void _go(BuildContext context, Widget screen) {
    Navigator.of(context).pop();
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final user = controller.user!;
    final session = controller.session!;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: EventHubTheme.primary.withValues(
                      alpha: 0.14,
                    ),
                    foregroundColor: EventHubTheme.primary,
                    child: Text(
                      _initialsFromName(user.fullName),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        Text(
                          user.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: EventHubTheme.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            _DrawerItem(
              icon: Icons.person_outline,
              label: 'My Profile',
              onTap: () =>
                  _go(context, ProfileScreen(authToken: session.token)),
            ),
            _DrawerItem(
              icon: Icons.explore_outlined,
              label: 'Events',
              onTap: () => _go(
                context,
                EventListScreen(
                  authToken: session.token,
                  currentUserId: user.id,
                  currentUserRole: user.role,
                ),
              ),
            ),
            _DrawerItem(
              icon: Icons.confirmation_number_outlined,
              label: 'My Tickets',
              onTap: () =>
                  _go(context, MyTicketsScreen(authToken: session.token)),
            ),
            _DrawerItem(
              icon: Icons.mail_outline,
              label: 'Invitations',
              onTap: () => _go(
                context,
                MyInvitationsScreen(
                  authToken: session.token,
                  currentUserId: user.id,
                  currentUserRole: user.role,
                ),
              ),
            ),
            _DrawerItem(
              icon: Icons.notifications_none,
              label: 'Notifications',
              onTap: () => _go(
                context,
                NotificationListScreen(
                  authToken: session.token,
                  currentUserId: user.id,
                  currentUserRole: user.role,
                ),
              ),
            ),
            const Spacer(),
            const Divider(height: 1),
            _DrawerItem(
              icon: Icons.logout,
              label: 'Sign Out',
              onTap: () {
                Navigator.of(context).pop();
                controller.logout();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: EventHubTheme.primary),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      onTap: onTap,
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
