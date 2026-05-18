import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../errors/failures.dart';

class FailureView extends StatelessWidget {
  const FailureView({
    required this.failure,
    required this.onRetry,
    super.key,
    this.title = 'Could not load stories',
  });

  final Failure failure;
  final VoidCallback onRetry;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final icon = switch (failure.type) {
      FailureType.network => Icons.wifi_off_rounded,
      FailureType.timeout => Icons.timer_off_rounded,
      FailureType.empty => Icons.inbox_rounded,
      _ => Icons.cloud_off_rounded,
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: colors.primary, size: 34),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              failure.message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ).animate().fadeIn(duration: 260.ms).slideY(begin: 0.05, end: 0),
      ),
    );
  }
}
