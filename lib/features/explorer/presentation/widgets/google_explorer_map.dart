import 'package:city_guide_app/features/explorer/presentation/view_model/explorer_state.dart';
import 'package:city_guide_app/shared/domain/place_category.dart';
import 'package:city_guide_app/shared/domain/place_summary.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleExplorerMap extends StatefulWidget {
  const GoogleExplorerMap({
    required this.state,
    required this.onPlaceSelected,
    required this.onZoomChanged,
    super.key,
  });

  final ExplorerLoaded state;
  final ValueChanged<String> onPlaceSelected;
  final ValueChanged<double> onZoomChanged;

  @override
  State<GoogleExplorerMap> createState() => _GoogleExplorerMapState();
}

class _GoogleExplorerMapState extends State<GoogleExplorerMap> {
  late double _latestZoom;

  @override
  void initState() {
    super.initState();
    _latestZoom = widget.state.zoom;
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.state.selectedPlace;
    final center = selected?.location ?? widget.state.searchCenter.point;
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(center.latitude, center.longitude),
        zoom: widget.state.zoom,
      ),
      markers: widget.state.filteredPlaces.map(_marker).toSet(),
      compassEnabled: false,
      mapToolbarEnabled: false,
      myLocationButtonEnabled: false,
      rotateGesturesEnabled: false,
      zoomControlsEnabled: false,
      onCameraMove: (position) => _latestZoom = position.zoom,
      onCameraIdle: () => widget.onZoomChanged(_latestZoom),
    );
  }

  Marker _marker(PlaceSummary place) => Marker(
    markerId: MarkerId(place.id),
    position: LatLng(place.location.latitude, place.location.longitude),
    infoWindow: InfoWindow(title: place.name, snippet: place.address),
    icon: BitmapDescriptor.defaultMarkerWithHue(
      place.id == widget.state.selectedPlaceId
          ? BitmapDescriptor.hueAzure
          : _hue(place.category),
    ),
    onTap: () => widget.onPlaceSelected(place.id),
  );

  double _hue(PlaceCategory category) => switch (category) {
    PlaceCategory.cafe => BitmapDescriptor.hueOrange,
    PlaceCategory.restaurant => BitmapDescriptor.hueRed,
    PlaceCategory.pharmacy => BitmapDescriptor.hueGreen,
    PlaceCategory.custom => BitmapDescriptor.hueViolet,
  };
}
