import 'package:city_guide_app/app/routing/app_router.dart';
import 'package:city_guide_app/core/config/app_config.dart';
import 'package:city_guide_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CityGuideApp extends StatelessWidget {
  CityGuideApp({AppConfig? config, super.key})
    : config = config ?? AppConfig.fromEnvironment();

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: config.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
