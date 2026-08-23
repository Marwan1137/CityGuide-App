import 'package:flutter/material.dart';

class DirectionsButton extends StatelessWidget {
  const DirectionsButton({
    required this.isLoading,
    required this.onPressed,
    super.key,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: isLoading ? null : onPressed,
    icon: isLoading
        ? const SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(strokeWidth: 2),
    )
        : const Icon(Icons.directions),
    label: const Text('Directions'),
  );
}