import 'package:flutter/material.dart';

class LocationHero extends StatelessWidget {
  const LocationHero({required this.icon, required this.color, super.key});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      shape: BoxShape.circle,
    ),
    child: Padding(
      padding: const EdgeInsets.all(30),
      child: Icon(icon, size: 66, color: color),
    ),
  );
}
