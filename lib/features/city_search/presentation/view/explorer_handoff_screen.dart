import 'package:city_guide_app/shared/domain/search_center.dart';
import 'package:flutter/material.dart';

class ExplorerHandoffScreen extends StatelessWidget {
  const ExplorerHandoffScreen({required this.searchCenter, super.key});

  final SearchCenter searchCenter;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Explorer')),
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.map_outlined,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                '${searchCenter.label ?? 'Selected city'} is ready',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              const Text(
                'The SearchCenter was persisted and passed to Explorer. '
                'The real map and nearby places arrive in Feature 3.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
