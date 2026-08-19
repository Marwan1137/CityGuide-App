import 'package:city_guide_app/features/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract final class AppRoutes {
  static const home = '/';
}

abstract final class AppRouter {
  static GoRouter create() => GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(path: AppRoutes.home, builder: (_, _) => const HomePage()),
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
