import 'dart:math' as math;

import 'package:city_guide_app/shared/domain/geo_point.dart';

abstract final class GeoDistanceCalculator {
  static const _earthRadiusMeters = 6371000.0;

  static double metersBetween(GeoPoint from, GeoPoint to) {
    final latitudeDelta = _radians(to.latitude - from.latitude);
    final longitudeDelta = _radians(to.longitude - from.longitude);
    final fromLatitude = _radians(from.latitude);
    final toLatitude = _radians(to.latitude);
    final haversine =
        math.sin(latitudeDelta / 2) * math.sin(latitudeDelta / 2) +
        math.cos(fromLatitude) *
            math.cos(toLatitude) *
            math.sin(longitudeDelta / 2) *
            math.sin(longitudeDelta / 2);
    return _earthRadiusMeters *
        2 *
        math.atan2(math.sqrt(haversine), math.sqrt(1 - haversine));
  }

  static double _radians(double degrees) => degrees * math.pi / 180;
}
