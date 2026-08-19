import 'package:city_guide_app/core/api/api_result.dart';
import 'package:city_guide_app/core/error/failure.dart';
import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/explorer/data/data_source_contract/nearby_places_datasource.dart';
import 'package:city_guide_app/features/explorer/data/model/nearby_search_request_model.dart';
import 'package:city_guide_app/features/explorer/data/model/place_model.dart';
import 'package:city_guide_app/features/explorer/data/repo_impl/nearby_places_repo_impl.dart';
import 'package:city_guide_app/features/explorer/domain/entity/nearby_search_request.dart';
import 'package:city_guide_app/shared/domain/geo_point.dart';
import 'package:city_guide_app/shared/domain/place_category.dart';
import 'package:city_guide_app/shared/domain/place_summary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDatasource extends Mock implements NearbyPlacesDatasource {}

void main() {
  late _MockDatasource datasource;
  late NearbyPlacesRepoImpl repo;

  const request = NearbySearchRequest(
    center: GeoPoint(latitude: 30.0444, longitude: 31.2357),
  );

  setUpAll(
    () => registerFallbackValue(
      const NearbySearchRequestModel(
        latitude: 0,
        longitude: 0,
        category: 'cafe',
        radiusMeters: 3000,
        maxResults: 20,
      ),
    ),
  );

  setUp(() {
    datasource = _MockDatasource();
    repo = NearbyPlacesRepoImpl(datasource);
  });

  test('maps DTOs into domain PlaceSummary entities', () async {
    when(() => datasource.searchNearby(any())).thenAnswer(
      (_) async => const ApiSuccess([
        PlaceModel(
          id: 'place-1',
          name: 'Cairo Coffee',
          category: 'cafe',
          latitude: 30.045,
          longitude: 31.236,
          rating: 4.7,
        ),
      ]),
    );

    final result = await repo.searchNearby(request);
    final place = (result as Success<List<PlaceSummary>>).data.single;

    expect(place.category, PlaceCategory.cafe);
    expect(place.location.latitude, 30.045);
  });

  test(
    'maps data-source failures without leaking ApiError to domain',
    () async {
      when(() => datasource.searchNearby(any())).thenAnswer(
        (_) async => const ApiFailure(
          ApiError(type: ApiErrorType.network, message: 'offline'),
        ),
      );

      final result = await repo.searchNearby(request);

      expect(
        (result as Error<List<PlaceSummary>>).failure,
        isA<NetworkFailure>(),
      );
    },
  );
}
