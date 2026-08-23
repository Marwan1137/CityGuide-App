import 'dart:async';

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
import 'package:city_guide_app/features/custom_places/domain/repo_contract/custom_places_repo.dart';
import 'package:city_guide_app/features/custom_places/domain/use_cases/watch_custom_places_usecase.dart';

class _MockRepo extends Mock implements NearbyPlacesRepo {}

class _MockFilterPreferencesRepo extends Mock
    implements ExplorerFilterPreferencesRepo {}

class _MockCustomPlacesRepo extends Mock implements CustomPlacesRepo {}

void main() {
  late _MockRepo repo;
  late SearchNearbyPlacesUseCase useCase;
  late _MockFilterPreferencesRepo filterRepo;
  late LoadExplorerFiltersUseCase loadFilters;
  late SaveExplorerFiltersUseCase saveFilters;
  late ResetExplorerFiltersUseCase resetFilters;
  late _MockCustomPlacesRepo customPlacesRepo;
  late WatchCustomPlacesUseCase watchCustomPlaces;

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
    customPlacesRepo = _MockCustomPlacesRepo();
    watchCustomPlaces = WatchCustomPlacesUseCase(customPlacesRepo);
    when(
          () => filterRepo.load(),
    ).thenAnswer((_) async => const Success(ExplorerFilters()));
    when(
          () => filterRepo.save(any()),
    ).thenAnswer((_) async => const Success(null));
    when(() => filterRepo.reset()).thenAnswer((_) async => const Success(null));
    when(
          () => customPlacesRepo.watchCustomPlaces(),
    ).thenAnswer((_) => const Stream.empty());
  });

  ExplorerCubit buildCubit() => ExplorerCubit(
    useCase,
    loadFilters,
    saveFilters,
    resetFilters,
    watchCustomPlaces,
  );

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

  test('camera movement makes zero requests until explicit search', () async {
    when(
      () => repo.searchNearby(any()),
    ).thenAnswer((_) async => const Success([place]));
    final cubit = buildCubit();
    await cubit.initialize(center);
    clearInteractions(repo);

    cubit.onCameraIdle(const GeoPoint(latitude: 30.07, longitude: 31.27), 15);
    cubit.onCameraIdle(const GeoPoint(latitude: 30.08, longitude: 31.28), 15.5);

    final loaded = cubit.state as ExplorerLoaded;
    expect(
      loaded.pendingSearchCenter?.point,
      const GeoPoint(latitude: 30.08, longitude: 31.28),
    );
    verifyNever(() => repo.searchNearby(any()));
    await cubit.close();
  });

  test(
    'explicit search makes one request and accepts the map center',
    () async {
      var call = 0;
      when(() => repo.searchNearby(any())).thenAnswer((_) async {
        call++;
        return call == 1
            ? const Success([place])
            : const Success([secondPlace]);
      });
      final cubit = buildCubit();
      await cubit.initialize(center);
      clearInteractions(repo);
      const mapPoint = GeoPoint(latitude: 30.08, longitude: 31.28);
      cubit.onCameraIdle(mapPoint, 15);

      await cubit.searchThisArea();

      final captured = verify(() => repo.searchNearby(captureAny())).captured;
      expect(captured, hasLength(1));
      expect((captured.single as NearbySearchRequest).center, mapPoint);
      final loaded = cubit.state as ExplorerLoaded;
      expect(loaded.searchCenter.point, mapPoint);
      expect(loaded.pendingSearchCenter, isNull);
      expect(loaded.allPlaces, const [secondPlace]);
      await cubit.close();
    },
  );

  test(
    'new map search cancels the previous request and rejects stale data',
    () async {
      final firstResult = Completer<AppResult<List<PlaceSummary>>>();
      final secondResult = Completer<AppResult<List<PlaceSummary>>>();
      final requests = <NearbySearchRequest>[];
      when(() => repo.searchNearby(any())).thenAnswer((invocation) {
        final request =
            invocation.positionalArguments.single as NearbySearchRequest;
        requests.add(request);
        if (requests.length == 1) {
          return Future.value(const Success([place]));
        }
        return requests.length == 2 ? firstResult.future : secondResult.future;
      });
      final cubit = buildCubit();
      await cubit.initialize(center);

      const firstPoint = GeoPoint(latitude: 30.07, longitude: 31.27);
      cubit.onCameraIdle(firstPoint, 15);
      final firstSearch = cubit.searchThisArea();
      await Future<void>.delayed(Duration.zero);

      const latestPoint = GeoPoint(latitude: 30.09, longitude: 31.29);
      cubit.onCameraIdle(latestPoint, 15.5);
      final latestSearch = cubit.searchThisArea();
      await Future<void>.delayed(Duration.zero);

      expect(requests[1].cancellation?.isCancelled, isTrue);
      secondResult.complete(const Success([secondPlace]));
      await latestSearch;
      firstResult.complete(const Success([restaurant]));
      await firstSearch;

      final loaded = cubit.state as ExplorerLoaded;
      expect(loaded.searchCenter.point, latestPoint);
      expect(loaded.allPlaces, const [secondPlace]);
      await cubit.close();
    },
  );

  test(
    'refresh failure retains places and exposes a recoverable message',
    () async {
      var call = 0;
      when(() => repo.searchNearby(any())).thenAnswer((_) async {
        call++;
        return call == 1
            ? const Success([place])
            : const Error<List<PlaceSummary>>(
                NetworkFailure('Connection interrupted.'),
              );
      });
      final cubit = buildCubit();
      await cubit.initialize(center);
      cubit.onCameraIdle(const GeoPoint(latitude: 30.08, longitude: 31.28), 15);

      await cubit.searchThisArea();

      final loaded = cubit.state as ExplorerLoaded;
      expect(loaded.allPlaces, const [place]);
      expect(loaded.searchCenter, center);
      expect(loaded.pendingSearchCenter, isNotNull);
      expect(loaded.refreshErrorMessage, 'Connection interrupted.');
      expect(loaded.isRefreshing, isFalse);
      await cubit.close();
    },
  );

  test('rapid filter changes cancel and ignore the older response', () async {
    final firstResult = Completer<AppResult<List<PlaceSummary>>>();
    final secondResult = Completer<AppResult<List<PlaceSummary>>>();
    final requests = <NearbySearchRequest>[];
    when(() => repo.searchNearby(any())).thenAnswer((invocation) {
      final request =
          invocation.positionalArguments.single as NearbySearchRequest;
      requests.add(request);
      if (requests.length == 1) {
        return Future.value(const Success([place]));
      }
      return requests.length == 2 ? firstResult.future : secondResult.future;
    });
    final cubit = buildCubit();
    await cubit.initialize(center);

    final categoryChange = cubit.changeCategory(PlaceCategory.restaurant);
    await Future<void>.delayed(Duration.zero);
    final radiusChange = cubit.changeRadius(5000);
    await Future<void>.delayed(Duration.zero);

    expect(requests[1].cancellation?.isCancelled, isTrue);
    secondResult.complete(const Success([restaurant]));
    await radiusChange;
    firstResult.complete(const Success([secondPlace]));
    await categoryChange;

    final loaded = cubit.state as ExplorerLoaded;
    expect(
      loaded.filters,
      const ExplorerFilters(
        category: PlaceCategory.restaurant,
        radiusMeters: 5000,
      ),
    );
    expect(loaded.allPlaces, const [restaurant]);
    await cubit.close();
  });
}
