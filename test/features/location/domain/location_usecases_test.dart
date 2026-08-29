import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/location/domain/entity/location_access.dart';
import 'package:city_guide_app/features/location/domain/repo_contract/location_repo.dart';
import 'package:city_guide_app/features/location/domain/use_cases/check_location_access_usecase.dart';
import 'package:city_guide_app/features/location/domain/use_cases/get_current_location_usecase.dart';
import 'package:city_guide_app/features/location/domain/use_cases/request_location_access_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLocationRepo extends Mock implements LocationRepo {}

void main() {
  late _MockLocationRepo repo;
  const access = LocationAccess(status: LocationAccessStatus.granted);

  setUp(() => repo = _MockLocationRepo());

  test('check use case triggers the repository contract', () async {
    when(
      () => repo.checkAccess(),
    ).thenAnswer((_) async => const Success(access));

    final result = await CheckLocationAccessUseCase(repo)();

    expect(result, const Success<LocationAccess>(access));
    verify(() => repo.checkAccess()).called(1);
  });

  test('request use case triggers the repository contract', () async {
    when(
      () => repo.requestAccess(),
    ).thenAnswer((_) async => const Success(access));

    await RequestLocationAccessUseCase(repo)();

    verify(() => repo.requestAccess()).called(1);
  });

  test('current location use case triggers the repository contract', () async {
    when(
      () => repo.getCurrentLocation(),
    ).thenAnswer((_) async => const Success(access));

    await GetCurrentLocationUseCase(repo)();

    verify(() => repo.getCurrentLocation()).called(1);
  });
}
