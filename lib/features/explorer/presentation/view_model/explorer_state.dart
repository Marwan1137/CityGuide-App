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
    this.customPlaces = const [],
    this.selectedPlaceId,
    this.isRefreshing = false,
    this.viewMode = ExplorerViewMode.map,
    this.zoom = 14,
    this.listScrollOffset = 0,
    this.filters = const ExplorerFilters(),
    this.pendingSearchCenter,
    this.refreshErrorMessage,
  }) : filteredPlaces = filteredPlaces ?? allPlaces;

  final SearchCenter searchCenter;
  final List<PlaceSummary> allPlaces;
  final List<PlaceSummary> filteredPlaces;
  final List<PlaceSummary> customPlaces;
  final String? selectedPlaceId;
  final bool isRefreshing;
  final ExplorerViewMode viewMode;
  final double zoom;
  final double listScrollOffset;
  final ExplorerFilters filters;
  final SearchCenter? pendingSearchCenter;
  final String? refreshErrorMessage;

  bool get canSearchThisArea => pendingSearchCenter != null;

  List<PlaceSummary> get places => filteredPlaces;

  List<PlaceSummary> get allVisiblePlaces => [...filteredPlaces, ...customPlaces];

  PlaceSummary? get selectedPlace {
    for (final place in allVisiblePlaces) {
      if (place.id == selectedPlaceId) return place;
    }
    return null;
  }

  ExplorerLoaded copyWith({
    SearchCenter? searchCenter,
    List<PlaceSummary>? allPlaces,
    List<PlaceSummary>? filteredPlaces,
    List<PlaceSummary>? customPlaces,
    Object? selectedPlaceId = _unchanged,
    bool? isRefreshing,
    ExplorerViewMode? viewMode,
    double? zoom,
    double? listScrollOffset,
    ExplorerFilters? filters,
    Object? pendingSearchCenter = _unchanged,
    Object? refreshErrorMessage = _unchanged,
  }) => ExplorerLoaded(
  searchCenter: searchCenter ?? this.searchCenter,
  allPlaces: allPlaces ?? this.allPlaces,
  filteredPlaces: filteredPlaces ?? this.filteredPlaces,
  customPlaces: customPlaces ?? this.customPlaces,
  selectedPlaceId: identical(selectedPlaceId, _unchanged)
        ? this.selectedPlaceId
        : selectedPlaceId as String?,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    viewMode: viewMode ?? this.viewMode,
    zoom: zoom ?? this.zoom,
    listScrollOffset: listScrollOffset ?? this.listScrollOffset,
    filters: filters ?? this.filters,
    pendingSearchCenter: identical(pendingSearchCenter, _unchanged)
        ? this.pendingSearchCenter
        : pendingSearchCenter as SearchCenter?,
    refreshErrorMessage: identical(refreshErrorMessage, _unchanged)
        ? this.refreshErrorMessage
        : refreshErrorMessage as String?,
  );

  @override
  List<Object?> get props => [
  searchCenter,
  allPlaces,
  filteredPlaces,
  customPlaces,
  selectedPlaceId,
    isRefreshing,
    viewMode,
    zoom,
    listScrollOffset,
    filters,
    pendingSearchCenter,
    refreshErrorMessage,
  ];
}

const _unchanged = Object();

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
