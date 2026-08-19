import 'package:city_guide_app/features/location/presentation/view_model/location_cubit.dart';
import 'package:city_guide_app/features/location/presentation/view_model/location_state.dart';
import 'package:city_guide_app/features/location/presentation/widgets/location_status_view.dart';
import 'package:city_guide_app/shared/domain/search_center.dart';
import 'package:city_guide_app/shared/widgets/friendly_error_view.dart';
import 'package:city_guide_app/shared/widgets/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({this.onChooseCity, this.onLocationReady, super.key});

  final VoidCallback? onChooseCity;
  final ValueChanged<SearchCenter>? onLocationReady;

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<LocationCubit>().onAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: BlocBuilder<LocationCubit, LocationState>(
      builder: (context, state) {
        if (state is LocationLoading) {
          return const LoadingView(message: 'Checking location access…');
        }
        if (state is LocationLoaded) {
          return LocationStatusView(
            access: state.access,
            onChooseCity:
                widget.onChooseCity ?? () => _showUpcoming('City search'),
            onLocationReady: () {
              final point = state.access.point;
              if (point == null) return;
              final center = SearchCenter(
                point: point,
                source: SearchCenterSource.device,
                label: 'Current location',
              );
              final onLocationReady = widget.onLocationReady;
              if (onLocationReady != null) {
                onLocationReady(center);
              } else {
                _showUpcoming('Explorer');
              }
            },
          );
        }
        if (state is LocationError) {
          return FriendlyErrorView(
            message: state.message,
            onRetry: context.read<LocationCubit>().retry,
          );
        }
        return const SizedBox.shrink();
      },
    ),
  );

  void _showUpcoming(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature will be connected in its feature branch.'),
      ),
    );
  }
}
