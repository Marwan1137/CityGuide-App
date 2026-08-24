abstract interface class DirectionsLauncherGateway {
  Future<bool> launchDirections({
    required double latitude,
    required double longitude,
    required String label,
  });
}