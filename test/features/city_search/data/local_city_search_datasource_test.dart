import 'dart:convert';

import 'package:city_guide_app/core/api/api_executor.dart';
import 'package:city_guide_app/core/api/api_result.dart';
import 'package:city_guide_app/features/city_search/data/data_source_contract/city_search_datasource.dart';
import 'package:city_guide_app/features/city_search/data/data_source_impl/local_city_search_datasource_impl.dart';
import 'package:city_guide_app/features/city_search/data/model/city_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockPersistenceStore extends Mock
    implements CitySearchPersistenceStore {}

void main() {
  late _MockPersistenceStore store;
  late LocalCitySearchDatasourceImpl datasource;

  setUp(() {
    store = _MockPersistenceStore();
    datasource = LocalCitySearchDatasourceImpl(const ApiExecutor(), store);
    when(() => store.read(any())).thenAnswer((_) async => null);
    when(() => store.write(any(), any())).thenAnswer((_) async {});
  });

  test('contains all 27 Egyptian governorate capitals', () async {
    final cities = _success(await datasource.search(''));

    expect(cities, hasLength(27));
    expect(cities.map((city) => city.id).toSet(), hasLength(27));
  });

  test('matches English city and governorate aliases offline', () async {
    expect(_success(await datasource.search('Cairo')).single.id, 'cairo');
    expect(_success(await datasource.search('Dakahlia')).single.id, 'mansoura');
  });

  test('matches Arabic names with spelling normalization offline', () async {
    expect(_success(await datasource.search('القاهره')).single.id, 'cairo');
    expect(_success(await datasource.search('الدقهلية')).single.id, 'mansoura');
  });

  test('returns an empty list for an unknown local city', () async {
    expect(_success(await datasource.search('Zamalek')), isEmpty);
  });

  test('persists and restores the recent selected city', () async {
    const city = CityModel(
      id: 'cairo',
      nameEn: 'Cairo',
      nameAr: 'القاهرة',
      governorateEn: 'Cairo',
      governorateAr: 'القاهرة',
      latitude: 30.0444,
      longitude: 31.2357,
      aliases: [],
    );
    await datasource.saveRecentCity(city);
    final captured =
        verify(
              () => store.write('recent_selected_city', captureAny()),
            ).captured.single
            as String;
    when(
      () => store.read('recent_selected_city'),
    ).thenAnswer((_) async => captured);

    final restored = _nullableSuccess(await datasource.getRecentCity());

    expect(jsonDecode(captured), isA<Map<String, dynamic>>());
    expect(restored, city);
  });
}

List<CityModel> _success(ApiResult<List<CityModel>> result) =>
    (result as ApiSuccess<List<CityModel>>).data;

CityModel? _nullableSuccess(ApiResult<CityModel?> result) =>
    (result as ApiSuccess<CityModel?>).data;
