import 'package:city_guide_app/core/error/failure.dart';
import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/explorer/domain/entity/nearby_search_request.dart';
import 'package:city_guide_app/features/explorer/domain/repo_contract/nearby_places_repo.dart';
import 'package:city_guide_app/features/explorer/domain/use_cases/search_nearby_places_usecase.dart';
import 'package:city_guide_app/shared/domain/geo_point.dart';
import 'package:city_guide_app/shared/domain/place_category.dart';
import 'package:city_guide_app/shared/domain/place_summary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockNearbyPlacesRepo extends Mock implements NearbyPlacesRepo {}

void main() {
  late _MockNearbyPlacesRepo repo;
  late SearchNearbyPlacesUseCase useCase;

  const center = GeoPoint(latitude: 30.0444, longitude: 31.2357);
  const request = NearbySearchRequest(center: center);

  setUpAll(() => registerFallbackValue(request));

  setUp(() {
    repo = _MockNearbyPlacesRepo();
    useCase = SearchNearbyPlacesUseCase(repo);
  });

  test('uses the default cafe, 3 km, 20-result request', () async {
    when(
      () => repo.searchNearby(any()),
    ).thenAnswer((_) async => const Success(<PlaceSummary>[]));

    await useCase(request);

    final captured =
        verify(() => repo.searchNearby(captureAny())).captured.single
            as NearbySearchRequest;
    expect(captured.category, PlaceCategory.cafe);
    expect(captured.radiusMeters, 3000);
    expect(captured.maxResults, 20);
  });

  test('rejects custom category before reaching the repository', () async {
    final result = await useCase(
      const NearbySearchRequest(center: center, category: PlaceCategory.custom),
    );

    expect(
      (result as Error<List<PlaceSummary>>).failure,
      isA<ValidationFailure>(),
    );
    verifyNever(() => repo.searchNearby(any()));
  });

  test('rejects unsupported radius boundaries and result count', () async {
    final radius = await useCase(
      const NearbySearchRequest(center: center, radiusMeters: 99),
    );
    final unsupportedRadius = await useCase(
      const NearbySearchRequest(center: center, radiusMeters: 2000),
    );
    final count = await useCase(
      const NearbySearchRequest(center: center, maxResults: 21),
    );

    expect(radius, isA<Error<List<PlaceSummary>>>());
    expect(unsupportedRadius, isA<Error<List<PlaceSummary>>>());
    expect(count, isA<Error<List<PlaceSummary>>>());
    verifyNever(() => repo.searchNearby(any()));
  });
}
