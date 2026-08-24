import 'package:city_guide_app/features/explorer/presentation/view_model/explorer_state.dart';
import 'package:city_guide_app/features/explorer/presentation/widgets/explorer_marker_factory.dart';
import 'package:city_guide_app/shared/domain/geo_point.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';

class GoogleExplorerMap extends StatefulWidget {
  const GoogleExplorerMap({
    required this.state,
    required this.onPlaceSelected,
    required this.onCameraIdle,
    super.key,
  });

  final ExplorerLoaded state;
  final ValueChanged<String> onPlaceSelected;
  final void Function(GeoPoint target, double zoom) onCameraIdle;

  @override
  State<GoogleExplorerMap> createState() => _GoogleExplorerMapState();
}

class _GoogleExplorerMapState extends State<GoogleExplorerMap> {
  late double _latestZoom;
  late GeoPoint _latestTarget;
  GoogleMapController? _controller;
  late final ClusterManager _clusterManager;

  @override
  void initState() {
    super.initState();
    _latestZoom = widget.state.zoom;
    _latestTarget = widget.state.searchCenter.point;
    _clusterManager = ClusterManager(
      clusterManagerId: ExplorerMarkerFactory.clusterManagerId,
      onClusterTap: _onClusterTap,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
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
      clusterManagers: {_clusterManager},
      markers: ExplorerMarkerFactory.buildMarkers(
        places: widget.state.allVisiblePlaces,
        selectedPlaceId: widget.state.selectedPlaceId,
        onPlaceSelected: widget.onPlaceSelected,
      ),
      compassEnabled: false,
      mapToolbarEnabled: false,
      myLocationButtonEnabled: false,
      rotateGesturesEnabled: false,
      zoomControlsEnabled: false,
      onMapCreated: (controller) => _controller = controller,
      onCameraMove: (position) {
        _latestZoom = position.zoom;
        _latestTarget = GeoPoint(
          latitude: position.target.latitude,
          longitude: position.target.longitude,
        );
      },
      onCameraIdle: () => widget.onCameraIdle(_latestTarget, _latestZoom),
      onLongPress: (position) => context.push(
        '/add-custom-place',
        extra: GeoPoint(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      ),
    );
  }

  void _onClusterTap(Cluster cluster) {
    _controller?.animateCamera(
      CameraUpdate.newLatLngBounds(cluster.bounds, 56),
    );
  }
}
