import 'package:city_guide_app/features/explorer/presentation/view_model/explorer_state.dart';
import 'package:city_guide_app/shared/domain/place_category.dart';
import 'package:city_guide_app/shared/widgets/empty_state_view.dart';
import 'package:city_guide_app/shared/widgets/place_card.dart';
import 'package:flutter/material.dart';

class ExplorerListContent extends StatefulWidget {
  const ExplorerListContent({
    required this.state,
    required this.onPlaceSelected,
    required this.onShowMap,
    required this.onChooseCity,
    required this.onOpenFilters,
    required this.onListScrollOffsetChanged,
    super.key,
  });

  final ExplorerLoaded state;
  final ValueChanged<String> onPlaceSelected;
  final VoidCallback onShowMap;
  final VoidCallback onChooseCity;
  final VoidCallback onOpenFilters;
  final ValueChanged<double> onListScrollOffsetChanged;

  @override
  State<ExplorerListContent> createState() => _ExplorerListContentState();
}

class _ExplorerListContentState extends State<ExplorerListContent> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: widget.state.listScrollOffset,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final places = widget.state.allVisiblePlaces;
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
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
                IconButton.filledTonal(
                  key: const Key('show-map-button'),
                  onPressed: widget.onShowMap,
                  tooltip: 'Show map',
                  icon: const Icon(Icons.map_outlined),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Material(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                key: const Key('explorer-list-search-control'),
                onTap: widget.onChooseCity,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Search ${widget.state.searchCenter.label ?? 'this area'}…',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        key: const Key('explorer-list-filter-button'),
                        onPressed: widget.onOpenFilters,
                        tooltip: 'Filter nearby places',
                        icon: const Icon(Icons.tune, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${places.length} nearby ${_pluralCategory(widget.state)}',
                  key: const Key('explorer-list-count'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  'Within ${widget.state.filters.radiusMeters ~/ 1000} km',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: places.isEmpty
                ? EmptyStateView(
                    title: 'No ${_pluralCategory(widget.state)} found nearby',
                    message:
                        'Try a wider distance, another category, or a different city.',
                    icon: _categoryIcon(widget.state),
                  )
                : NotificationListener<ScrollEndNotification>(
                    onNotification: (_) {
                      widget.onListScrollOffsetChanged(
                        _scrollController.offset,
                      );
                      return false;
                    },
                    child: ListView.separated(
                      key: const PageStorageKey('explorer-place-list'),
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
                      itemCount: places.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final place = places[index];
                        return PlaceCard(
                          key: ValueKey('place-list-card-${place.id}'),
                          place: place,
                          selected: place.id == widget.state.selectedPlaceId,
                          onTap: () => widget.onPlaceSelected(place.id),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
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
