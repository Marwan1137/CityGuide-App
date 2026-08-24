import 'package:flutter/material.dart';

class PlaceWeeklyHours extends StatelessWidget {
  const PlaceWeeklyHours({required this.weeklyHours, super.key});

  final List<String> weeklyHours;

  @override
  Widget build(BuildContext context) {
    if (weeklyHours.isEmpty) return const SizedBox.shrink();

    final todayIndex = DateTime.now().weekday - 1;
    final todayLine = todayIndex >= 0 && todayIndex < weeklyHours.length
        ? weeklyHours[todayIndex]
        : null;
    final todayHours = todayLine != null
        ? todayLine.split(': ').skip(1).join(': ')
        : null;

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      title: Row(
        children: [
          const Icon(Icons.access_time, size: 18),
          const SizedBox(width: 8),
          Text('Today', style: Theme.of(context).textTheme.titleSmall),
          const Spacer(),
          if (todayHours != null) Text(todayHours),
        ],
      ),
      children: weeklyHours.map((line) {
        final parts = line.split(': ');
        final day = parts.first;
        final hours = parts.skip(1).join(': ');
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Text(day, style: Theme.of(context).textTheme.bodyMedium),
              const Spacer(),
              Text(hours, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        );
      }).toList(),
    );
  }
}