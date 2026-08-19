import 'package:city_guide_app/app/app.dart';
import 'package:city_guide_app/core/config/app_config.dart';
import 'package:city_guide_app/features/home/presentation/pages/home_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('renders the CityGuide application shell', (tester) async {
    await tester.pumpWidget(
      CityGuideApp(
        router: GoRouter(
          routes: [GoRoute(path: '/', builder: (_, _) => const HomePage())],
        ),
        config: const AppConfig(
          environment: AppEnvironment.development,
          apiBaseUrl: '',
          supabaseUrl: '',
          supabasePublishableKey: '',
          enableLogging: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('CityGuide'), findsOneWidget);
    expect(find.text('Discover the city around you'), findsOneWidget);
    expect(find.text('Explore places'), findsOneWidget);
    expect(find.text('Foundation ready'), findsOneWidget);
  });
}
