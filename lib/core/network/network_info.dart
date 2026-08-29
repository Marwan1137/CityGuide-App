enum NetworkStatus { online, offline }

/// Port implemented by the infrastructure layer when networking is introduced.
abstract interface class NetworkInfo {
  Future<bool> get isConnected;

  Stream<NetworkStatus> get status;
}
