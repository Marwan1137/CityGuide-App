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

  setUp(() {
    cubit = _MockExplorerCubit();
    when(() => cubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => cubit.selectPlace(any())).thenReturn(null);
  });

  Widget buildScreen(ExplorerState state) {
    when(() => cubit.state).thenReturn(state);
    return MaterialApp(
      home: BlocProvider<ExplorerCubit>.value(
        value: cubit,
        child: ExplorerScreen(
          onChooseCity: () {},
          mapBuilder: (_, _, _) =>
              const ColoredBox(key: Key('mock-map'), color: Colors.blueGrey),
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
          places: [place],
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
      buildScreen(const ExplorerLoaded(searchCenter: center, places: [])),
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
      const ExplorerLoaded(searchCenter: center, places: [place]),
    );
    await tester.pumpWidget(widget);
    await tester.pumpWidget(widget);

    verifyNever(() => cubit.initialize(center));
  });
}
