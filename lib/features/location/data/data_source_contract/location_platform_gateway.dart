enum DeviceLocationPermission { denied, deniedForever, granted, unable }

enum DeviceLocationAccuracy { precise, reduced }

final class DevicePosition {
  const DevicePosition({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
  });

  final double latitude;
  final double longitude;
  final double accuracyMeters;
}

abstract interface class LocationPlatformGateway {
  Future<bool> isServiceEnabled();

  Future<DeviceLocationPermission> checkPermission();

  Future<DeviceLocationPermission> requestPermission();

  Future<DeviceLocationAccuracy> getAccuracy();

  Future<DevicePosition> getCurrentPosition({required Duration timeout});

  Future<bool> openAppSettings();

  Future<bool> openLocationSettings();
}

abstract interface class PermissionRequestStore {
  Future<bool> wasRequested();

  Future<void> markRequested();
}
