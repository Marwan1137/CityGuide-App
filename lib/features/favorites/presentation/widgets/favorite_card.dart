import 'package:city_guide_app/features/favorites/domain/entity/favorite.dart';
import 'package:flutter/material.dart';

class FavoriteCard extends StatelessWidget {
  const FavoriteCard({required this.favorite, required this.onTap, super.key});

  final Favorite favorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final place = favorite.place;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: place.photoUrl != null
                    ? Image.network(
                  place.photoUrl!,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 64,
                    height: 64,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.place_outlined),
                  ),
                )
                    : Container(
                  width: 64,
                  height: 64,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.place_outlined),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(place.name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(place.category.label),
                    const SizedBox(height: 4),
                    Text(
                      'Saved ${_relativeDay(favorite.savedAt)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.favorite, color: Colors.blue),
            ],
          ),
        ),
      ),
    );
  }

  String _relativeDay(DateTime savedAt) {
    final now = DateTime.now();
    final saved = DateTime(savedAt.year, savedAt.month, savedAt.day);
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(saved).inDays;
    if (diff == 0) return 'today';
    if (diff == 1) return 'yesterday';
    return '$diff days ago';
  }
}