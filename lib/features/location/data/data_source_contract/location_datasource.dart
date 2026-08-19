import 'package:city_guide_app/core/api/api_result.dart';
import 'package:city_guide_app/features/location/data/model/location_access_model.dart';

abstract interface class LocationDatasource {
  Future<ApiResult<LocationAccessModel>> checkAccess();

  Future<ApiResult<LocationAccessModel>> requestAccess();

  Future<ApiResult<LocationAccessModel>> getCurrentLocation();

  Future<ApiResult<bool>> openAppSettings();

  Future<ApiResult<bool>> openLocationSettings();
}
