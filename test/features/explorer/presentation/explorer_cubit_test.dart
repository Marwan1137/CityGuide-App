import 'package:bloc_test/bloc_test.dart';
import 'package:city_guide_app/core/error/failure.dart';
import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/explorer/domain/entity/nearby_search_request.dart';
import 'package:city_guide_app/features/explorer/domain/repo_contract/nearby_places_repo.dart';
import 'package:city_guide_app/features/explorer/domain/use_cases/search_nearby_places_usecase.dart';
import 'package:city_guide_app/features/explorer/presentation/view_model/explorer_cubit.dart';
import 'package:city_guide_app/features/explorer/presentation/view_model/explorer_state.dart';
import 'package:city_guide_app/shared/domain/geo_point.dart';
import 'package:city_guide_app/shared/domain/place_category.dart';
import 'package:city_guide_app/shared/domain/place_summary.dart';
import 'package:city_guide_app/shared/domain/search_center.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements NearbyPlacesRepo {}

void main() {
  late _MockRepo repo;
  late SearchNearbyPlacesUseCase useCase;

  const center = SearchCenter(
    point: GeoPoint(latitude: 30.0444, longitude: 31.2357),
    source: SearchCenterSource.selectedCity,
    label: 'Cairo',
  );
  const place = PlaceSummary(
    id: 'place-1',
    name: 'Cairo Coffee',
    category: PlaceCategory.cafe,
    location: GeoPoint(latitude: 30.045, longitude: 31.236),
  );

  setUpAll(
    () => registerFallbackValue(
      const NearbySearchRequest(
        center: GeoPoint(latitude: 30.0444, longitude: 31.2357),
      ),
    ),
  );

  setUp(() {
    repo = _MockRepo();
    useCase = SearchNearbyPlacesUseCase(repo);
  });

  blocTest<ExplorerCubit, ExplorerState>(
    'loads cafes and selects the first result',
    build: () {
      when(
        () => repo.searchNearby(any()),
      ).thenAnswer((_) async => const Success([place]));
      return ExplorerCubit(useCase);
    },
    act: (cubit) => cubit.initialize(center),
    expect: () => const [
      ExplorerLoading(),
      ExplorerLoaded(
        searchCenter: center,
        places: [place],
        selectedPlaceId: 'place-1',
      ),
    ],
    verify: (_) => verify(() => repo.searchNearby(any())).called(1),
  );

  blocTest<ExplorerCubit, ExplorerState>(
    'emits a loaded empty outcome instead of an error',
    build: () {
      when(
        () => repo.searchNearby(any()),
      ).thenAnswer((_) async => const Success([]));
      return ExplorerCubit(useCase);
    },
    act: (cubit) => cubit.initialize(center),
    expect: () => const [
      ExplorerLoading(),
      ExplorerLoaded(searchCenter: center, places: []),
    ],
  );

  blocTest<ExplorerCubit, ExplorerState>(
    'maps repository failures into a friendly error state',
    build: () {
      when(() => repo.searchNearby(any())).thenAnswer(
        (_) async => const Error(NetworkFailure('Check your connection.')),
      );
      return ExplorerCubit(useCase);
    },
    act: (cubit) => cubit.initialize(center),
    expect: () => const [
      ExplorerLoading(),
      ExplorerError(searchCenter: center, message: 'Check your connection.'),
    ],
  );

  blocTest<ExplorerCubit, ExplorerState>(
    'changes selection without another nearby request',
    build: () {
      when(
        () => repo.searchNearby(any()),
      ).thenAnswer((_) async => const Success([place]));
      return ExplorerCubit(useCase);
    },
    seed: () => const ExplorerLoaded(searchCenter: center, places: [place]),
    act: (cubit) => cubit.selectPlace('place-1'),
    expect: () => const [
      ExplorerLoaded(
        searchCenter: center,
        places: [place],
        selectedPlaceId: 'place-1',
      ),
    ],
    verify: (_) => verifyNever(() => repo.searchNearby(any())),
  );
}
