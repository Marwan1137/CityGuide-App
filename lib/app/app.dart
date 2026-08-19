import 'package:city_guide_app/app/routing/app_router.dart';
import 'package:city_guide_app/core/config/app_config.dart';
import 'package:city_guide_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CityGuideApp extends StatelessWidget {
  CityGuideApp({AppConfig? config, GoRouter? router, super.key})
    : config = config ?? AppConfig.fromEnvironment(),
      router = router ?? AppRouter.create();

  final AppConfig config;
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: config.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
