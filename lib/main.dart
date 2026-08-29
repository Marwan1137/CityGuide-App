import 'package:city_guide_app/app/app.dart';
import 'package:city_guide_app/bootstrap.dart';
import 'package:city_guide_app/core/di/injection.dart';
import 'package:city_guide_app/core/services/supabase_session_service.dart';

Future<void> main() async {
  await bootstrap(() async {
    configureDependencies();
    await getIt<SupabaseSessionService>().initialize();
    return CityGuideApp();
  });
}
