import 'package:city_guide_app/shared/domain/place_summary.dart';
import 'package:city_guide_app/shared/widgets/place_card.dart';
import 'package:flutter/material.dart';

class PlaceQuickPreview extends StatelessWidget {
  const PlaceQuickPreview({
    required this.place,
    required this.onTap,
    super.key,
  });

  final PlaceSummary place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Selected nearby place',
    child: PlaceCard(
      key: ValueKey('quick-preview-${place.id}'),
      place: place,
      selected: true,
      onTap: onTap,
    ),
  );
}
