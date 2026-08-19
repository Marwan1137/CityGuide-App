import 'package:city_guide_app/features/explorer/domain/entity/explorer_filters.dart';
import 'package:city_guide_app/shared/domain/place_summary.dart';
import 'package:city_guide_app/shared/domain/search_center.dart';
import 'package:equatable/equatable.dart';

sealed class ExplorerState extends Equatable {
  const ExplorerState();
}

enum ExplorerViewMode { map, list }

final class ExplorerLoading extends ExplorerState {
  const ExplorerLoading();

  @override
  List<Object?> get props => [];
}

final class ExplorerLoaded extends ExplorerState {
  const ExplorerLoaded({
    required this.searchCenter,
    required this.allPlaces,
    List<PlaceSummary>? filteredPlaces,
    this.selectedPlaceId,
    this.isRefreshing = false,
    this.viewMode = ExplorerViewMode.map,
    this.zoom = 14,
    this.listScrollOffset = 0,
    this.filters = const ExplorerFilters(),
  }) : filteredPlaces = filteredPlaces ?? allPlaces;

  final SearchCenter searchCenter;
  final List<PlaceSummary> allPlaces;
  final List<PlaceSummary> filteredPlaces;
  final String? selectedPlaceId;
  final bool isRefreshing;
  final ExplorerViewMode viewMode;
  final double zoom;
  final double listScrollOffset;
  final ExplorerFilters filters;

  List<PlaceSummary> get places => filteredPlaces;

  PlaceSummary? get selectedPlace {
    for (final place in filteredPlaces) {
      if (place.id == selectedPlaceId) return place;
    }
    return null;
  }

  @override
  List<Object?> get props => [
    searchCenter,
    allPlaces,
    filteredPlaces,
    selectedPlaceId,
    isRefreshing,
    viewMode,
    zoom,
    listScrollOffset,
    filters,
  ];
}

final class ExplorerError extends ExplorerState {
  const ExplorerError({
    required this.searchCenter,
    required this.message,
    this.filters = const ExplorerFilters(),
  });

  final SearchCenter searchCenter;
  final String message;
  final ExplorerFilters filters;

  @override
  List<Object?> get props => [searchCenter, message, filters];
}
