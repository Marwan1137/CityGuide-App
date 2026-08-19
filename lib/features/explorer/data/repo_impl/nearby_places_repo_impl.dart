import 'package:city_guide_app/core/api/api_result.dart';
import 'package:city_guide_app/core/error/failure.dart';
import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/explorer/data/data_source_contract/nearby_places_datasource.dart';
import 'package:city_guide_app/features/explorer/data/model/nearby_search_request_model.dart';
import 'package:city_guide_app/features/explorer/data/model/place_model.dart';
import 'package:city_guide_app/features/explorer/domain/entity/nearby_search_request.dart';
import 'package:city_guide_app/features/explorer/domain/repo_contract/nearby_places_repo.dart';
import 'package:city_guide_app/features/explorer/domain/service/geo_distance_calculator.dart';
import 'package:city_guide_app/shared/domain/geo_point.dart';
import 'package:city_guide_app/shared/domain/place_category.dart';
import 'package:city_guide_app/shared/domain/place_summary.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: NearbyPlacesRepo)
class NearbyPlacesRepoImpl implements NearbyPlacesRepo {
  const NearbyPlacesRepoImpl(this._datasource);

  final NearbyPlacesDatasource _datasource;

  @override
  Future<AppResult<List<PlaceSummary>>> searchNearby(
    NearbySearchRequest request,
  ) async {
    final result = await _datasource.searchNearby(
      NearbySearchRequestModel.fromEntity(request),
    );
    return result.fold(
      onSuccess: (models) => Success(
        models
            .map((model) => _toEntity(model, request))
            .whereType<PlaceSummary>()
            .where(
              (place) =>
                  (place.distanceMeters ?? double.infinity) <=
                  request.radiusMeters,
            )
            .toList(growable: false),
      ),
      onFailure: (error) => Error(_mapFailure(error)),
    );
  }

  PlaceSummary? _toEntity(PlaceModel model, NearbySearchRequest request) {
    final category = PlaceCategory.values
        .where((value) => value.name == model.category)
        .firstOrNull;
    if (category == null || category == PlaceCategory.custom) return null;
    final location = GeoPoint(
      latitude: model.latitude,
      longitude: model.longitude,
    );
    return PlaceSummary(
      id: model.id,
      name: model.name,
      category: category,
      location: location,
      address: model.address,
      rating: model.rating,
      photoUrl: model.photoUrl,
      distanceMeters: GeoDistanceCalculator.metersBetween(
        request.center,
        location,
      ),
    );
  }

  Failure _mapFailure(ApiError error) => switch (error.type) {
    ApiErrorType.network => NetworkFailure(error.message),
    ApiErrorType.parsing => CacheFailure(error.message),
    ApiErrorType.unauthorized || ApiErrorType.server => ServerFailure(
      error.message,
      code: error.statusCode?.toString(),
    ),
    _ => UnknownFailure(message: error.message),
  };
}
