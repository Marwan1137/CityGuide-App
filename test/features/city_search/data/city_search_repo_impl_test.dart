import 'package:city_guide_app/core/api/api_result.dart';
import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/city_search/data/data_source_contract/city_search_datasource.dart';
import 'package:city_guide_app/features/city_search/data/model/city_model.dart';
import 'package:city_guide_app/features/city_search/data/repo_impl/city_search_repo_impl.dart';
import 'package:city_guide_app/features/city_search/domain/entity/city.dart';
import 'package:city_guide_app/shared/domain/geo_point.dart';
import 'package:city_guide_app/shared/domain/search_center.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLocalDatasource extends Mock implements LocalCitySearchDatasource {}

class _MockRemoteDatasource extends Mock
    implements RemoteCitySearchDatasource {}

void main() {
  late _MockLocalDatasource local;
  late _MockRemoteDatasource remote;
  late CitySearchRepoImpl repo;

  const cairoModel = CityModel(
    id: 'cairo',
    nameEn: 'Cairo',
    nameAr: 'القاهرة',
    governorateEn: 'Cairo',
    governorateAr: 'القاهرة',
    latitude: 30.0444,
    longitude: 31.2357,
    aliases: [],
  );
  const cairo = City(
    id: 'cairo',
    nameEn: 'Cairo',
    nameAr: 'القاهرة',
    governorateEn: 'Cairo',
    governorateAr: 'القاهرة',
    location: GeoPoint(latitude: 30.0444, longitude: 31.2357),
  );

  setUpAll(() => registerFallbackValue(cairoModel));

  setUp(() {
    local = _MockLocalDatasource();
    remote = _MockRemoteDatasource();
    repo = CitySearchRepoImpl(local, remote);
  });

  test('maps local models into domain entities', () async {
    when(
      () => local.search('cairo'),
    ).thenAnswer((_) async => const ApiSuccess([cairoModel]));

    final result = await repo.searchLocal('cairo');

    expect((result as Success<List<City>>).data, const [cairo]);
  });

  test('selection saves recent city and SearchCenter', () async {
    when(
      () => local.saveRecentCity(any()),
    ).thenAnswer((_) async => const ApiSuccess(null));
    when(
      () => local.saveSearchCenter(any()),
    ).thenAnswer((_) async => const ApiSuccess(null));

    final result = await repo.selectCity(cairo);

    final center = (result as Success<SearchCenter>).data;
    expect(center.source, SearchCenterSource.selectedCity);
    expect(center.point, cairo.location);
    expect(center.label, 'Cairo');
    verify(() => local.saveRecentCity(any())).called(1);
    verify(() => local.saveSearchCenter(any())).called(1);
  });

  test('restores the persisted SearchCenter contract', () async {
    when(
      () => local.getPersistedSearchCenter(),
    ).thenAnswer((_) async => const ApiSuccess(cairoModel));

    final result = await repo.getPersistedSearchCenter();
    final center = (result as Success<SearchCenter?>).data;

    expect(center?.point, cairo.location);
    expect(center?.source, SearchCenterSource.selectedCity);
  });
}
