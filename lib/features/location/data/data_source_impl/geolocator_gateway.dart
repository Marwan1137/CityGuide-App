import 'package:city_guide_app/features/location/data/data_source_contract/location_platform_gateway.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: LocationPlatformGateway)
class GeolocatorGateway implements LocationPlatformGateway {
  @override
  Future<DeviceLocationPermission> checkPermission() async =>
      _mapPermission(await Geolocator.checkPermission());

  @override
  Future<DeviceLocationAccuracy> getAccuracy() async {
    try {
      final status = await Geolocator.getLocationAccuracy();
      return status == LocationAccuracyStatus.reduced
          ? DeviceLocationAccuracy.reduced
          : DeviceLocationAccuracy.precise;
    } on UnimplementedError {
      return DeviceLocationAccuracy.precise;
    } on UnsupportedError {
      return DeviceLocationAccuracy.precise;
    }
  }

  @override
  Future<DevicePosition> getCurrentPosition({required Duration timeout}) async {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: timeout,
      ),
    );
    return DevicePosition(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracyMeters: position.accuracy,
    );
  }

  @override
  Future<bool> isServiceEnabled() => Geolocator.isLocationServiceEnabled();

  @override
  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  @override
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  @override
  Future<DeviceLocationPermission> requestPermission() async =>
      _mapPermission(await Geolocator.requestPermission());

  DeviceLocationPermission _mapPermission(LocationPermission permission) =>
      switch (permission) {
        LocationPermission.denied => DeviceLocationPermission.denied,
        LocationPermission.deniedForever =>
          DeviceLocationPermission.deniedForever,
        LocationPermission.whileInUse ||
        LocationPermission.always => DeviceLocationPermission.granted,
        LocationPermission.unableToDetermine => DeviceLocationPermission.unable,
      };
}
