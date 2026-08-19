import 'package:city_guide_app/features/explorer/presentation/view_model/explorer_state.dart';
import 'package:city_guide_app/shared/widgets/empty_state_view.dart';
import 'package:city_guide_app/shared/widgets/place_card.dart';
import 'package:flutter/material.dart';

typedef ExplorerMapBuilder =
    Widget Function(
      BuildContext context,
      ExplorerLoaded state,
      ValueChanged<String> onPlaceSelected,
    );

class ExplorerMapContent extends StatelessWidget {
  const ExplorerMapContent({
    required this.state,
    required this.mapBuilder,
    required this.onPlaceSelected,
    required this.onChooseCity,
    super.key,
  });

  final ExplorerLoaded state;
  final ExplorerMapBuilder mapBuilder;
  final ValueChanged<String> onPlaceSelected;
  final VoidCallback onChooseCity;

  @override
  Widget build(BuildContext context) {
    final selectedPlace = state.selectedPlace;
    final topInset = MediaQuery.paddingOf(context).top;
    return Stack(
      children: [
        Positioned.fill(child: mapBuilder(context, state, onPlaceSelected)),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: topInset + 64,
          child: _ExplorerHeader(topInset: topInset),
        ),
        Positioned(
          top: topInset + 76,
          left: 16,
          right: 16,
          child: Row(
            children: [
              Expanded(
                child: _MapControl(
                  key: const Key('explorer-search-control'),
                  icon: Icons.search,
                  label: 'Search ${state.searchCenter.label ?? 'this area'}…',
                  onPressed: onChooseCity,
                ),
              ),
              const SizedBox(width: 8),
              const _RoundControl(
                icon: Icons.tune,
                tooltip: 'Filters arrive in Feature 5',
              ),
            ],
          ),
        ),
        Positioned(
          top: topInset + 132,
          right: 16,
          child: Column(
            children: const [
              _RoundControl(
                icon: Icons.my_location,
                tooltip: 'Current search center',
              ),
              SizedBox(height: 8),
              _RoundControl(
                icon: Icons.format_list_bulleted,
                tooltip: 'List view arrives in Feature 4',
                selected: true,
              ),
            ],
          ),
        ),
        if (state.places.isEmpty)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.88),
                child: const EmptyStateView(
                  title: 'No cafes found nearby',
                  message:
                      'Try another city now, or adjust category and distance when filters are available.',
                  icon: Icons.local_cafe_outlined,
                ),
              ),
            ),
          ),
        if (selectedPlace != null)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Semantics(
              label: 'Selected nearby place',
              child: PlaceCard(
                place: selectedPlace,
                selected: true,
                onTap: () => onPlaceSelected(selectedPlace.id),
              ),
            ),
          ),
      ],
    );
  }
}

class _ExplorerHeader extends StatelessWidget {
  const _ExplorerHeader({required this.topInset});

  final double topInset;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.88),
    child: Padding(
      padding: EdgeInsets.fromLTRB(16, topInset, 16, 0),
      child: Row(
        children: [
          Icon(
            Icons.explore,
            size: 32,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Text('Explorer', style: Theme.of(context).textTheme.titleLarge),
          const Spacer(),
          const CircleAvatar(
            radius: 17,
            child: Icon(Icons.person_outline, size: 20),
          ),
        ],
      ),
    ),
  );
}

class _MapControl extends StatelessWidget {
  const _MapControl({
    required this.icon,
    required this.label,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.94),
    elevation: 2,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    ),
  );
}

class _RoundControl extends StatelessWidget {
  const _RoundControl({
    required this.icon,
    required this.tooltip,
    this.selected = false,
  });

  final IconData icon;
  final String tooltip;
  final bool selected;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Material(
      color: selected
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.surface.withValues(alpha: 0.94),
      elevation: 2,
      shape: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Icon(
          icon,
          size: 21,
          color: selected
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
    ),
  );
}
