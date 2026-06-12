import 'package:flutter/material.dart';

import '../../events/presentation/event_list_screen.dart';
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
              FilledButton.icon(
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
                icon: const Icon(Icons.event_note),
                label: const Text('Events'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
