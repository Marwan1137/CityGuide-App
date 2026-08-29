import 'package:city_guide_app/features/explorer/data/model/place_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps all stable nearby place fields', () {
    final model = PlaceModel.fromJson({
      'id': 'place-1',
      'name': 'Cairo Coffee',
      'category': 'cafe',
      'latitude': 30.045,
      'longitude': 31.236,
      'address': 'Downtown Cairo',
      'rating': 4.7,
      'photo_url': 'https://example.com/photo.jpg',
      'distance_meters': 320,
    });

    expect(model.name, 'Cairo Coffee');
    expect(model.rating, 4.7);
    expect(model.distanceMeters, 320);
  });

  test('accepts missing optional provider fields', () {
    final model = PlaceModel.fromJson({
      'id': 'place-2',
      'name': 'Small Cafe',
      'category': 'cafe',
      'latitude': 30,
      'longitude': 31,
    });

    expect(model.address, isNull);
    expect(model.rating, isNull);
    expect(model.photoUrl, isNull);
    expect(model.distanceMeters, isNull);
  });

  test('rejects malformed required fields', () {
    expect(
      () => PlaceModel.fromJson({
        'id': 'place-3',
        'name': '',
        'category': 'cafe',
        'latitude': 30,
        'longitude': 31,
      }),
      throwsFormatException,
    );
  });
}
