import 'package:city_guide_app/core/di/injection.dart';
import 'package:city_guide_app/features/city_search/presentation/view/city_search_screen.dart';
import 'package:city_guide_app/features/city_search/presentation/view_model/city_search_cubit.dart';
import 'package:city_guide_app/features/explorer/presentation/view/explorer_screen.dart';
import 'package:city_guide_app/features/explorer/presentation/view_model/explorer_cubit.dart';
import 'package:city_guide_app/features/home/presentation/pages/home_page.dart';
import 'package:city_guide_app/features/location/presentation/view/location_screen.dart';
import 'package:city_guide_app/features/location/presentation/view_model/location_cubit.dart';
import 'package:city_guide_app/shared/domain/search_center.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const location = '/location';
  static const citySearch = '/city-search';
  static const explorer = '/explorer';
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
    ],
    errorBuilder: (_, _) => const _UnknownRoutePage(),
  );
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
