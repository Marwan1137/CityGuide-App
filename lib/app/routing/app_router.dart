import 'package:city_guide_app/core/di/injection.dart';
import 'package:city_guide_app/features/city_search/presentation/view/city_search_screen.dart';
import 'package:city_guide_app/features/city_search/presentation/view_model/city_search_cubit.dart';
import 'package:city_guide_app/features/custom_places/domain/use_cases/create_custom_place_usecase.dart';
import 'package:city_guide_app/features/custom_places/presentation/view/add_custom_place_screen.dart';
import 'package:city_guide_app/features/custom_places/presentation/view_model/custom_place_form_cubit.dart';
import 'package:city_guide_app/features/directions/domain/use_cases/open_directions_usecase.dart';
import 'package:city_guide_app/features/explorer/presentation/view/explorer_screen.dart';
import 'package:city_guide_app/features/explorer/presentation/view_model/explorer_cubit.dart';
import 'package:city_guide_app/features/favorites/domain/use_cases/toggle_favorite_usecase.dart';
import 'package:city_guide_app/features/favorites/domain/use_cases/watch_is_favorite_usecase.dart';
import 'package:city_guide_app/features/favorites/presentation/view/favorites_screen.dart';
import 'package:city_guide_app/features/favorites/presentation/view_model/favorites_cubit.dart';
import 'package:city_guide_app/features/home/presentation/pages/home_page.dart';
import 'package:city_guide_app/features/location/presentation/view/location_screen.dart';
import 'package:city_guide_app/features/location/presentation/view_model/location_cubit.dart';
import 'package:city_guide_app/features/place_details/domain/use_cases/get_place_detail_usecase.dart';
import 'package:city_guide_app/features/place_details/presentation/view/place_details_screen.dart';
import 'package:city_guide_app/features/place_details/presentation/view_model/place_details_cubit.dart';
import 'package:city_guide_app/shared/domain/geo_point.dart';
import 'package:city_guide_app/shared/domain/place_summary.dart';
import 'package:city_guide_app/shared/domain/search_center.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:city_guide_app/core/network/network_info.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const location = '/location';
  static const citySearch = '/city-search';
  static const explorer = '/explorer';
  static const favorites = '/favorites';
  static const addCustomPlace = '/add-custom-place';
}

abstract final class AppRouter {
  static GoRouter create() => GoRouter(
    initialLocation: AppRoutes.location,
    routes: [
      GoRoute(path: AppRoutes.home, builder: (_, _) => const HomePage()),
      GoRoute(
        path: AppRoutes.location,
        builder: (context, _) => BlocProvider(
          create: (_) => getIt<LocationCubit>()..initialize(),
          child: LocationScreen(
            onChooseCity: () => context.go(AppRoutes.citySearch),
            onLocationReady: (center) =>
                context.go(AppRoutes.explorer, extra: center),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.citySearch,
        builder: (context, _) => BlocProvider(
          create: (_) => getIt<CitySearchCubit>()..initialize(),
          child: CitySearchScreen(
            onRetryDeviceLocation: () => context.go(AppRoutes.location),
            onCenterSelected: (center) =>
                context.go(AppRoutes.explorer, extra: center),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.explorer,
        redirect: (_, state) =>
        state.extra is SearchCenter ? null : AppRoutes.citySearch,
        builder: (context, state) {
          final searchCenter = state.extra! as SearchCenter;
          return BlocProvider(
            create: (_) => getIt<ExplorerCubit>()..initialize(searchCenter),
            child: ExplorerScreen(
              onChooseCity: () => context.go(AppRoutes.citySearch),
            ),
          );
        },
      ),
      GoRoute(
        path: '/place/:id',
        redirect: (_, state) =>
        state.extra is PlaceSummary ? null : AppRoutes.citySearch,
        builder: (context, state) {
          final place = state.extra! as PlaceSummary;
          return BlocProvider(
            create: (_) => PlaceDetailsCubit(
              getIt<OpenDirectionsUseCase>(),
              getIt<GetPlaceDetailUseCase>(),
              getIt<WatchIsFavoriteUseCase>(),
              getIt<ToggleFavoriteUseCase>(),
              getIt<NetworkInfo>(),
              place,
            ),
            child: PlaceDetailsScreen(place: place),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.favorites,
        builder: (context, _) => BlocProvider(
          create: (_) => getIt<FavoritesCubit>(),
          child: FavoritesScreen(
            onDestinationSelected: (index) =>
                _onShellDestinationSelected(context, index),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.addCustomPlace,
        builder: (context, state) {
          final initialLocation = state.extra is GeoPoint
              ? state.extra! as GeoPoint
              : const GeoPoint(latitude: 30.0444, longitude: 31.2357);
          return BlocProvider(
            create: (_) => CustomPlaceFormCubit(
              getIt<CreateCustomPlaceUseCase>(),
              initialLocation,
            ),
            child: const AddCustomPlaceScreen(),
          );
        },
      ),
    ],
    errorBuilder: (_, _) => const _UnknownRoutePage(),
  );
}

void _onShellDestinationSelected(BuildContext context, int index) {
  switch (index) {
    case 0:
      context.go(AppRoutes.explorer);
    case 1:
      context.go(AppRoutes.citySearch);
    case 2:
      context.push(AppRoutes.addCustomPlace);
    case 3:
      context.go(AppRoutes.favorites);
  }
}

class _UnknownRoutePage extends StatelessWidget {
  const _UnknownRoutePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Center(
        child: FilledButton(
          onPressed: () => context.go(AppRoutes.home),
          child: const Text('Return home'),
        ),
      ),
    );
  }
}