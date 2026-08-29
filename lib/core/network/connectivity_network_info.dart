import 'package:city_guide_app/core/network/network_info.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: NetworkInfo)
class ConnectivityNetworkInfo implements NetworkInfo {
  ConnectivityNetworkInfo(this._connectivity);

  final Connectivity _connectivity;

  @override
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return _hasConnection(results);
  }

  @override
  Stream<NetworkStatus> get status => _connectivity.onConnectivityChanged.map(
        (results) =>
    _hasConnection(results) ? NetworkStatus.online : NetworkStatus.offline,
  );

  bool _hasConnection(List<ConnectivityResult> results) =>
      results.any((result) => result != ConnectivityResult.none);
}