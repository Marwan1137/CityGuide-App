import 'package:city_guide_app/core/error/failure.dart';
import 'package:city_guide_app/features/explorer/domain/entity/nearby_search_request.dart';
import 'package:city_guide_app/features/explorer/domain/use_cases/search_nearby_places_usecase.dart';
import 'package:city_guide_app/features/explorer/presentation/view_model/explorer_state.dart';
import 'package:city_guide_app/shared/domain/search_center.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class ExplorerCubit extends Cubit<ExplorerState> {
  ExplorerCubit(this._searchNearby) : super(const ExplorerLoading());

  final SearchNearbyPlacesUseCase _searchNearby;
  SearchCenter? _searchCenter;

  Future<void> initialize(SearchCenter searchCenter) async {
    _searchCenter = searchCenter;
    emit(const ExplorerLoading());
    await _load(searchCenter);
  }

  Future<void> retry() async {
    final center = _searchCenter;
    if (center == null) return;
    emit(const ExplorerLoading());
    await _load(center);
  }

  void selectPlace(String placeId) {
    final current = state;
    if (current is! ExplorerLoaded ||
        !current.filteredPlaces.any((place) => place.id == placeId)) {
      return;
    }
    _emitLoaded(current, selectedPlaceId: placeId);
  }

  void selectPlaceFromList(String placeId) {
    final current = state;
    if (current is! ExplorerLoaded ||
        !current.filteredPlaces.any((place) => place.id == placeId)) {
      return;
    }
    _emitLoaded(
      current,
      selectedPlaceId: placeId,
      viewMode: ExplorerViewMode.map,
    );
  }

  void changeViewMode(ExplorerViewMode viewMode) {
    final current = state;
    if (current is! ExplorerLoaded || current.viewMode == viewMode) return;
    _emitLoaded(current, viewMode: viewMode);
  }

  void updateZoom(double zoom) {
    final current = state;
    if (current is! ExplorerLoaded || (current.zoom - zoom).abs() < 0.01) {
      return;
    }
    _emitLoaded(current, zoom: zoom);
  }

  void updateListScrollOffset(double offset) {
    final current = state;
    final safeOffset = offset < 0 ? 0.0 : offset;
    if (current is! ExplorerLoaded ||
        (current.listScrollOffset - safeOffset).abs() < 0.5) {
      return;
    }
    _emitLoaded(current, listScrollOffset: safeOffset);
  }

  Future<void> _load(SearchCenter searchCenter) async {
    final result = await _searchNearby(
      NearbySearchRequest(center: searchCenter.point),
    );
    result.fold(
      onSuccess: (places) => emit(
        ExplorerLoaded(
          searchCenter: searchCenter,
          allPlaces: places,
          selectedPlaceId: places.isEmpty ? null : places.first.id,
        ),
      ),
      onFailure: (failure) => emit(
        ExplorerError(searchCenter: searchCenter, message: _message(failure)),
      ),
    );
  }

  String _message(Failure failure) => failure.message.trim().isEmpty
      ? 'Nearby places are unavailable right now. Please try again.'
      : failure.message;

  void _emitLoaded(
    ExplorerLoaded current, {
    String? selectedPlaceId,
    ExplorerViewMode? viewMode,
    double? zoom,
    double? listScrollOffset,
  }) {
    emit(
      ExplorerLoaded(
        searchCenter: current.searchCenter,
        allPlaces: current.allPlaces,
        filteredPlaces: current.filteredPlaces,
        selectedPlaceId: selectedPlaceId ?? current.selectedPlaceId,
        isRefreshing: current.isRefreshing,
        viewMode: viewMode ?? current.viewMode,
        zoom: zoom ?? current.zoom,
        listScrollOffset: listScrollOffset ?? current.listScrollOffset,
      ),
    );
  }
}
