import 'package:bloc_test/bloc_test.dart';
import 'package:city_guide_app/core/error/failure.dart';
import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/location/domain/entity/location_access.dart';
import 'package:city_guide_app/features/location/domain/repo_contract/location_repo.dart';
import 'package:city_guide_app/features/location/domain/use_cases/check_location_access_usecase.dart';
import 'package:city_guide_app/features/location/domain/use_cases/get_current_location_usecase.dart';
import 'package:city_guide_app/features/location/domain/use_cases/open_location_settings_usecase.dart';
import 'package:city_guide_app/features/location/domain/use_cases/request_location_access_usecase.dart';
import 'package:city_guide_app/features/location/presentation/view_model/location_cubit.dart';
import 'package:city_guide_app/features/location/presentation/view_model/location_state.dart';
import 'package:city_guide_app/shared/domain/geo_point.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLocationRepo extends Mock implements LocationRepo {}

void main() {
  late _MockLocationRepo repo;

  LocationCubit buildCubit() => LocationCubit(
    CheckLocationAccessUseCase(repo),
    RequestLocationAccessUseCase(repo),
    GetCurrentLocationUseCase(repo),
    OpenLocationSettingsUseCase(repo),
  );

  setUp(() => repo = _MockLocationRepo());

  final statuses = LocationAccessStatus.values;
  for (final status in statuses) {
    blocTest<LocationCubit, LocationState>(
      'initialize emits loaded for ${status.name}',
      build: () {
        when(
          () => repo.checkAccess(),
        ).thenAnswer((_) async => Success(LocationAccess(status: status)));
        return buildCubit();
      },
      act: (cubit) => cubit.initialize(),
      expect: () => [
        const LocationLoading(),
        LocationLoaded(LocationAccess(status: status)),
      ],
    );
  }

  blocTest<LocationCubit, LocationState>(
    'granted request automatically obtains the current location',
    build: () {
      when(() => repo.requestAccess()).thenAnswer(
        (_) async =>
            const Success(LocationAccess(status: LocationAccessStatus.granted)),
      );
      when(() => repo.getCurrentLocation()).thenAnswer(
        (_) async => const Success(
          LocationAccess(
            status: LocationAccessStatus.granted,
            point: GeoPoint(latitude: 30.0444, longitude: 31.2357),
          ),
        ),
      );
      return buildCubit();
    },
    act: (cubit) => cubit.requestPermission(),
    expect: () => const [
      LocationLoading(),
      LocationLoaded(
        LocationAccess(
          status: LocationAccessStatus.granted,
          point: GeoPoint(latitude: 30.0444, longitude: 31.2357),
        ),
      ),
    ],
    verify: (_) {
      verify(() => repo.requestAccess()).called(1);
      verify(() => repo.getCurrentLocation()).called(1);
    },
  );

  blocTest<LocationCubit, LocationState>(
    'settings return rechecks service and permission state',
    build: () {
      when(() => repo.checkAccess()).thenAnswer(
        (_) async =>
            const Success(LocationAccess(status: LocationAccessStatus.granted)),
      );
      when(
        () => repo.openAppSettings(),
      ).thenAnswer((_) async => const Success(true));
      return buildCubit();
    },
    act: (cubit) async {
      await cubit.openAppSettings();
      await cubit.onAppResumed();
    },
    expect: () => const [
      LocationLoading(),
      LocationLoaded(LocationAccess(status: LocationAccessStatus.granted)),
    ],
    verify: (_) => verify(() => repo.checkAccess()).called(1),
  );

  blocTest<LocationCubit, LocationState>(
    'infrastructure failure emits a friendly error state',
    build: () {
      when(() => repo.checkAccess()).thenAnswer(
        (_) async => const Error(
          UnknownFailure(message: 'Location is unavailable right now.'),
        ),
      );
      return buildCubit();
    },
    act: (cubit) => cubit.initialize(),
    expect: () => const [
      LocationLoading(),
      LocationError('Location is unavailable right now.'),
    ],
  );
}
