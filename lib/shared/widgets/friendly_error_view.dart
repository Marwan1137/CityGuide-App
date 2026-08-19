import 'package:city_guide_app/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class FriendlyErrorView extends StatelessWidget {
  const FriendlyErrorView({
    required this.message,
    this.onRetry,
    this.title = 'We hit a small detour',
    super.key,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 56,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 20),
            PrimaryButton(label: 'Try again', onPressed: onRetry),
          ],
        ],
      ),
    ),
  );
}
