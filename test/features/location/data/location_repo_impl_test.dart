import 'package:city_guide_app/core/api/api_result.dart';
import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/location/data/data_source_contract/location_datasource.dart';
import 'package:city_guide_app/features/location/data/model/location_access_model.dart';
import 'package:city_guide_app/features/location/data/repo_impl/location_repo_impl.dart';
import 'package:city_guide_app/features/location/domain/entity/location_access.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLocationDatasource extends Mock implements LocationDatasource {}

void main() {
  late _MockLocationDatasource datasource;
  late LocationRepoImpl repo;

  setUp(() {
    datasource = _MockLocationDatasource();
    repo = LocationRepoImpl(datasource);
  });

  final outcomes = <LocationAccessModelStatus, LocationAccessStatus>{
    LocationAccessModelStatus.notRequested: LocationAccessStatus.notRequested,
    LocationAccessModelStatus.granted: LocationAccessStatus.granted,
    LocationAccessModelStatus.denied: LocationAccessStatus.denied,
    LocationAccessModelStatus.permanentlyDenied:
        LocationAccessStatus.permanentlyDenied,
    LocationAccessModelStatus.servicesDisabled:
        LocationAccessStatus.servicesDisabled,
    LocationAccessModelStatus.reducedAccuracy:
        LocationAccessStatus.reducedAccuracy,
    LocationAccessModelStatus.timedOut: LocationAccessStatus.timedOut,
  };

  for (final entry in outcomes.entries) {
    test('maps ${entry.key.name} into the domain outcome', () async {
      final model = LocationAccessModel(status: entry.key);
      when(
        () => datasource.checkAccess(),
      ).thenAnswer((_) async => ApiSuccess(model));

      final result = await repo.checkAccess();

      expect(result, isA<Success<LocationAccess>>());
      final access = (result as Success<LocationAccess>).data;
      expect(access.status, entry.value);
    });
  }

  test('maps coordinates only inside the repository boundary', () async {
    const model = LocationAccessModel(
      status: LocationAccessModelStatus.granted,
      latitude: 30.0444,
      longitude: 31.2357,
      accuracyMeters: 8,
    );
    when(
      () => datasource.getCurrentLocation(),
    ).thenAnswer((_) async => const ApiSuccess(model));

    final result = await repo.getCurrentLocation();
    final access = (result as Success<LocationAccess>).data;

    expect(access.point?.latitude, 30.0444);
    expect(access.point?.longitude, 31.2357);
    expect(access.accuracyMeters, 8);
  });

  test('maps provider failures to a friendly domain failure', () async {
    when(() => datasource.checkAccess()).thenAnswer(
      (_) async => const ApiFailure(
        ApiError(
          type: ApiErrorType.unknown,
          message: 'Location is temporarily unavailable.',
        ),
      ),
    );

    final result = await repo.checkAccess();

    expect(result, isA<Error<LocationAccess>>());
    expect(
      (result as Error<LocationAccess>).failure.message,
      'Location is temporarily unavailable.',
    );
  });
}
