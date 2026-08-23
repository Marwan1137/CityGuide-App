import 'package:city_guide_app/core/api/api_result.dart';
import 'package:city_guide_app/core/error/failure.dart';
import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/place_details/data/data_source_contract/place_details_datasource.dart';
import 'package:city_guide_app/features/place_details/data/model/place_detail_model.dart';
import 'package:city_guide_app/features/place_details/domain/entity/place_detail.dart';
import 'package:city_guide_app/features/place_details/domain/repo_contract/place_details_repo.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: PlaceDetailsRepo)
class PlaceDetailsRepoImpl implements PlaceDetailsRepo {
  const PlaceDetailsRepoImpl(this._datasource);

  final PlaceDetailsDatasource _datasource;

  @override
  Future<AppResult<PlaceDetail>> getPlaceDetail(String placeId) async {
    final result = await _datasource.getPlaceDetail(placeId);
    return result.fold(
      onSuccess: (model) => Success(_toEntity(model)),
      onFailure: (error) => Error(_mapFailure(error)),
    );
  }

  PlaceDetail _toEntity(PlaceDetailModel model) => PlaceDetail(
    id: model.id,
    priceLevel: model.priceLevel,
    openNow: model.openNow,
    nextCloseTime: model.nextCloseTime,
    weeklyHours: model.weeklyHours,
    photos: model.photos
        .map(
          (photo) =>
          PlaceDetailPhoto(url: photo.url, attribution: photo.attribution),
    )
        .toList(growable: false),
  );

  Failure _mapFailure(ApiError error) => switch (error.type) {
    ApiErrorType.network => NetworkFailure(error.message),
    ApiErrorType.timeout => TimeoutFailure(error.message),
    ApiErrorType.quota => QuotaFailure(
      error.message,
      code: error.statusCode?.toString(),
    ),
    ApiErrorType.server || ApiErrorType.unauthorized => ServerFailure(
      error.message,
      code: error.statusCode?.toString(),
    ),
    _ => UnknownFailure(message: error.message),
  };
}