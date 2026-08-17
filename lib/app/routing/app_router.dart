import 'package:city_guide_app/features/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';

abstract final class AppRoutes {
  static const home = '/';
}

abstract final class AppRouter {
  static Route<void> onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      AppRoutes.home => MaterialPageRoute<void>(
        builder: (_) => const HomePage(),
        settings: settings,
      ),
      _ => MaterialPageRoute<void>(
        builder: (_) => const _UnknownRoutePage(),
        settings: settings,
      ),
    };
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
          onPressed: () => Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false),
          child: const Text('Return home'),
        ),
      ),
    );
  }
}
