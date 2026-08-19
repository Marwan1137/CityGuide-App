import 'package:city_guide_app/features/explorer/domain/service/geo_distance_calculator.dart';
import 'package:city_guide_app/shared/domain/geo_point.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('returns zero for the same coordinate', () {
    const point = GeoPoint(latitude: 30.0444, longitude: 31.2357);

    expect(GeoDistanceCalculator.metersBetween(point, point), 0);
  });

  test('calculates Haversine distance across a known latitude delta', () {
    const from = GeoPoint(latitude: 0, longitude: 0);
    const to = GeoPoint(latitude: 1, longitude: 0);

    expect(GeoDistanceCalculator.metersBetween(from, to), closeTo(111195, 2));
  });
}
