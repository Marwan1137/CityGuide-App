import 'package:city_guide_app/features/location/domain/entity/location_access.dart';
import 'package:city_guide_app/features/location/presentation/view_model/location_cubit.dart';
import 'package:city_guide_app/features/location/presentation/widgets/location_hero.dart';
import 'package:city_guide_app/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocationStatusView extends StatelessWidget {
  const LocationStatusView({
    required this.access,
    required this.onChooseCity,
    required this.onLocationReady,
    super.key,
  });

  final LocationAccess access;
  final VoidCallback onChooseCity;
  final VoidCallback onLocationReady;

  @override
  Widget build(BuildContext context) {
    final content = _contentFor(access.status);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 48, 24, 28),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_city,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'CityGuide',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 56),
            LocationHero(
              icon: content.icon,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 32),
            Text(
              content.title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            Text(
              content.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              label: content.primaryLabel,
              icon: content.primaryIcon,
              expand: true,
              onPressed: () => _handlePrimary(context, content.action),
            ),
            if (access.status == LocationAccessStatus.reducedAccuracy) ...[
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: context.read<LocationCubit>().openAppSettings,
                icon: const Icon(Icons.tune),
                label: const Text('Improve accuracy in Settings'),
              ),
            ],
            if (content.showCityFallback) ...[
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: onChooseCity,
                icon: const Icon(Icons.search),
                label: const Text('Choose a city instead'),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              'Your precise location is used only to find places around you.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  void _handlePrimary(BuildContext context, _LocationAction action) {
    final cubit = context.read<LocationCubit>();
    switch (action) {
      case _LocationAction.requestPermission:
        cubit.requestPermission();
      case _LocationAction.locate:
        cubit.locateMe();
      case _LocationAction.openAppSettings:
        cubit.openAppSettings();
      case _LocationAction.openLocationSettings:
        cubit.openLocationSettings();
      case _LocationAction.ready:
        onLocationReady();
    }
  }

  _LocationContent _contentFor(LocationAccessStatus status) => switch (status) {
    LocationAccessStatus.notRequested => const _LocationContent(
      icon: Icons.near_me_outlined,
      title: 'Discover what is nearby',
      message:
          'Allow location access to find cafes, restaurants, and pharmacies around you.',
      primaryLabel: 'Use my location',
      primaryIcon: Icons.my_location,
      action: _LocationAction.requestPermission,
    ),
    LocationAccessStatus.denied => const _LocationContent(
      icon: Icons.location_off_outlined,
      title: 'Location access was denied',
      message:
          'CityGuide works best with your location, but you can try again or choose a city.',
      primaryLabel: 'Try location again',
      primaryIcon: Icons.refresh,
      action: _LocationAction.requestPermission,
    ),
    LocationAccessStatus.permanentlyDenied => const _LocationContent(
      icon: Icons.app_settings_alt_outlined,
      title: 'Allow location in Settings',
      message:
          'Location permission is blocked. Open app Settings, allow location while using the app, then return.',
      primaryLabel: 'Open app Settings',
      primaryIcon: Icons.settings_outlined,
      action: _LocationAction.openAppSettings,
    ),
    LocationAccessStatus.servicesDisabled => const _LocationContent(
      icon: Icons.gps_off_outlined,
      title: 'Turn on Location Services',
      message:
          'Your device location service is off. Turn it on, then return to CityGuide.',
      primaryLabel: 'Open location Settings',
      primaryIcon: Icons.gps_fixed,
      action: _LocationAction.openLocationSettings,
    ),
    LocationAccessStatus.reducedAccuracy => _LocationContent(
      icon: Icons.adjust,
      title: access.point == null
          ? 'Approximate location is on'
          : 'Location found',
      message:
          'CityGuide can continue with your approximate location. You can enable precise location in Settings for closer results.',
      primaryLabel: access.point == null ? 'Find nearby places' : 'Continue',
      primaryIcon: Icons.explore_outlined,
      action: access.point == null
          ? _LocationAction.locate
          : _LocationAction.ready,
    ),
    LocationAccessStatus.timedOut => const _LocationContent(
      icon: Icons.timer_off_outlined,
      title: 'Location took too long',
      message:
          'We could not get a GPS fix in time. Move somewhere with a clearer signal and retry.',
      primaryLabel: 'Retry location',
      primaryIcon: Icons.refresh,
      action: _LocationAction.locate,
    ),
    LocationAccessStatus.granted => _LocationContent(
      icon: access.point == null
          ? Icons.location_searching
          : Icons.check_circle_outline,
      title: access.point == null
          ? 'Location access is ready'
          : 'You are ready to explore',
      message: access.point == null
          ? 'CityGuide has permission. Find your current location to start nearby discovery.'
          : 'Your search center is ready. Continue to discover nearby places.',
      primaryLabel: access.point == null ? 'Find my location' : 'Continue',
      primaryIcon: access.point == null
          ? Icons.my_location
          : Icons.arrow_forward,
      action: access.point == null
          ? _LocationAction.locate
          : _LocationAction.ready,
      showCityFallback: access.point == null,
    ),
  };
}

enum _LocationAction {
  requestPermission,
  locate,
  openAppSettings,
  openLocationSettings,
  ready,
}

final class _LocationContent {
  const _LocationContent({
    required this.icon,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.primaryIcon,
    required this.action,
    this.showCityFallback = true,
  });

  final IconData icon;
  final String title;
  final String message;
  final String primaryLabel;
  final IconData primaryIcon;
  final _LocationAction action;
  final bool showCityFallback;
}
