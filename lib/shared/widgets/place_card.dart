import 'package:city_guide_app/shared/domain/place_summary.dart';
import 'package:city_guide_app/shared/widgets/category_badge.dart';
import 'package:flutter/material.dart';

class PlaceCard extends StatelessWidget {
  const PlaceCard({
    required this.place,
    this.onTap,
    this.selected = false,
    super.key,
  });

  final PlaceSummary place;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) => Card(
    color: selected ? Theme.of(context).colorScheme.primaryContainer : null,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(place.name, style: Theme.of(context).textTheme.titleMedium),
            if (place.address case final address?) ...[
              const SizedBox(height: 4),
              Text(address, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                CategoryBadge(category: place.category),
                const Spacer(),
                if (place.rating case final rating?)
                  Text('★ ${rating.toStringAsFixed(1)}'),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
