import 'dart:async';

import 'package:city_guide_app/core/di/injection.dart';
import 'package:city_guide_app/core/network/network_info.dart';
import 'package:city_guide_app/shared/widgets/offline_banner.dart';
import 'package:flutter/material.dart';

/// Self-contained banner that listens to [NetworkInfo.status] and shows
/// itself whenever the device goes offline. Drop it at the top of any
/// screen to get live offline messaging without wiring state manually.
class ConnectivityBanner extends StatefulWidget {
  const ConnectivityBanner({super.key});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  final NetworkInfo _networkInfo = getIt<NetworkInfo>();
  late final StreamSubscription<NetworkStatus> _subscription;
  bool _offline = false;

  @override
  void initState() {
    super.initState();
    _networkInfo.isConnected.then((connected) {
      if (mounted) setState(() => _offline = !connected);
    });
    _subscription = _networkInfo.status.listen((status) {
      if (mounted) {
        setState(() => _offline = status == NetworkStatus.offline);
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => OfflineBanner(visible: _offline);
}
