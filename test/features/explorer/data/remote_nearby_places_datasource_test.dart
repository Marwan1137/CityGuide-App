import 'dart:async';

import 'package:city_guide_app/core/api/api_manager.dart';
import 'package:city_guide_app/core/api/api_result.dart';
import 'package:city_guide_app/core/config/app_config.dart';
import 'package:city_guide_app/core/services/supabase_session_service.dart';
import 'package:city_guide_app/features/explorer/data/data_source_impl/remote_nearby_places_datasource_impl.dart';
import 'package:city_guide_app/features/explorer/data/model/nearby_search_request_model.dart';
import 'package:city_guide_app/features/explorer/data/model/place_model.dart';
import 'package:city_guide_app/features/explorer/domain/entity/search_request_cancellation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockApiManager extends Mock implements ApiManager {}

class _MockSessionService extends Mock implements SupabaseSessionService {}

void main() {
  late _MockApiManager apiManager;
  late _MockSessionService sessionService;
  late RemoteNearbyPlacesDatasourceImpl datasource;

  const config = AppConfig(
    environment: AppEnvironment.development,
    apiBaseUrl: '',
    supabaseUrl: 'https://example.supabase.co',
    supabasePublishableKey: 'sb_publishable_test',
    enableLogging: false,
  );
  const request = NearbySearchRequestModel(
    latitude: 30.0444,
    longitude: 31.2357,
    category: 'cafe',
    radiusMeters: 3000,
    maxResults: 20,
  );

  setUpAll(() => registerFallbackValue(CancelToken()));

  setUp(() {
    apiManager = _MockApiManager();
    sessionService = _MockSessionService();
    datasource = RemoteNearbyPlacesDatasourceImpl(
      apiManager,
      config,
      sessionService,
    );
    when(
      () => sessionService.getAccessToken(),
    ).thenAnswer((_) async => 'user-jwt');
  });

  test(
    'sends one authenticated stable proxy request and maps places',
    () async {
      when(
        () => apiManager.post(
          any(),
          data: any(named: 'data'),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer(
        (_) async => const ApiSuccess({
          'data': {
            'places': [
              {
                'id': 'place-1',
                'name': 'Cairo Coffee',
                'category': 'cafe',
                'latitude': 30.045,
                'longitude': 31.236,
                'address': 'Downtown Cairo',
                'rating': 4.7,
                'photo_url': null,
                'distance_meters': 320,
              },
            ],
          },
        }),
      );

      final result = await datasource.searchNearby(request);

      expect(
        (result as ApiSuccess<List<PlaceModel>>).data.single.id,
        'place-1',
      );
      verify(
        () => apiManager.post(
          'https://example.supabase.co/functions/v1/places-nearby',
          data: {
            'latitude': 30.0444,
            'longitude': 31.2357,
            'category': 'cafe',
            'radius_meters': 3000,
            'max_results': 20,
          },
          headers: {
            'authorization': 'Bearer user-jwt',
            'apikey': 'sb_publishable_test',
            'content-type': 'application/json',
          },
        ),
      ).called(1);
    },
  );

  test('returns unauthorized without a user session', () async {
    when(() => sessionService.getAccessToken()).thenAnswer((_) async => null);

    final result = await datasource.searchNearby(request);

    expect(result, isA<ApiFailure<List<PlaceModel>>>());
    verifyNever(
      () => apiManager.post(
        any(),
        data: any(named: 'data'),
        headers: any(named: 'headers'),
      ),
    );
  });

  test('maps malformed provider DTO into a parsing failure', () async {
    when(
      () => apiManager.post(
        any(),
        data: any(named: 'data'),
        headers: any(named: 'headers'),
      ),
    ).thenAnswer(
      (_) async => const ApiSuccess({
        'data': {'places': 'invalid'},
      }),
    );

    final result = await datasource.searchNearby(request);

    expect(
      (result as ApiFailure<List<PlaceModel>>).error.type,
      ApiErrorType.parsing,
    );
  });

  test('maps quota and timeout to friendly messages', () async {
    when(
      () => apiManager.post(
        any(),
        data: any(named: 'data'),
        headers: any(named: 'headers'),
      ),
    ).thenAnswer(
      (_) async => const ApiFailure(
        ApiError(type: ApiErrorType.server, message: 'raw', statusCode: 429),
      ),
    );
    final quota = await datasource.searchNearby(request);
    expect(
      (quota as ApiFailure<List<PlaceModel>>).error.message,
      contains('busy'),
    );

    when(
      () => apiManager.post(
        any(),
        data: any(named: 'data'),
        headers: any(named: 'headers'),
      ),
    ).thenAnswer(
      (_) async => const ApiFailure(
        ApiError(type: ApiErrorType.server, message: 'raw', statusCode: 504),
      ),
    );
    final timeout = await datasource.searchNearby(request);
    expect(
      (timeout as ApiFailure<List<PlaceModel>>).error.message,
      contains('too long'),
    );
  });

  test('forwards domain cancellation to the active Dio request', () async {
    when(
      () => apiManager.post(
        any(),
        data: any(named: 'data'),
        headers: any(named: 'headers'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((_) => Completer<ApiResult<Map<String, dynamic>>>().future);
    final cancellation = SearchRequestCancellation();

    unawaited(datasource.searchNearby(request, cancellation: cancellation));
    await Future<void>.delayed(Duration.zero);
    final token =
        verify(
              () => apiManager.post(
                any(),
                data: any(named: 'data'),
                headers: any(named: 'headers'),
                cancelToken: captureAny(named: 'cancelToken'),
              ),
            ).captured.single
            as CancelToken;

    cancellation.cancel();

    expect(token.isCancelled, isTrue);
  });
}
