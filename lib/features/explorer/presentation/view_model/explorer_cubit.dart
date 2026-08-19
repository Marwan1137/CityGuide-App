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
        !current.places.any((place) => place.id == placeId)) {
      return;
    }
    emit(
      ExplorerLoaded(
        searchCenter: current.searchCenter,
        places: current.places,
        selectedPlaceId: placeId,
        isRefreshing: current.isRefreshing,
      ),
    );
  }

  Future<void> _load(SearchCenter searchCenter) async {
    final result = await _searchNearby(
      NearbySearchRequest(center: searchCenter.point),
    );
    result.fold(
      onSuccess: (places) => emit(
        ExplorerLoaded(
          searchCenter: searchCenter,
          places: places,
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
}
