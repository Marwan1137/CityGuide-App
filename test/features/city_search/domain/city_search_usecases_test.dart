import 'package:city_guide_app/core/error/failure.dart';
import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/city_search/domain/entity/city.dart';
import 'package:city_guide_app/features/city_search/domain/repo_contract/city_search_repo.dart';
import 'package:city_guide_app/features/city_search/domain/use_cases/geocode_city_usecase.dart';
import 'package:city_guide_app/features/city_search/domain/use_cases/search_cities_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCitySearchRepo extends Mock implements CitySearchRepo {}

void main() {
  late _MockCitySearchRepo repo;

  setUp(() => repo = _MockCitySearchRepo());

  test('local search rejects an excessively long query', () async {
    final result = await SearchCitiesUseCase(repo)('x' * 81);

    expect(result, isA<Error<List<City>>>());
    verifyNever(() => repo.searchLocal(any()));
  });

  test('remote search validates the query before making a request', () async {
    final result = await GeocodeCityUseCase(repo)('x');

    expect(result, isA<Error<City>>());
    verifyNever(() => repo.geocodeUnknownCity(any()));
  });

  test('valid remote search triggers the repository contract once', () async {
    when(() => repo.geocodeUnknownCity('Zamalek')).thenAnswer(
      (_) async => const Error<City>(
        // The transport result is irrelevant to this delegation test.
        UnknownFailure(message: 'test'),
      ),
    );

    await GeocodeCityUseCase(repo)(' Zamalek ');

    verify(() => repo.geocodeUnknownCity('Zamalek')).called(1);
  });
}
