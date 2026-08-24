import 'package:city_guide_app/features/explorer/presentation/view_model/explorer_state.dart';
import 'package:city_guide_app/features/explorer/presentation/widgets/place_quick_preview.dart';
import 'package:city_guide_app/shared/domain/geo_point.dart';
import 'package:city_guide_app/shared/domain/place_category.dart';
import 'package:city_guide_app/shared/widgets/empty_state_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

typedef ExplorerMapBuilder =
    Widget Function(
      BuildContext context,
      ExplorerLoaded state,
      ValueChanged<String> onPlaceSelected,
      void Function(GeoPoint target, double zoom) onCameraIdle,
    );

class ExplorerMapContent extends StatelessWidget {
  const ExplorerMapContent({
    required this.state,
    required this.mapBuilder,
    required this.onPlaceSelected,
    required this.onShowList,
    required this.onCameraIdle,
    required this.onSearchThisArea,
    required this.onOpenFilters,
    required this.onChooseCity,
    super.key,
  });

  final ExplorerLoaded state;
  final ExplorerMapBuilder mapBuilder;
  final ValueChanged<String> onPlaceSelected;
  final VoidCallback onShowList;
  final void Function(GeoPoint target, double zoom) onCameraIdle;
  final VoidCallback onSearchThisArea;
  final VoidCallback onOpenFilters;
  final VoidCallback onChooseCity;

  @override
  Widget build(BuildContext context) {
    final selectedPlace = state.selectedPlace;
    final topInset = MediaQuery.paddingOf(context).top;
    return Stack(
      children: [
        Positioned.fill(
          child: mapBuilder(context, state, onPlaceSelected, onCameraIdle),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: topInset + 64,
          child: _ExplorerHeader(topInset: topInset),
        ),
        if (state.canSearchThisArea)
          Positioned(
            top: topInset + 188,
            left: 0,
            right: 0,
            child: Center(
              child: FilledButton.icon(
                key: const Key('search-this-area-button'),
                onPressed: state.isRefreshing ? null : onSearchThisArea,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Search this area'),
              ),
            ),
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
              _RoundControl(
                icon: Icons.tune,
                tooltip: 'Filter nearby places',
                onPressed: onOpenFilters,
              ),
            ],
          ),
        ),
        Positioned(
          top: topInset + 132,
          left: 16,
          child: _ActiveFilters(state: state),
        ),
        Positioned(
          top: topInset + 132,
          right: 16,
          child: Column(
            children: [
              const _RoundControl(
                icon: Icons.my_location,
                tooltip: 'Current search center',
              ),
              const SizedBox(height: 8),
              _RoundControl(
                icon: Icons.format_list_bulleted,
                tooltip: 'Show list',
                selected: true,
                onPressed: onShowList,
              ),
            ],
          ),
        ),
        if (state.allVisiblePlaces.isEmpty)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.88),
                child: EmptyStateView(
                  title: 'No ${_pluralCategory(state)} found nearby',
                  message:
                      'Try a wider distance, another category, or a different city.',
                  icon: _categoryIcon(state),
                ),
              ),
            ),
          ),
        if (selectedPlace != null)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: PlaceQuickPreview(
              place: selectedPlace,
              onTap: () =>
                  context.go('/place/${selectedPlace.id}', extra: selectedPlace),
            ),
          ),
      ],
    );
  }
}

class _ActiveFilters extends StatelessWidget {
  const _ActiveFilters({required this.state});

  final ExplorerLoaded state;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 6,
    children: [
      Chip(
        visualDensity: VisualDensity.compact,
        label: Text(state.filters.category.label),
      ),
      Chip(
        visualDensity: VisualDensity.compact,
        label: Text('${state.filters.radiusMeters ~/ 1000} km'),
      ),
    ],
  );
}

String _pluralCategory(ExplorerLoaded state) =>
    switch (state.filters.category) {
      PlaceCategory.cafe => 'cafés',
      PlaceCategory.restaurant => 'restaurants',
      PlaceCategory.pharmacy => 'pharmacies',
      PlaceCategory.custom => 'places',
    };

IconData _categoryIcon(ExplorerLoaded state) =>
    switch (state.filters.category) {
      PlaceCategory.cafe => Icons.local_cafe_outlined,
      PlaceCategory.restaurant => Icons.restaurant_outlined,
      PlaceCategory.pharmacy => Icons.local_pharmacy_outlined,
      PlaceCategory.custom => Icons.place_outlined,
    };

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
    this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Material(
      color: selected
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.surface.withValues(alpha: 0.94),
      elevation: 2,
      shape: const CircleBorder(),
      child: InkWell(
        key: selected ? const Key('show-list-button') : null,
        onTap: onPressed,
        customBorder: const CircleBorder(),
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
    ),
  );
}
