import 'package:city_guide_app/shared/domain/place_category.dart';
import 'package:city_guide_app/shared/domain/place_summary.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract final class ExplorerMarkerFactory {
  static const clusterManagerId = ClusterManagerId('cityguide-places');

  static final Map<PlaceCategory, BitmapDescriptor> _categoryDescriptors = {
    PlaceCategory.cafe: BitmapDescriptor.defaultMarkerWithHue(20),
    PlaceCategory.restaurant: BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueOrange,
    ),
    PlaceCategory.pharmacy: BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueGreen,
    ),
    PlaceCategory.custom: BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueViolet,
    ),
  };

  static final BitmapDescriptor _selectedDescriptor =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);

  static Set<Marker> buildMarkers({
    required List<PlaceSummary> places,
    required String? selectedPlaceId,
    required ValueChanged<String> onPlaceSelected,
  }) {
    final stopwatch = Stopwatch()..start();
    final markers = places
        .map(
          (place) => Marker(
            markerId: MarkerId(place.id),
            clusterManagerId: clusterManagerId,
            position: LatLng(place.location.latitude, place.location.longitude),
            infoWindow: InfoWindow(title: place.name, snippet: place.address),
            icon: place.id == selectedPlaceId
                ? _selectedDescriptor
                : _categoryDescriptors[place.category]!,
            zIndexInt: place.id == selectedPlaceId ? 2 : 1,
            onTap: () => onPlaceSelected(place.id),
          ),
        )
        .toSet();
    stopwatch.stop();
    _logMarkerBuild(markers.length, stopwatch.elapsedMicroseconds);
    return markers;
  }

  @visibleForTesting
  static BitmapDescriptor descriptorFor(
    PlaceCategory category, {
    bool selected = false,
  }) => selected ? _selectedDescriptor : _categoryDescriptors[category]!;

  static void _logMarkerBuild(int markerCount, int elapsedMicroseconds) {
    if (kReleaseMode) return;
    debugPrint(
      'ExplorerMap marker_count=$markerCount '
      'build_us=$elapsedMicroseconds',
    );
  }
}
