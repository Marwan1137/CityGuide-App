import 'dart:async';

import 'package:city_guide_app/core/api/api_executor.dart';
import 'package:city_guide_app/core/api/api_result.dart';
import 'package:city_guide_app/features/location/data/data_source_contract/location_platform_gateway.dart';
import 'package:city_guide_app/features/location/data/data_source_impl/geolocator_location_datasource.dart';
import 'package:city_guide_app/features/location/data/model/location_access_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLocationPlatformGateway extends Mock
    implements LocationPlatformGateway {}

class _MockPermissionRequestStore extends Mock
    implements PermissionRequestStore {}

void main() {
  late _MockLocationPlatformGateway gateway;
  late _MockPermissionRequestStore store;
  late GeolocatorLocationDatasource datasource;

  setUp(() {
    gateway = _MockLocationPlatformGateway();
    store = _MockPermissionRequestStore();
    datasource = GeolocatorLocationDatasource(
      const ApiExecutor(),
      gateway,
      store,
    );

    when(() => gateway.isServiceEnabled()).thenAnswer((_) async => true);
    when(
      () => gateway.checkPermission(),
    ).thenAnswer((_) async => DeviceLocationPermission.granted);
    when(
      () => gateway.getAccuracy(),
    ).thenAnswer((_) async => DeviceLocationAccuracy.precise);
    when(() => store.wasRequested()).thenAnswer((_) async => false);
    when(() => store.markRequested()).thenAnswer((_) async {});
  });

  test('returns services disabled as a recoverable outcome', () async {
    when(() => gateway.isServiceEnabled()).thenAnswer((_) async => false);

    final model = _success(await datasource.checkAccess());

    expect(model.status, LocationAccessModelStatus.servicesDisabled);
  });

  test('distinguishes a first request from a previous denial', () async {
    when(
      () => gateway.checkPermission(),
    ).thenAnswer((_) async => DeviceLocationPermission.denied);

    expect(
      _success(await datasource.checkAccess()).status,
      LocationAccessModelStatus.notRequested,
    );

    when(() => store.wasRequested()).thenAnswer((_) async => true);
    expect(
      _success(await datasource.checkAccess()).status,
      LocationAccessModelStatus.denied,
    );
  });

  test('returns permanently denied without throwing', () async {
    when(
      () => gateway.checkPermission(),
    ).thenAnswer((_) async => DeviceLocationPermission.deniedForever);

    expect(
      _success(await datasource.checkAccess()).status,
      LocationAccessModelStatus.permanentlyDenied,
    );
  });

  test('returns reduced accuracy without treating it as an error', () async {
    when(
      () => gateway.getAccuracy(),
    ).thenAnswer((_) async => DeviceLocationAccuracy.reduced);

    expect(
      _success(await datasource.checkAccess()).status,
      LocationAccessModelStatus.reducedAccuracy,
    );
  });

  test('returns granted permission', () async {
    expect(
      _success(await datasource.checkAccess()).status,
      LocationAccessModelStatus.granted,
    );
  });

  test(
    'marks permission requested before invoking the system prompt',
    () async {
      when(
        () => gateway.requestPermission(),
      ).thenAnswer((_) async => DeviceLocationPermission.denied);

      final model = _success(await datasource.requestAccess());

      expect(model.status, LocationAccessModelStatus.denied);
      verifyInOrder([
        () => store.markRequested(),
        () => gateway.requestPermission(),
      ]);
    },
  );

  test('maps a GPS timeout to a recoverable loaded outcome', () async {
    when(
      () => gateway.getCurrentPosition(timeout: const Duration(seconds: 12)),
    ).thenThrow(TimeoutException('GPS timeout'));

    final model = _success(await datasource.getCurrentLocation());

    expect(model.status, LocationAccessModelStatus.timedOut);
  });

  test('returns the current position and measured accuracy', () async {
    when(
      () => gateway.getCurrentPosition(timeout: const Duration(seconds: 12)),
    ).thenAnswer(
      (_) async => const DevicePosition(
        latitude: 30.0444,
        longitude: 31.2357,
        accuracyMeters: 6,
      ),
    );

    final model = _success(await datasource.getCurrentLocation());

    expect(model.latitude, 30.0444);
    expect(model.longitude, 31.2357);
    expect(model.accuracyMeters, 6);
  });
}

LocationAccessModel _success(ApiResult<LocationAccessModel> result) {
  expect(result, isA<ApiSuccess<LocationAccessModel>>());
  return (result as ApiSuccess<LocationAccessModel>).data;
}
