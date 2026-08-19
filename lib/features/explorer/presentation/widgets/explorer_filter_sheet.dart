import 'package:city_guide_app/features/explorer/domain/entity/explorer_filters.dart';
import 'package:city_guide_app/shared/domain/place_category.dart';
import 'package:flutter/material.dart';

class ExplorerFilterSheet extends StatelessWidget {
  const ExplorerFilterSheet({
    required this.filters,
    required this.onCategorySelected,
    required this.onRadiusSelected,
    required this.onReset,
    super.key,
  });

  final ExplorerFilters filters;
  final ValueChanged<PlaceCategory> onCategorySelected;
  final ValueChanged<int> onRadiusSelected;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Filter nearby places',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                TextButton(
                  key: const Key('reset-explorer-filters'),
                  onPressed: () {
                    Navigator.pop(context);
                    onReset();
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text('Category', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ExplorerFilters.supportedCategories
                  .map(
                    (category) => ChoiceChip(
                      key: ValueKey('category-${category.name}'),
                      label: Text(category.label),
                      selected: filters.category == category,
                      avatar: Icon(_categoryIcon(category), size: 18),
                      onSelected: (selected) {
                        if (!selected) return;
                        Navigator.pop(context);
                        onCategorySelected(category);
                      },
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: 24),
            Text(
              'Distance from search center',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ExplorerFilters.supportedRadiiMeters
                  .map(
                    (radius) => ChoiceChip(
                      key: ValueKey('radius-$radius'),
                      label: Text('${radius ~/ 1000} km'),
                      selected: filters.radiusMeters == radius,
                      onSelected: (selected) {
                        if (!selected) return;
                        Navigator.pop(context);
                        onRadiusSelected(radius);
                      },
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: 18),
            Text(
              'Choose one option at a time. Results refresh once after each accepted change.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  IconData _categoryIcon(PlaceCategory category) => switch (category) {
    PlaceCategory.cafe => Icons.local_cafe_outlined,
    PlaceCategory.restaurant => Icons.restaurant_outlined,
    PlaceCategory.pharmacy => Icons.local_pharmacy_outlined,
    PlaceCategory.custom => Icons.add_location_alt_outlined,
  };
}
