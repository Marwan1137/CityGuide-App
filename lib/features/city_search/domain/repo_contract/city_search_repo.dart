import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/city_search/domain/entity/city.dart';
import 'package:city_guide_app/shared/domain/search_center.dart';

abstract interface class CitySearchRepo {
  Future<AppResult<List<City>>> searchLocal(String query);

  Future<AppResult<City>> geocodeUnknownCity(String query);

  Future<AppResult<City?>> getRecentCity();

  Future<AppResult<SearchCenter?>> getPersistedSearchCenter();

  Future<AppResult<SearchCenter>> selectCity(City city);
}
