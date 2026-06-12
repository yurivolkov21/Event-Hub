import 'package:flutter/material.dart';

import '../../bookings/presentation/my_tickets_screen.dart';
import '../../events/presentation/event_list_screen.dart';
import '../../notifications/presentation/notification_list_screen.dart';
import '../application/auth_controller.dart';

class SignedInHomeScreen extends StatelessWidget {
  const SignedInHomeScreen({required this.controller, super.key});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    final user = controller.user!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('EventHub'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: controller.logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, ${user.fullName}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                user.email,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),
              Chip(
                avatar: Icon(
                  user.role == 'organizer'
                      ? Icons.storefront_outlined
                      : Icons.person_outline,
                ),
                label: Text(user.role == 'organizer' ? 'Organizer' : 'User'),
              ),
              const SizedBox(height: 24),
              _HomeActionButton(
                icon: Icons.event_note,
                label: 'Events',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => EventListScreen(
                        authToken: controller.session!.token,
                        currentUserId: user.id,
                        currentUserRole: user.role,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _HomeActionButton(
                icon: Icons.confirmation_number_outlined,
                label: 'My Tickets',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          MyTicketsScreen(authToken: controller.session!.token),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _HomeActionButton(
                icon: Icons.notifications_none,
                label: 'Notifications',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => NotificationListScreen(
                        authToken: controller.session!.token,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeActionButton extends StatelessWidget {
  const _HomeActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
