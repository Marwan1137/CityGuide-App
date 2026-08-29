import 'package:city_guide_app/shared/domain/place_category.dart';
import 'package:flutter/material.dart';

class CategoryBadge extends StatelessWidget {
  const CategoryBadge({required this.category, super.key});

  final PlaceCategory category;

  @override
  Widget build(BuildContext context) => Chip(
    avatar: Icon(_icon, size: 17),
    label: Text(category.label),
    visualDensity: VisualDensity.compact,
  );

  IconData get _icon => switch (category) {
    PlaceCategory.cafe => Icons.local_cafe_outlined,
    PlaceCategory.restaurant => Icons.restaurant_outlined,
    PlaceCategory.pharmacy => Icons.local_pharmacy_outlined,
    PlaceCategory.custom => Icons.place_outlined,
  };
}
