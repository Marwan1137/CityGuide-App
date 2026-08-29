import 'package:flutter/material.dart';

class ExplorerRefreshErrorBanner extends StatelessWidget {
  const ExplorerRefreshErrorBanner({
    required this.message,
    required this.onRetry,
    required this.onDismiss,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) => SafeArea(
    minimum: const EdgeInsets.all(12),
    child: Material(
      key: const Key('explorer-refresh-error-banner'),
      color: Theme.of(context).colorScheme.errorContainer,
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
        child: Row(
          children: [
            Icon(
              Icons.wifi_off_outlined,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
            IconButton(
              key: const Key('dismiss-refresh-error'),
              onPressed: onDismiss,
              tooltip: 'Dismiss',
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    ),
  );
}
