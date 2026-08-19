import 'package:city_guide_app/core/error/failure.dart';
import 'package:city_guide_app/features/explorer/domain/entity/explorer_filters.dart';
import 'package:city_guide_app/features/explorer/domain/entity/nearby_search_request.dart';
import 'package:city_guide_app/features/explorer/domain/use_cases/load_explorer_filters_usecase.dart';
import 'package:city_guide_app/features/explorer/domain/use_cases/reset_explorer_filters_usecase.dart';
import 'package:city_guide_app/features/explorer/domain/use_cases/save_explorer_filters_usecase.dart';
import 'package:city_guide_app/features/explorer/domain/use_cases/search_nearby_places_usecase.dart';
import 'package:city_guide_app/features/explorer/presentation/view_model/explorer_state.dart';
import 'package:city_guide_app/shared/domain/place_category.dart';
import 'package:city_guide_app/shared/domain/search_center.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class ExplorerCubit extends Cubit<ExplorerState> {
  ExplorerCubit(
    this._searchNearby,
    this._loadFilters,
    this._saveFilters,
    this._resetFilters,
  ) : super(const ExplorerLoading());

  final SearchNearbyPlacesUseCase _searchNearby;
  final LoadExplorerFiltersUseCase _loadFilters;
  final SaveExplorerFiltersUseCase _saveFilters;
  final ResetExplorerFiltersUseCase _resetFilters;
  SearchCenter? _searchCenter;
  ExplorerFilters _filters = const ExplorerFilters();

  Future<void> initialize(SearchCenter searchCenter) async {
    _searchCenter = searchCenter;
    emit(const ExplorerLoading());
    final storedFilters = await _loadFilters();
    _filters = storedFilters.fold(
      onSuccess: (filters) => filters,
      onFailure: (_) => const ExplorerFilters(),
    );
    await _load(searchCenter, _filters);
  }

  Future<void> retry() async {
    final center = _searchCenter;
    if (center == null) return;
    emit(const ExplorerLoading());
    await _load(center, _filters);
  }

  Future<void> changeCategory(PlaceCategory category) async {
    final current = state;
    if (current is! ExplorerLoaded ||
        !ExplorerFilters.supportedCategories.contains(category) ||
        current.filters.category == category ||
        current.isRefreshing) {
      return;
    }
    await _applyFilters(current, current.filters.copyWith(category: category));
  }

  Future<void> changeRadius(int radiusMeters) async {
    final current = state;
    if (current is! ExplorerLoaded ||
        !ExplorerFilters.supportedRadiiMeters.contains(radiusMeters) ||
        current.filters.radiusMeters == radiusMeters ||
        current.isRefreshing) {
      return;
    }
    await _applyFilters(
      current,
      current.filters.copyWith(radiusMeters: radiusMeters),
    );
  }

  Future<void> resetFilters() async {
    final current = state;
    const defaults = ExplorerFilters();
    if (current is! ExplorerLoaded ||
        current.filters == defaults ||
        current.isRefreshing) {
      return;
    }
    _emitLoaded(current, filters: defaults, isRefreshing: true);
    final resetResult = await _resetFilters();
    await resetResult.fold(
      onSuccess: (_) async {
        _filters = defaults;
        await _loadFromExisting(current, defaults);
      },
      onFailure: (failure) async => emit(
        ExplorerError(
          searchCenter: current.searchCenter,
          message: _message(failure),
          filters: current.filters,
        ),
      ),
    );
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

  Future<void> _load(SearchCenter searchCenter, ExplorerFilters filters) async {
    final result = await _searchNearby(
      NearbySearchRequest(
        center: searchCenter.point,
        category: filters.category,
        radiusMeters: filters.radiusMeters,
      ),
    );
    result.fold(
      onSuccess: (places) => emit(
        ExplorerLoaded(
          searchCenter: searchCenter,
          allPlaces: places,
          selectedPlaceId: places.isEmpty ? null : places.first.id,
          filters: filters,
        ),
      ),
      onFailure: (failure) => emit(
        ExplorerError(
          searchCenter: searchCenter,
          message: _message(failure),
          filters: filters,
        ),
      ),
    );
  }

  Future<void> _applyFilters(
    ExplorerLoaded current,
    ExplorerFilters filters,
  ) async {
    _emitLoaded(current, filters: filters, isRefreshing: true);
    final saveResult = await _saveFilters(filters);
    await saveResult.fold(
      onSuccess: (_) async {
        _filters = filters;
        await _loadFromExisting(current, filters);
      },
      onFailure: (failure) async => emit(
        ExplorerError(
          searchCenter: current.searchCenter,
          message: _message(failure),
          filters: current.filters,
        ),
      ),
    );
  }

  Future<void> _loadFromExisting(
    ExplorerLoaded current,
    ExplorerFilters filters,
  ) async {
    final result = await _searchNearby(
      NearbySearchRequest(
        center: current.searchCenter.point,
        category: filters.category,
        radiusMeters: filters.radiusMeters,
      ),
    );
    result.fold(
      onSuccess: (places) => emit(
        ExplorerLoaded(
          searchCenter: current.searchCenter,
          allPlaces: places,
          selectedPlaceId: places.isEmpty ? null : places.first.id,
          viewMode: current.viewMode,
          zoom: current.zoom,
          listScrollOffset: current.listScrollOffset,
          filters: filters,
        ),
      ),
      onFailure: (failure) => emit(
        ExplorerError(
          searchCenter: current.searchCenter,
          message: _message(failure),
          filters: filters,
        ),
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
    ExplorerFilters? filters,
    bool? isRefreshing,
  }) {
    emit(
      ExplorerLoaded(
        searchCenter: current.searchCenter,
        allPlaces: current.allPlaces,
        filteredPlaces: current.filteredPlaces,
        selectedPlaceId: selectedPlaceId ?? current.selectedPlaceId,
        isRefreshing: isRefreshing ?? current.isRefreshing,
        viewMode: viewMode ?? current.viewMode,
        zoom: zoom ?? current.zoom,
        listScrollOffset: listScrollOffset ?? current.listScrollOffset,
        filters: filters ?? current.filters,
      ),
    );
  }
}
