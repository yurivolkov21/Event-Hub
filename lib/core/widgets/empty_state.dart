import 'package:flutter/material.dart';

import '../theme/eventhub_theme.dart';

/// A reusable empty-state illustration block matching the EventHub Figma
/// "No Upcoming Event" / "No Notifications!" screens: a soft circular backdrop
/// with an icon, a bold title, a muted description, and an optional CTA.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.badge,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;

  /// Optional small badge text rendered on the illustration (e.g. "0").
  final String? badge;

  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: const BoxDecoration(
                    color: EventHubTheme.softBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 64, color: EventHubTheme.primary),
                ),
                if (badge != null)
                  Positioned(
                    right: 6,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: EventHubTheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: EventHubTheme.background,
                          width: 3,
                        ),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 38,
                        minHeight: 38,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        badge!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: EventHubTheme.muted,
              height: 1.5,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 32),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(minimumSize: const Size(220, 56)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(actionLabel!),
                  const SizedBox(width: 14),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward, size: 18),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
