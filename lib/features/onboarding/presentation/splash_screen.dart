import 'package:flutter/material.dart';

import '../../../core/theme/eventhub_theme.dart';

/// Branded launch screen shown while the app boots (reading the onboarding flag
/// and restoring the saved session). Kept static (no tickers/timers) so widget
/// tests stay deterministic.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EventHubTheme.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 104,
              height: 104,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 54,
                    height: 54,
                    decoration: const BoxDecoration(
                      color: EventHubTheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Transform.rotate(
                    angle: -0.45,
                    child: Container(
                      width: 72,
                      height: 22,
                      decoration: BoxDecoration(
                        color: EventHubTheme.accent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'EventHub',
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Discover events around you',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
