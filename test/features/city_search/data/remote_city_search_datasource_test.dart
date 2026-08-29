import 'package:city_guide_app/core/api/api_manager.dart';
import 'package:city_guide_app/core/api/api_result.dart';
import 'package:city_guide_app/core/config/app_config.dart';
import 'package:city_guide_app/core/services/supabase_session_service.dart';
import 'package:city_guide_app/features/city_search/data/data_source_impl/remote_city_search_datasource_impl.dart';
import 'package:city_guide_app/features/city_search/data/model/city_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockApiManager extends Mock implements ApiManager {}

class _MockSupabaseSessionService extends Mock
    implements SupabaseSessionService {}

void main() {
  late _MockApiManager apiManager;
  late _MockSupabaseSessionService sessionService;
  late RemoteCitySearchDatasourceImpl datasource;

  const config = AppConfig(
    environment: AppEnvironment.development,
    apiBaseUrl: '',
    supabaseUrl: 'https://example.supabase.co',
    supabasePublishableKey: 'sb_publishable_test',
    enableLogging: false,
  );

  setUp(() {
    apiManager = _MockApiManager();
    sessionService = _MockSupabaseSessionService();
    datasource = RemoteCitySearchDatasourceImpl(
      apiManager,
      config,
      sessionService,
    );
    when(
      () => sessionService.getAccessToken(),
    ).thenAnswer((_) async => 'user-jwt');
  });

  test('maps the stable Edge Function DTO', () async {
    when(
      () => apiManager.post(
        any(),
        data: any(named: 'data'),
        headers: any(named: 'headers'),
      ),
    ).thenAnswer(
      (_) async => const ApiSuccess({
        'data': {
          'id': 'google:zamalek',
          'name_en': 'Zamalek',
          'name_ar': 'الزمالك',
          'governorate_en': 'Cairo Governorate',
          'governorate_ar': '',
          'latitude': 30.0626,
          'longitude': 31.2197,
          'aliases': <String>[],
          'is_remote_result': true,
        },
      }),
    );

    final result = await datasource.geocode('Zamalek');
    final city = (result as ApiSuccess<CityModel>).data;

    expect(city.nameEn, 'Zamalek');
    expect(city.isRemoteResult, isTrue);
    verify(
      () => apiManager.post(
        'https://example.supabase.co/functions/v1/geocode-city',
        data: {'query': 'Zamalek'},
        headers: {
          'authorization': 'Bearer user-jwt',
          'apikey': 'sb_publishable_test',
          'content-type': 'application/json',
        },
      ),
    ).called(1);
  });

  test('does not call the function without an authenticated session', () async {
    when(() => sessionService.getAccessToken()).thenAnswer((_) async => null);

    final result = await datasource.geocode('Zamalek');

    expect(result, isA<ApiFailure<CityModel>>());
    verifyNever(
      () => apiManager.post(
        any(),
        data: any(named: 'data'),
        headers: any(named: 'headers'),
      ),
    );
  });

  test('maps quota and timeout responses to friendly errors', () async {
    when(
      () => apiManager.post(
        any(),
        data: any(named: 'data'),
        headers: any(named: 'headers'),
      ),
    ).thenAnswer(
      (_) async => const ApiFailure(
        ApiError(
          type: ApiErrorType.server,
          message: 'provider error',
          statusCode: 429,
        ),
      ),
    );

    final quota = await datasource.geocode('Zamalek');
    expect((quota as ApiFailure<CityModel>).error.message, contains('busy'));

    when(
      () => apiManager.post(
        any(),
        data: any(named: 'data'),
        headers: any(named: 'headers'),
      ),
    ).thenAnswer(
      (_) async => const ApiFailure(
        ApiError(
          type: ApiErrorType.server,
          message: 'provider error',
          statusCode: 504,
        ),
      ),
    );

    final timeout = await datasource.geocode('Zamalek');
    expect(
      (timeout as ApiFailure<CityModel>).error.message,
      contains('too long'),
    );
  });
}
