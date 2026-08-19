import 'package:bloc_test/bloc_test.dart';
import 'package:city_guide_app/features/location/domain/entity/location_access.dart';
import 'package:city_guide_app/features/location/presentation/view/location_screen.dart';
import 'package:city_guide_app/features/location/presentation/view_model/location_cubit.dart';
import 'package:city_guide_app/features/location/presentation/view_model/location_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockLocationCubit extends MockCubit<LocationState>
    implements LocationCubit {}

void main() {
  late _MockLocationCubit cubit;

  setUp(() => cubit = _MockLocationCubit());

  Future<void> pumpState(WidgetTester tester, LocationState state) async {
    whenListen(cubit, const Stream<LocationState>.empty(), initialState: state);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<LocationCubit>.value(
          value: cubit,
          child: const LocationScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('renders loading explicitly', (tester) async {
    await pumpState(tester, const LocationLoading());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Checking location access…'), findsOneWidget);
  });

  testWidgets('renders the loaded permission rationale explicitly', (
    tester,
  ) async {
    await pumpState(
      tester,
      const LocationLoaded(
        LocationAccess(status: LocationAccessStatus.notRequested),
      ),
    );

    expect(find.text('Discover what is nearby'), findsOneWidget);
    expect(find.text('Use my location'), findsOneWidget);
    expect(find.text('Choose a city instead'), findsOneWidget);
  });

  testWidgets('renders a friendly error explicitly', (tester) async {
    await pumpState(
      tester,
      const LocationError('Location is unavailable right now.'),
    );

    expect(find.text('We hit a small detour'), findsOneWidget);
    expect(find.text('Location is unavailable right now.'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });
}
