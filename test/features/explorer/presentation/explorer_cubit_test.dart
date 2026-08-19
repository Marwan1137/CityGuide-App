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
  const secondPlace = PlaceSummary(
    id: 'place-2',
    name: 'Nile Brew',
    category: PlaceCategory.cafe,
    location: GeoPoint(latitude: 30.046, longitude: 31.237),
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
        allPlaces: [place],
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
      ExplorerLoaded(searchCenter: center, allPlaces: []),
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
    seed: () => const ExplorerLoaded(searchCenter: center, allPlaces: [place]),
    act: (cubit) => cubit.selectPlace('place-1'),
    expect: () => const [
      ExplorerLoaded(
        searchCenter: center,
        allPlaces: [place],
        selectedPlaceId: 'place-1',
      ),
    ],
    verify: (_) => verifyNever(() => repo.searchNearby(any())),
  );

  blocTest<ExplorerCubit, ExplorerState>(
    'switches map and list without another nearby request',
    build: () => ExplorerCubit(useCase),
    seed: () => const ExplorerLoaded(
      searchCenter: center,
      allPlaces: [place, secondPlace],
      selectedPlaceId: 'place-1',
    ),
    act: (cubit) {
      cubit.changeViewMode(ExplorerViewMode.list);
      cubit.changeViewMode(ExplorerViewMode.map);
    },
    expect: () => const [
      ExplorerLoaded(
        searchCenter: center,
        allPlaces: [place, secondPlace],
        selectedPlaceId: 'place-1',
        viewMode: ExplorerViewMode.list,
      ),
      ExplorerLoaded(
        searchCenter: center,
        allPlaces: [place, secondPlace],
        selectedPlaceId: 'place-1',
      ),
    ],
    verify: (_) => verifyNever(() => repo.searchNearby(any())),
  );

  blocTest<ExplorerCubit, ExplorerState>(
    'list card selection returns to map and preserves explorer context',
    build: () => ExplorerCubit(useCase),
    seed: () => const ExplorerLoaded(
      searchCenter: center,
      allPlaces: [place, secondPlace],
      filteredPlaces: [place, secondPlace],
      selectedPlaceId: 'place-1',
      viewMode: ExplorerViewMode.list,
      zoom: 15.5,
      listScrollOffset: 128,
    ),
    act: (cubit) => cubit.selectPlaceFromList('place-2'),
    expect: () => const [
      ExplorerLoaded(
        searchCenter: center,
        allPlaces: [place, secondPlace],
        filteredPlaces: [place, secondPlace],
        selectedPlaceId: 'place-2',
        zoom: 15.5,
        listScrollOffset: 128,
      ),
    ],
    verify: (_) => verifyNever(() => repo.searchNearby(any())),
  );

  blocTest<ExplorerCubit, ExplorerState>(
    'keeps identical filtered IDs while preserving zoom and list position',
    build: () => ExplorerCubit(useCase),
    seed: () => const ExplorerLoaded(
      searchCenter: center,
      allPlaces: [place, secondPlace],
      filteredPlaces: [secondPlace],
      selectedPlaceId: 'place-2',
    ),
    act: (cubit) {
      cubit.updateZoom(16);
      cubit.updateListScrollOffset(84);
    },
    expect: () => const [
      ExplorerLoaded(
        searchCenter: center,
        allPlaces: [place, secondPlace],
        filteredPlaces: [secondPlace],
        selectedPlaceId: 'place-2',
        zoom: 16,
      ),
      ExplorerLoaded(
        searchCenter: center,
        allPlaces: [place, secondPlace],
        filteredPlaces: [secondPlace],
        selectedPlaceId: 'place-2',
        zoom: 16,
        listScrollOffset: 84,
      ),
    ],
  );

  blocTest<ExplorerCubit, ExplorerState>(
    'marker selection remains selected after switching to the list',
    build: () => ExplorerCubit(useCase),
    seed: () => const ExplorerLoaded(
      searchCenter: center,
      allPlaces: [place, secondPlace],
      selectedPlaceId: 'place-1',
      zoom: 15,
    ),
    act: (cubit) {
      cubit.selectPlace('place-2');
      cubit.changeViewMode(ExplorerViewMode.list);
    },
    expect: () => const [
      ExplorerLoaded(
        searchCenter: center,
        allPlaces: [place, secondPlace],
        selectedPlaceId: 'place-2',
        zoom: 15,
      ),
      ExplorerLoaded(
        searchCenter: center,
        allPlaces: [place, secondPlace],
        selectedPlaceId: 'place-2',
        viewMode: ExplorerViewMode.list,
        zoom: 15,
      ),
    ],
    verify: (_) => verifyNever(() => repo.searchNearby(any())),
  );
}
