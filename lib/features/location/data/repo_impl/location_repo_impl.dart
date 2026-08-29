import 'package:city_guide_app/core/api/api_result.dart';
import 'package:city_guide_app/core/error/failure.dart';
import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/location/data/data_source_contract/location_datasource.dart';
import 'package:city_guide_app/features/location/data/model/location_access_model.dart';
import 'package:city_guide_app/features/location/domain/entity/location_access.dart';
import 'package:city_guide_app/features/location/domain/repo_contract/location_repo.dart';
import 'package:city_guide_app/shared/domain/geo_point.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: LocationRepo)
class LocationRepoImpl implements LocationRepo {
  const LocationRepoImpl(this._datasource);

  final LocationDatasource _datasource;

  @override
  Future<AppResult<LocationAccess>> checkAccess() async =>
      _mapLocation(await _datasource.checkAccess());

  @override
  Future<AppResult<LocationAccess>> requestAccess() async =>
      _mapLocation(await _datasource.requestAccess());

  @override
  Future<AppResult<LocationAccess>> getCurrentLocation() async =>
      _mapLocation(await _datasource.getCurrentLocation());

  @override
  Future<AppResult<bool>> openAppSettings() async =>
      _mapValue(await _datasource.openAppSettings());

  @override
  Future<AppResult<bool>> openLocationSettings() async =>
      _mapValue(await _datasource.openLocationSettings());

  AppResult<LocationAccess> _mapLocation(
    ApiResult<LocationAccessModel> result,
  ) => result.fold(
    onSuccess: (model) => Success(_toEntity(model)),
    onFailure: (error) => Error(_mapFailure(error)),
  );

  AppResult<T> _mapValue<T>(ApiResult<T> result) => result.fold(
    onSuccess: Success.new,
    onFailure: (error) => Error(_mapFailure(error)),
  );

  LocationAccess _toEntity(LocationAccessModel model) => LocationAccess(
    status: switch (model.status) {
      LocationAccessModelStatus.notRequested =>
        LocationAccessStatus.notRequested,
      LocationAccessModelStatus.granted => LocationAccessStatus.granted,
      LocationAccessModelStatus.denied => LocationAccessStatus.denied,
      LocationAccessModelStatus.permanentlyDenied =>
        LocationAccessStatus.permanentlyDenied,
      LocationAccessModelStatus.servicesDisabled =>
        LocationAccessStatus.servicesDisabled,
      LocationAccessModelStatus.reducedAccuracy =>
        LocationAccessStatus.reducedAccuracy,
      LocationAccessModelStatus.timedOut => LocationAccessStatus.timedOut,
    },
    point: model.latitude != null && model.longitude != null
        ? GeoPoint(latitude: model.latitude!, longitude: model.longitude!)
        : null,
    accuracyMeters: model.accuracyMeters,
  );

  Failure _mapFailure(ApiError error) => switch (error.type) {
    ApiErrorType.network => NetworkFailure(error.message),
    ApiErrorType.server || ApiErrorType.unauthorized => ServerFailure(
      error.message,
      code: error.statusCode?.toString(),
    ),
    _ => UnknownFailure(message: error.message),
  };
}
