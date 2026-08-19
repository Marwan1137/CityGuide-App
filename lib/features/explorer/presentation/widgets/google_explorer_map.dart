import 'package:city_guide_app/features/explorer/presentation/view_model/explorer_state.dart';
import 'package:city_guide_app/shared/domain/place_category.dart';
import 'package:city_guide_app/shared/domain/place_summary.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleExplorerMap extends StatelessWidget {
  const GoogleExplorerMap({
    required this.state,
    required this.onPlaceSelected,
    super.key,
  });

  final ExplorerLoaded state;
  final ValueChanged<String> onPlaceSelected;

  @override
  Widget build(BuildContext context) {
    final center = state.searchCenter.point;
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(center.latitude, center.longitude),
        zoom: 14,
      ),
      markers: state.places.map(_marker).toSet(),
      compassEnabled: false,
      mapToolbarEnabled: false,
      myLocationButtonEnabled: false,
      rotateGesturesEnabled: false,
      zoomControlsEnabled: false,
    );
  }

  Marker _marker(PlaceSummary place) => Marker(
    markerId: MarkerId(place.id),
    position: LatLng(place.location.latitude, place.location.longitude),
    infoWindow: InfoWindow(title: place.name, snippet: place.address),
    icon: BitmapDescriptor.defaultMarkerWithHue(
      place.id == state.selectedPlaceId
          ? BitmapDescriptor.hueAzure
          : _hue(place.category),
    ),
    onTap: () => onPlaceSelected(place.id),
  );

  double _hue(PlaceCategory category) => switch (category) {
    PlaceCategory.cafe => BitmapDescriptor.hueOrange,
    PlaceCategory.restaurant => BitmapDescriptor.hueRed,
    PlaceCategory.pharmacy => BitmapDescriptor.hueGreen,
    PlaceCategory.custom => BitmapDescriptor.hueViolet,
  };
}
