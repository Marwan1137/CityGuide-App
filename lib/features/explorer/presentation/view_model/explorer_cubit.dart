import 'package:city_guide_app/core/error/failure.dart';
import 'package:city_guide_app/features/explorer/domain/entity/explorer_filters.dart';
import 'package:city_guide_app/features/explorer/domain/entity/nearby_search_request.dart';
import 'package:city_guide_app/features/explorer/domain/entity/search_request_cancellation.dart';
import 'package:city_guide_app/features/explorer/domain/service/geo_distance_calculator.dart';
import 'package:city_guide_app/features/explorer/domain/use_cases/load_explorer_filters_usecase.dart';
import 'package:city_guide_app/features/explorer/domain/use_cases/reset_explorer_filters_usecase.dart';
import 'package:city_guide_app/features/explorer/domain/use_cases/save_explorer_filters_usecase.dart';
import 'package:city_guide_app/features/explorer/domain/use_cases/search_nearby_places_usecase.dart';
import 'package:city_guide_app/features/explorer/presentation/view_model/explorer_state.dart';
import 'package:city_guide_app/shared/domain/geo_point.dart';
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
  SearchRequestCancellation? _activeCancellation;
  int _requestSequence = 0;

  static const double _searchAreaThresholdMeters = 150;

  Future<void> initialize(SearchCenter searchCenter) async {
    final sequence = _invalidateRequests();
    _searchCenter = searchCenter;
    emit(const ExplorerLoading());
    final storedFilters = await _loadFilters();
    if (!_isCurrent(sequence)) return;
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
        current.filters.category == category) {
      return;
    }
    await _applyFilters(current, current.filters.copyWith(category: category));
  }

  Future<void> changeRadius(int radiusMeters) async {
    final current = state;
    if (current is! ExplorerLoaded ||
        !ExplorerFilters.supportedRadiiMeters.contains(radiusMeters) ||
        current.filters.radiusMeters == radiusMeters) {
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
    if (current is! ExplorerLoaded || current.filters == defaults) {
      return;
    }
    final request = _beginRequest();
    emit(
      current.copyWith(
        filters: defaults,
        isRefreshing: true,
        refreshErrorMessage: null,
      ),
    );
    final resetResult = await _resetFilters();
    if (!_isCurrent(request.sequence)) return;
    await resetResult.fold(
      onSuccess: (_) async {
        _filters = defaults;
        await _loadFromExisting(current, defaults, request: request);
      },
      onFailure: (failure) async => emit(
        current.copyWith(
          isRefreshing: false,
          refreshErrorMessage: _message(failure),
        ),
      ),
    );
  }

  void onCameraIdle(GeoPoint target, double zoom) {
    final current = state;
    if (current is! ExplorerLoaded) return;
    final movedMeters = GeoDistanceCalculator.metersBetween(
      current.searchCenter.point,
      target,
    );
    emit(
      current.copyWith(
        zoom: zoom,
        pendingSearchCenter: movedMeters >= _searchAreaThresholdMeters
            ? SearchCenter(
                point: target,
                source: SearchCenterSource.map,
                label: 'this map area',
              )
            : null,
      ),
    );
  }

  Future<void> searchThisArea() async {
    final current = state;
    final pendingCenter = current is ExplorerLoaded
        ? current.pendingSearchCenter
        : null;
    if (current is! ExplorerLoaded || pendingCenter == null) return;
    await _refresh(
      current,
      center: pendingCenter,
      filters: current.filters,
      acceptCenterOnSuccess: true,
    );
  }

  Future<void> retryRefresh() async {
    final current = state;
    if (current is! ExplorerLoaded) return;
    final pendingCenter = current.pendingSearchCenter;
    await _refresh(
      current,
      center: pendingCenter ?? current.searchCenter,
      filters: current.filters,
      acceptCenterOnSuccess: pendingCenter != null,
    );
  }

  void dismissRefreshError() {
    final current = state;
    if (current is! ExplorerLoaded || current.refreshErrorMessage == null) {
      return;
    }
    emit(current.copyWith(refreshErrorMessage: null));
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
    final request = _beginRequest();
    final result = await _searchNearby(
      NearbySearchRequest(
        center: searchCenter.point,
        category: filters.category,
        radiusMeters: filters.radiusMeters,
        cancellation: request.cancellation,
      ),
    );
    if (!_isCurrent(request.sequence)) return;
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
    final request = _beginRequest();
    emit(
      current.copyWith(
        filters: filters,
        isRefreshing: true,
        refreshErrorMessage: null,
      ),
    );
    final saveResult = await _saveFilters(filters);
    if (!_isCurrent(request.sequence)) return;
    await saveResult.fold(
      onSuccess: (_) async {
        _filters = filters;
        await _loadFromExisting(current, filters, request: request);
      },
      onFailure: (failure) async => emit(
        current.copyWith(
          isRefreshing: false,
          refreshErrorMessage: _message(failure),
        ),
      ),
    );
  }

  Future<void> _loadFromExisting(
    ExplorerLoaded current,
    ExplorerFilters filters, {
    required ({int sequence, SearchRequestCancellation cancellation}) request,
  }) async {
    final result = await _searchNearby(
      NearbySearchRequest(
        center: current.searchCenter.point,
        category: filters.category,
        radiusMeters: filters.radiusMeters,
        cancellation: request.cancellation,
      ),
    );
    if (!_isCurrent(request.sequence)) return;
    result.fold(
      onSuccess: (places) => emit(
        current.copyWith(
          allPlaces: places,
          filteredPlaces: places,
          selectedPlaceId: places.isEmpty ? null : places.first.id,
          filters: filters,
          isRefreshing: false,
          refreshErrorMessage: null,
        ),
      ),
      onFailure: (failure) => emit(
        current.copyWith(
          filters: filters,
          isRefreshing: false,
          refreshErrorMessage: _message(failure),
        ),
      ),
    );
  }

  Future<void> _refresh(
    ExplorerLoaded current, {
    required SearchCenter center,
    required ExplorerFilters filters,
    required bool acceptCenterOnSuccess,
  }) async {
    final request = _beginRequest();
    emit(current.copyWith(isRefreshing: true, refreshErrorMessage: null));
    final result = await _searchNearby(
      NearbySearchRequest(
        center: center.point,
        category: filters.category,
        radiusMeters: filters.radiusMeters,
        cancellation: request.cancellation,
      ),
    );
    if (!_isCurrent(request.sequence)) return;
    result.fold(
      onSuccess: (places) {
        if (acceptCenterOnSuccess) _searchCenter = center;
        emit(
          current.copyWith(
            searchCenter: acceptCenterOnSuccess ? center : current.searchCenter,
            allPlaces: places,
            filteredPlaces: places,
            selectedPlaceId: places.isEmpty ? null : places.first.id,
            filters: filters,
            isRefreshing: false,
            pendingSearchCenter: acceptCenterOnSuccess
                ? null
                : current.pendingSearchCenter,
            refreshErrorMessage: null,
          ),
        );
      },
      onFailure: (failure) => emit(
        current.copyWith(
          filters: filters,
          isRefreshing: false,
          refreshErrorMessage: _message(failure),
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
      current.copyWith(
        selectedPlaceId: selectedPlaceId ?? current.selectedPlaceId,
        isRefreshing: isRefreshing,
        viewMode: viewMode,
        zoom: zoom,
        listScrollOffset: listScrollOffset,
        filters: filters,
      ),
    );
  }

  ({int sequence, SearchRequestCancellation cancellation}) _beginRequest() {
    final sequence = _invalidateRequests();
    final cancellation = SearchRequestCancellation();
    _activeCancellation = cancellation;
    return (sequence: sequence, cancellation: cancellation);
  }

  int _invalidateRequests() {
    _activeCancellation?.cancel();
    _activeCancellation = null;
    return ++_requestSequence;
  }

  bool _isCurrent(int sequence) => !isClosed && sequence == _requestSequence;

  @override
  Future<void> close() {
    _invalidateRequests();
    return super.close();
  }
}
