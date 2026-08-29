import 'dart:async';

import 'package:city_guide_app/core/api/api_executor.dart';
import 'package:city_guide_app/core/api/api_result.dart';
import 'package:city_guide_app/features/location/data/data_source_contract/location_datasource.dart';
import 'package:city_guide_app/features/location/data/data_source_contract/location_platform_gateway.dart';
import 'package:city_guide_app/features/location/data/model/location_access_model.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: LocationDatasource)
class GeolocatorLocationDatasource implements LocationDatasource {
  GeolocatorLocationDatasource(this._executor, this._gateway, this._store);

  static const _locationTimeout = Duration(seconds: 12);

  final ApiExecutor _executor;
  final LocationPlatformGateway _gateway;
  final PermissionRequestStore _store;

  @override
  Future<ApiResult<LocationAccessModel>> checkAccess() =>
      _executor.execute(_checkAccess);

  @override
  Future<ApiResult<LocationAccessModel>> requestAccess() =>
      _executor.execute(() async {
        if (!await _gateway.isServiceEnabled()) {
          return const LocationAccessModel(
            status: LocationAccessModelStatus.servicesDisabled,
          );
        }

        await _store.markRequested();
        final permission = await _gateway.requestPermission();
        return _modelForPermission(permission);
      });

  @override
  Future<ApiResult<LocationAccessModel>> getCurrentLocation() =>
      _executor.execute(() async {
        final access = await _checkAccess();
        if (access.status != LocationAccessModelStatus.granted &&
            access.status != LocationAccessModelStatus.reducedAccuracy) {
          return access;
        }

        try {
          final position = await _gateway.getCurrentPosition(
            timeout: _locationTimeout,
          );
          final accuracyStatus = await _gateway.getAccuracy();
          return LocationAccessModel(
            status: accuracyStatus == DeviceLocationAccuracy.reduced
                ? LocationAccessModelStatus.reducedAccuracy
                : LocationAccessModelStatus.granted,
            latitude: position.latitude,
            longitude: position.longitude,
            accuracyMeters: position.accuracyMeters,
          );
        } on TimeoutException {
          return const LocationAccessModel(
            status: LocationAccessModelStatus.timedOut,
          );
        }
      });

  @override
  Future<ApiResult<bool>> openAppSettings() =>
      _executor.execute(_gateway.openAppSettings);

  @override
  Future<ApiResult<bool>> openLocationSettings() =>
      _executor.execute(_gateway.openLocationSettings);

  Future<LocationAccessModel> _checkAccess() async {
    if (!await _gateway.isServiceEnabled()) {
      return const LocationAccessModel(
        status: LocationAccessModelStatus.servicesDisabled,
      );
    }

    final permission = await _gateway.checkPermission();
    if (permission == DeviceLocationPermission.denied) {
      final wasRequested = await _store.wasRequested();
      return LocationAccessModel(
        status: wasRequested
            ? LocationAccessModelStatus.denied
            : LocationAccessModelStatus.notRequested,
      );
    }
    return _modelForPermission(permission);
  }

  Future<LocationAccessModel> _modelForPermission(
    DeviceLocationPermission permission,
  ) async {
    if (permission == DeviceLocationPermission.deniedForever) {
      return const LocationAccessModel(
        status: LocationAccessModelStatus.permanentlyDenied,
      );
    }
    if (permission == DeviceLocationPermission.denied ||
        permission == DeviceLocationPermission.unable) {
      return const LocationAccessModel(
        status: LocationAccessModelStatus.denied,
      );
    }

    final accuracyStatus = await _gateway.getAccuracy();
    return LocationAccessModel(
      status: accuracyStatus == DeviceLocationAccuracy.reduced
          ? LocationAccessModelStatus.reducedAccuracy
          : LocationAccessModelStatus.granted,
    );
  }
}
