import 'package:city_guide_app/core/di/injection.dart';
import 'package:city_guide_app/features/home/presentation/pages/home_page.dart';
import 'package:city_guide_app/features/location/presentation/view/location_screen.dart';
import 'package:city_guide_app/features/location/presentation/view_model/location_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const location = '/location';
}

abstract final class AppRouter {
  static GoRouter create() => GoRouter(
    initialLocation: AppRoutes.location,
    routes: [
      GoRoute(path: AppRoutes.home, builder: (_, _) => const HomePage()),
      GoRoute(
        path: AppRoutes.location,
        builder: (_, _) => BlocProvider(
          create: (_) => getIt<LocationCubit>()..initialize(),
          child: const LocationScreen(),
        ),
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
