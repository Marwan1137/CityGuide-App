import 'package:city_guide_app/features/explorer/presentation/widgets/explorer_marker_factory.dart';
import 'package:city_guide_app/shared/domain/geo_point.dart';
import 'package:city_guide_app/shared/domain/place_category.dart';
import 'package:city_guide_app/shared/domain/place_summary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  const selectedId = 'place-42';

  test('builds 100 stable markers under the official cluster manager', () {
    final places = List.generate(
      100,
      (index) => PlaceSummary(
        id: 'place-$index',
        name: 'Place $index',
        category: PlaceCategory.values[index % PlaceCategory.values.length],
        location: GeoPoint(
          latitude: 30 + (index * 0.0001),
          longitude: 31 + (index * 0.0001),
        ),
      ),
    );
    String? tappedId;

    final markers = ExplorerMarkerFactory.buildMarkers(
      places: places,
      selectedPlaceId: selectedId,
      onPlaceSelected: (id) => tappedId = id,
    );

    expect(markers, hasLength(100));
    expect(
      markers.map((marker) => marker.markerId.value).toSet(),
      places.map((place) => place.id).toSet(),
    );
    expect(
      markers.every(
        (marker) =>
            marker.clusterManagerId == ExplorerMarkerFactory.clusterManagerId,
      ),
      isTrue,
    );
    final selected = markers.singleWhere(
      (marker) => marker.markerId == const MarkerId(selectedId),
    );
    expect(selected.zIndexInt, 2);
    selected.onTap?.call();
    expect(tappedId, selectedId);
  });

  test('reuses cached category and selected descriptors', () {
    for (final category in PlaceCategory.values) {
      expect(
        identical(
          ExplorerMarkerFactory.descriptorFor(category),
          ExplorerMarkerFactory.descriptorFor(category),
        ),
        isTrue,
      );
    }
    expect(
      identical(
        ExplorerMarkerFactory.descriptorFor(PlaceCategory.cafe, selected: true),
        ExplorerMarkerFactory.descriptorFor(
          PlaceCategory.restaurant,
          selected: true,
        ),
      ),
      isTrue,
    );
  });

  test('uses distinct cafe, restaurant, pharmacy, and custom styles', () {
    final descriptors = PlaceCategory.values
        .map(ExplorerMarkerFactory.descriptorFor)
        .toSet();

    expect(descriptors, hasLength(PlaceCategory.values.length));
  });
}
