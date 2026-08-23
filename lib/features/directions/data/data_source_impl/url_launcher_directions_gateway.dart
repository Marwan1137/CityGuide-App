import 'package:city_guide_app/features/directions/data/data_source_contract/directions_launcher_gateway.dart';
import 'package:injectable/injectable.dart';
import 'package:url_launcher/url_launcher.dart';

@LazySingleton(as: DirectionsLauncherGateway)
class UrlLauncherDirectionsGateway implements DirectionsLauncherGateway {
  @override
  Future<bool> launchDirections({
    required double latitude,
    required double longitude,
    required String label,
  }) {
    final uri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': '$latitude,$longitude',
    });
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}