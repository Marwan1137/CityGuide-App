import 'package:city_guide_app/shared/domain/place_summary.dart';
import 'package:city_guide_app/shared/domain/search_center.dart';
import 'package:equatable/equatable.dart';

sealed class ExplorerState extends Equatable {
  const ExplorerState();
}

final class ExplorerLoading extends ExplorerState {
  const ExplorerLoading();

  @override
  List<Object?> get props => [];
}

final class ExplorerLoaded extends ExplorerState {
  const ExplorerLoaded({
    required this.searchCenter,
    required this.places,
    this.selectedPlaceId,
    this.isRefreshing = false,
  });

  final SearchCenter searchCenter;
  final List<PlaceSummary> places;
  final String? selectedPlaceId;
  final bool isRefreshing;

  PlaceSummary? get selectedPlace {
    for (final place in places) {
      if (place.id == selectedPlaceId) return place;
    }
    return null;
  }

  @override
  List<Object?> get props => [
    searchCenter,
    places,
    selectedPlaceId,
    isRefreshing,
  ];
}

final class ExplorerError extends ExplorerState {
  const ExplorerError({required this.searchCenter, required this.message});

  final SearchCenter searchCenter;
  final String message;

  @override
  List<Object?> get props => [searchCenter, message];
}
