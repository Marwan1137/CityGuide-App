import 'dart:async';

import 'package:city_guide_app/core/network/network_info.dart';
import 'package:city_guide_app/features/directions/domain/use_cases/open_directions_usecase.dart';
import 'package:city_guide_app/features/favorites/domain/use_cases/toggle_favorite_usecase.dart';
import 'package:city_guide_app/features/favorites/domain/use_cases/watch_is_favorite_usecase.dart';
import 'package:city_guide_app/features/place_details/domain/use_cases/get_place_detail_usecase.dart';
import 'package:city_guide_app/features/place_details/presentation/view_model/place_details_state.dart';
import 'package:city_guide_app/shared/domain/place_summary.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';

import 'package:city_guide_app/core/error/failure.dart';

class PlaceDetailsCubit extends Cubit<PlaceDetailsState> {
  PlaceDetailsCubit(
      this._openDirections,
      this._getPlaceDetail,
      this._watchIsFavorite,
      this._toggleFavorite,
      this._networkInfo,
      PlaceSummary place,
      ) : super(PlaceDetailsState(place: place)) {
    _loadDetail();
    _favoriteSubscription = _watchIsFavorite(place.id).listen(
          (isFavorite) => emit(state.copyWith(isFavorite: isFavorite)),
    );
  }

  final OpenDirectionsUseCase _openDirections;
  final GetPlaceDetailUseCase _getPlaceDetail;
  final WatchIsFavoriteUseCase _watchIsFavorite;
  final ToggleFavoriteUseCase _toggleFavorite;
  final NetworkInfo _networkInfo;
  late final StreamSubscription<bool> _favoriteSubscription;

  static const _maxAutoRetries = 2;

  Future<void> _loadDetail({int attempt = 0}) async {
    emit(state.copyWith(isLoadingDetail: true, detailErrorMessage: null));
    if (!await _networkInfo.isConnected) {
      emit(
        state.copyWith(
          isLoadingDetail: false,
          detailErrorMessage: "You're offline. Showing saved details.",
        ),
      );
      return;
    }
    final result = await _getPlaceDetail(state.place.id);
    await result.fold(
      onSuccess: (detail) async => emit(
        state.copyWith(
          placeDetail: detail,
          isLoadingDetail: false,
          lastDetailUpdatedAt: DateTime.now(),
        ),
      ),
      onFailure: (failure) async {
        final isTransient = failure is NetworkFailure || failure is TimeoutFailure;
        if (isTransient && attempt < _maxAutoRetries) {
          final backoff = Duration(
            milliseconds: (500 * (1 << attempt)) + Random().nextInt(300),
          );
          await Future<void>.delayed(backoff);
          if (isClosed) return;
          await _loadDetail(attempt: attempt + 1);
          return;
        }
        emit(
          state.copyWith(
            isLoadingDetail: false,
            detailErrorMessage: failure is QuotaFailure
                ? failure.message
                : failure.message,
          ),
        );
      },
    );
  }

  Future<void> retryLoadDetail() => _loadDetail();

  Future<void> openDirections() async {
    emit(
      state.copyWith(isLaunchingDirections: true, directionsErrorMessage: null),
    );
    if (!await _networkInfo.isConnected) {
      emit(
        state.copyWith(
          isLaunchingDirections: false,
          directionsErrorMessage:
          "You're offline. Connect to the internet to get directions.",
        ),
      );
      return;
    }
    final result = await _openDirections(state.place);
    result.fold(
      onSuccess: (_) => emit(state.copyWith(isLaunchingDirections: false)),
      onFailure: (failure) => emit(
        state.copyWith(
          isLaunchingDirections: false,
          directionsErrorMessage: failure.message,
        ),
      ),
    );
  }

  Future<void> toggleFavorite() {
    final detailPhotos = state.placeDetail?.photos ?? const [];
    final photoUrl = detailPhotos.isNotEmpty
        ? detailPhotos.first.url
        : state.place.photoUrl;
    final placeToSave = photoUrl == state.place.photoUrl
        ? state.place
        : PlaceSummary(
      id: state.place.id,
      name: state.place.name,
      category: state.place.category,
      location: state.place.location,
      address: state.place.address,
      rating: state.place.rating,
      photoUrl: photoUrl,
      distanceMeters: state.place.distanceMeters,
    );
    return _toggleFavorite(placeToSave, isFavorite: state.isFavorite);
  }

  @override
  Future<void> close() {
    _favoriteSubscription.cancel();
    return super.close();
  }
}