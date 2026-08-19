import 'dart:convert';

import 'package:city_guide_app/core/api/api_executor.dart';
import 'package:city_guide_app/core/api/api_result.dart';
import 'package:city_guide_app/features/city_search/data/data_source_contract/city_search_datasource.dart';
import 'package:city_guide_app/features/city_search/data/model/city_model.dart';
import 'package:city_guide_app/features/city_search/data/model/egypt_city_catalog.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: LocalCitySearchDatasource)
class LocalCitySearchDatasourceImpl implements LocalCitySearchDatasource {
  LocalCitySearchDatasourceImpl(this._executor, this._store);

  static const _recentCityKey = 'recent_selected_city';
  static const _searchCenterKey = 'persisted_search_center_city';

  final ApiExecutor _executor;
  final CitySearchPersistenceStore _store;

  @override
  Future<ApiResult<List<CityModel>>> search(String query) =>
      _executor.execute(() async {
        final normalizedQuery = _normalize(query);
        if (normalizedQuery.isEmpty) {
          return List<CityModel>.unmodifiable(EgyptCityCatalog.cities);
        }

        final matches = EgyptCityCatalog.cities.where((city) {
          final terms = [
            city.nameEn,
            city.nameAr,
            city.governorateEn,
            city.governorateAr,
            ...city.aliases,
          ].map(_normalize);
          return terms.any((term) => term.contains(normalizedQuery));
        }).toList();

        matches.sort((first, second) {
          final firstStarts = _normalize(
            first.nameEn + first.nameAr,
          ).startsWith(normalizedQuery);
          final secondStarts = _normalize(
            second.nameEn + second.nameAr,
          ).startsWith(normalizedQuery);
          if (firstStarts != secondStarts) return firstStarts ? -1 : 1;
          return first.nameEn.compareTo(second.nameEn);
        });
        return List<CityModel>.unmodifiable(matches);
      });

  @override
  Future<ApiResult<CityModel?>> getRecentCity() => _readCity(_recentCityKey);

  @override
  Future<ApiResult<CityModel?>> getPersistedSearchCenter() =>
      _readCity(_searchCenterKey);

  @override
  Future<ApiResult<void>> saveRecentCity(CityModel city) =>
      _writeCity(_recentCityKey, city);

  @override
  Future<ApiResult<void>> saveSearchCenter(CityModel city) =>
      _writeCity(_searchCenterKey, city);

  Future<ApiResult<CityModel?>> _readCity(String key) =>
      _executor.execute(() async {
        final value = await _store.read(key);
        if (value == null || value.isEmpty) return null;
        return CityModel.fromJson(jsonDecode(value) as Map<String, dynamic>);
      });

  Future<ApiResult<void>> _writeCity(String key, CityModel city) =>
      _executor.execute(() async {
        await _store.write(key, jsonEncode(city.toJson()));
      });

  String _normalize(String value) => value
      .toLowerCase()
      .replaceAll(RegExp('[\u064B-\u065F\u0670]'), '')
      .replaceAll(RegExp('[إأآٱ]'), 'ا')
      .replaceAll('ى', 'ي')
      .replaceAll('ؤ', 'و')
      .replaceAll('ئ', 'ي')
      .replaceAll('ة', 'ه')
      .replaceAll(RegExp('[^a-z0-9\u0600-\u06FF]+'), ' ')
      .trim();
}
