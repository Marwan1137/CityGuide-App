import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/location/domain/entity/location_access.dart';

abstract interface class LocationRepo {
  Future<AppResult<LocationAccess>> checkAccess();

  Future<AppResult<LocationAccess>> requestAccess();

  Future<AppResult<LocationAccess>> getCurrentLocation();

  Future<AppResult<bool>> openAppSettings();

  Future<AppResult<bool>> openLocationSettings();
}
