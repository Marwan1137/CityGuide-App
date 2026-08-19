import 'package:bloc_test/bloc_test.dart';
import 'package:city_guide_app/core/error/failure.dart';
import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/explorer/domain/entity/explorer_filters.dart';
import 'package:city_guide_app/features/explorer/domain/entity/nearby_search_request.dart';
import 'package:city_guide_app/features/explorer/domain/repo_contract/explorer_filter_preferences_repo.dart';
import 'package:city_guide_app/features/explorer/domain/repo_contract/nearby_places_repo.dart';
import 'package:city_guide_app/features/explorer/domain/use_cases/load_explorer_filters_usecase.dart';
import 'package:city_guide_app/features/explorer/domain/use_cases/reset_explorer_filters_usecase.dart';
import 'package:city_guide_app/features/explorer/domain/use_cases/save_explorer_filters_usecase.dart';
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

class _MockFilterPreferencesRepo extends Mock
    implements ExplorerFilterPreferencesRepo {}

void main() {
  late _MockRepo repo;
  late SearchNearbyPlacesUseCase useCase;
  late _MockFilterPreferencesRepo filterRepo;
  late LoadExplorerFiltersUseCase loadFilters;
  late SaveExplorerFiltersUseCase saveFilters;
  late ResetExplorerFiltersUseCase resetFilters;

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
  const restaurant = PlaceSummary(
    id: 'restaurant-1',
    name: 'Cairo Table',
    category: PlaceCategory.restaurant,
    location: GeoPoint(latitude: 30.0455, longitude: 31.2365),
  );

  setUpAll(() {
    registerFallbackValue(const ExplorerFilters());
    registerFallbackValue(
      const NearbySearchRequest(
        center: GeoPoint(latitude: 30.0444, longitude: 31.2357),
      ),
    );
  });

  setUp(() {
    repo = _MockRepo();
    useCase = SearchNearbyPlacesUseCase(repo);
    filterRepo = _MockFilterPreferencesRepo();
    loadFilters = LoadExplorerFiltersUseCase(filterRepo);
    saveFilters = SaveExplorerFiltersUseCase(filterRepo);
    resetFilters = ResetExplorerFiltersUseCase(filterRepo);
    when(
      () => filterRepo.load(),
    ).thenAnswer((_) async => const Success(ExplorerFilters()));
    when(
      () => filterRepo.save(any()),
    ).thenAnswer((_) async => const Success(null));
    when(() => filterRepo.reset()).thenAnswer((_) async => const Success(null));
  });

  ExplorerCubit buildCubit() =>
      ExplorerCubit(useCase, loadFilters, saveFilters, resetFilters);

  blocTest<ExplorerCubit, ExplorerState>(
    'loads cafes and selects the first result',
    build: () {
      when(
        () => repo.searchNearby(any()),
      ).thenAnswer((_) async => const Success([place]));
      return buildCubit();
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
      return buildCubit();
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
      return buildCubit();
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
      return buildCubit();
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
    build: buildCubit,
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
    build: buildCubit,
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
    build: buildCubit,
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
    build: buildCubit,
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

  blocTest<ExplorerCubit, ExplorerState>(
    'loads persisted filters before the initial nearby request',
    build: () {
      when(() => filterRepo.load()).thenAnswer(
        (_) async => const Success(
          ExplorerFilters(
            category: PlaceCategory.restaurant,
            radiusMeters: 5000,
          ),
        ),
      );
      when(
        () => repo.searchNearby(any()),
      ).thenAnswer((_) async => const Success([restaurant]));
      return buildCubit();
    },
    act: (cubit) => cubit.initialize(center),
    expect: () => const [
      ExplorerLoading(),
      ExplorerLoaded(
        searchCenter: center,
        allPlaces: [restaurant],
        selectedPlaceId: 'restaurant-1',
        filters: ExplorerFilters(
          category: PlaceCategory.restaurant,
          radiusMeters: 5000,
        ),
      ),
    ],
    verify: (_) {
      final request =
          verify(() => repo.searchNearby(captureAny())).captured.single
              as NearbySearchRequest;
      expect(request.category, PlaceCategory.restaurant);
      expect(request.radiusMeters, 5000);
    },
  );

  blocTest<ExplorerCubit, ExplorerState>(
    'category change persists and makes exactly one accepted request',
    build: () {
      when(
        () => repo.searchNearby(any()),
      ).thenAnswer((_) async => const Success([restaurant]));
      return buildCubit();
    },
    seed: () => const ExplorerLoaded(
      searchCenter: center,
      allPlaces: [place],
      selectedPlaceId: 'place-1',
      zoom: 15,
    ),
    act: (cubit) => cubit.changeCategory(PlaceCategory.restaurant),
    expect: () => const [
      ExplorerLoaded(
        searchCenter: center,
        allPlaces: [place],
        selectedPlaceId: 'place-1',
        isRefreshing: true,
        zoom: 15,
        filters: ExplorerFilters(category: PlaceCategory.restaurant),
      ),
      ExplorerLoaded(
        searchCenter: center,
        allPlaces: [restaurant],
        selectedPlaceId: 'restaurant-1',
        zoom: 15,
        filters: ExplorerFilters(category: PlaceCategory.restaurant),
      ),
    ],
    verify: (_) {
      verify(
        () => filterRepo.save(
          const ExplorerFilters(category: PlaceCategory.restaurant),
        ),
      ).called(1);
      final request =
          verify(() => repo.searchNearby(captureAny())).captured.single
              as NearbySearchRequest;
      expect(request.category, PlaceCategory.restaurant);
      expect(request.radiusMeters, 3000);
    },
  );

  blocTest<ExplorerCubit, ExplorerState>(
    'radius change makes one request and duplicate change makes none',
    build: () {
      when(
        () => repo.searchNearby(any()),
      ).thenAnswer((_) async => const Success([place]));
      return buildCubit();
    },
    seed: () => const ExplorerLoaded(searchCenter: center, allPlaces: [place]),
    act: (cubit) async {
      await cubit.changeRadius(5000);
      await cubit.changeRadius(5000);
    },
    expect: () => const [
      ExplorerLoaded(
        searchCenter: center,
        allPlaces: [place],
        isRefreshing: true,
        filters: ExplorerFilters(radiusMeters: 5000),
      ),
      ExplorerLoaded(
        searchCenter: center,
        allPlaces: [place],
        selectedPlaceId: 'place-1',
        filters: ExplorerFilters(radiusMeters: 5000),
      ),
    ],
    verify: (_) {
      verify(() => repo.searchNearby(any())).called(1);
      verify(
        () => filterRepo.save(const ExplorerFilters(radiusMeters: 5000)),
      ).called(1);
    },
  );

  blocTest<ExplorerCubit, ExplorerState>(
    'reset restores cafe and 3 km with exactly one request',
    build: () {
      when(
        () => repo.searchNearby(any()),
      ).thenAnswer((_) async => const Success([place]));
      return buildCubit();
    },
    seed: () => const ExplorerLoaded(
      searchCenter: center,
      allPlaces: [restaurant],
      filters: ExplorerFilters(
        category: PlaceCategory.restaurant,
        radiusMeters: 10000,
      ),
    ),
    act: (cubit) => cubit.resetFilters(),
    expect: () => const [
      ExplorerLoaded(
        searchCenter: center,
        allPlaces: [restaurant],
        isRefreshing: true,
      ),
      ExplorerLoaded(
        searchCenter: center,
        allPlaces: [place],
        selectedPlaceId: 'place-1',
      ),
    ],
    verify: (_) {
      verify(() => filterRepo.reset()).called(1);
      verify(() => repo.searchNearby(any())).called(1);
    },
  );
}
