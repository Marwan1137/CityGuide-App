import 'package:bloc_test/bloc_test.dart';
import 'package:city_guide_app/features/city_search/domain/entity/city.dart';
import 'package:city_guide_app/features/city_search/presentation/view/city_search_screen.dart';
import 'package:city_guide_app/features/city_search/presentation/view_model/city_search_cubit.dart';
import 'package:city_guide_app/features/city_search/presentation/view_model/city_search_state.dart';
import 'package:city_guide_app/features/city_search/presentation/widgets/city_result_tile.dart';
import 'package:city_guide_app/shared/domain/geo_point.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCitySearchCubit extends MockCubit<CitySearchState>
    implements CitySearchCubit {}

void main() {
  late _MockCitySearchCubit cubit;

  const cairo = City(
    id: 'cairo',
    nameEn: 'Cairo',
    nameAr: 'القاهرة',
    governorateEn: 'Cairo',
    governorateAr: 'القاهرة',
    location: GeoPoint(latitude: 30.0444, longitude: 31.2357),
  );

  setUp(() => cubit = _MockCitySearchCubit());

  Future<void> pumpState(WidgetTester tester, CitySearchState state) async {
    whenListen(
      cubit,
      const Stream<CitySearchState>.empty(),
      initialState: state,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CitySearchCubit>.value(
          value: cubit,
          child: CitySearchScreen(
            onRetryDeviceLocation: () {},
            onCenterSelected: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('renders loading explicitly', (tester) async {
    await pumpState(tester, const CitySearchLoading());

    expect(find.text('Loading Egyptian cities…'), findsOneWidget);
  });

  testWidgets('renders English and Arabic loaded results explicitly', (
    tester,
  ) async {
    when(() => cubit.search(any())).thenAnswer((_) async {});
    when(() => cubit.chooseCity(cairo)).thenAnswer((_) async {});
    await pumpState(
      tester,
      const CitySearchLoaded(query: 'Cairo', cities: [cairo]),
    );

    expect(find.text('Cairo · القاهرة'), findsWidgets);
    expect(find.byType(CityResultTile), findsOneWidget);
    await tester.tap(find.byType(CityResultTile));
    verify(() => cubit.chooseCity(cairo)).called(1);
  });

  testWidgets('renders empty local results and online fallback', (
    tester,
  ) async {
    when(() => cubit.search(any())).thenAnswer((_) async {});
    await pumpState(
      tester,
      const CitySearchLoaded(query: 'Zamalek', cities: []),
    );

    expect(find.text('No capital matches “Zamalek”'), findsOneWidget);
    expect(find.text('Search online for Zamalek'), findsOneWidget);
    expect(find.text('Retry device location'), findsOneWidget);
  });

  testWidgets('renders friendly errors explicitly', (tester) async {
    when(() => cubit.retry()).thenAnswer((_) async {});
    await pumpState(
      tester,
      const CitySearchError('City search is busy right now.'),
    );

    expect(find.text('City search took a detour'), findsOneWidget);
    expect(find.text('City search is busy right now.'), findsOneWidget);
  });
}
