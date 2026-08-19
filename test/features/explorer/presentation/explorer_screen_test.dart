import 'package:bloc_test/bloc_test.dart';
import 'package:city_guide_app/features/explorer/presentation/view/explorer_screen.dart';
import 'package:city_guide_app/features/explorer/presentation/view_model/explorer_cubit.dart';
import 'package:city_guide_app/features/explorer/presentation/view_model/explorer_state.dart';
import 'package:city_guide_app/shared/domain/geo_point.dart';
import 'package:city_guide_app/shared/domain/place_category.dart';
import 'package:city_guide_app/shared/domain/place_summary.dart';
import 'package:city_guide_app/shared/domain/search_center.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockExplorerCubit extends MockCubit<ExplorerState>
    implements ExplorerCubit {}

void main() {
  late _MockExplorerCubit cubit;

  setUpAll(() => registerFallbackValue(ExplorerViewMode.map));

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
    address: 'Downtown Cairo',
    rating: 4.7,
  );
  const secondPlace = PlaceSummary(
    id: 'place-2',
    name: 'Nile Brew',
    category: PlaceCategory.cafe,
    location: GeoPoint(latitude: 30.046, longitude: 31.237),
    address: 'Garden City',
    rating: 4.5,
  );

  setUp(() {
    cubit = _MockExplorerCubit();
    when(() => cubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => cubit.selectPlace(any())).thenReturn(null);
    when(() => cubit.selectPlaceFromList(any())).thenReturn(null);
    when(() => cubit.changeViewMode(any())).thenReturn(null);
    when(() => cubit.updateZoom(any())).thenReturn(null);
    when(() => cubit.updateListScrollOffset(any())).thenReturn(null);
  });

  Widget buildScreen(ExplorerState state) {
    when(() => cubit.state).thenReturn(state);
    return MaterialApp(
      home: BlocProvider<ExplorerCubit>.value(
        value: cubit,
        child: ExplorerScreen(
          key: UniqueKey(),
          onChooseCity: () {},
          mapBuilder: (_, state, _, _) => ColoredBox(
            key: const Key('mock-map'),
            color: Colors.blueGrey,
            child: Text(
              state.filteredPlaces.map((place) => place.id).join(','),
              key: const Key('mock-map-place-ids'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders loading explicitly', (tester) async {
    await tester.pumpWidget(buildScreen(const ExplorerLoading()));

    expect(find.text('Finding nearby cafes…'), findsOneWidget);
    expect(find.byKey(const Key('mock-map')), findsNothing);
  });

  testWidgets('renders loaded map and place preview explicitly', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildScreen(
        const ExplorerLoaded(
          searchCenter: center,
          allPlaces: [place],
          selectedPlaceId: 'place-1',
        ),
      ),
    );

    expect(find.byKey(const Key('mock-map')), findsOneWidget);
    expect(find.text('Explorer'), findsOneWidget);
    expect(find.text('Cairo Coffee'), findsOneWidget);
    expect(find.text('★ 4.7'), findsOneWidget);
  });

  testWidgets('renders a friendly loaded empty overlay', (tester) async {
    await tester.pumpWidget(
      buildScreen(const ExplorerLoaded(searchCenter: center, allPlaces: [])),
    );

    expect(find.byKey(const Key('mock-map')), findsOneWidget);
    expect(find.text('No cafes found nearby'), findsOneWidget);
  });

  testWidgets('renders friendly errors explicitly', (tester) async {
    when(() => cubit.retry()).thenAnswer((_) async {});
    await tester.pumpWidget(
      buildScreen(
        const ExplorerError(
          searchCenter: center,
          message: 'Check your internet connection and try again.',
        ),
      ),
    );

    expect(find.text('Nearby search took a detour'), findsOneWidget);
    expect(
      find.text('Check your internet connection and try again.'),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('rebuilding the loaded map does not trigger a nearby request', (
    tester,
  ) async {
    final widget = buildScreen(
      const ExplorerLoaded(searchCenter: center, allPlaces: [place]),
    );
    await tester.pumpWidget(widget);
    await tester.pumpWidget(widget);

    verifyNever(() => cubit.initialize(center));
  });

  testWidgets('map and list expose identical place IDs and counts', (
    tester,
  ) async {
    const places = [place, secondPlace];
    await tester.pumpWidget(
      buildScreen(
        const ExplorerLoaded(searchCenter: center, allPlaces: places),
      ),
    );

    expect(find.text('place-1,place-2'), findsOneWidget);

    await tester.pumpWidget(
      buildScreen(
        const ExplorerLoaded(
          searchCenter: center,
          allPlaces: places,
          viewMode: ExplorerViewMode.list,
        ),
      ),
    );

    expect(find.text('2 nearby cafés'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('place-list-card-place-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('place-list-card-place-2')),
      findsOneWidget,
    );
  });

  testWidgets('view controls and list cards synchronize through one Cubit', (
    tester,
  ) async {
    const places = [place, secondPlace];
    await tester.pumpWidget(
      buildScreen(
        const ExplorerLoaded(searchCenter: center, allPlaces: places),
      ),
    );

    await tester.tap(find.byKey(const Key('show-list-button')));
    verify(() => cubit.changeViewMode(ExplorerViewMode.list)).called(1);

    await tester.pumpWidget(
      buildScreen(
        const ExplorerLoaded(
          searchCenter: center,
          allPlaces: places,
          viewMode: ExplorerViewMode.list,
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('place-list-card-place-2')));
    verify(() => cubit.selectPlaceFromList('place-2')).called(1);

    await tester.tap(find.byKey(const Key('show-map-button')));
    verify(() => cubit.changeViewMode(ExplorerViewMode.map)).called(1);
    verifyNever(() => cubit.initialize(center));
  });
}
