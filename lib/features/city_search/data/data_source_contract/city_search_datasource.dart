import 'package:city_guide_app/core/api/api_result.dart';
import 'package:city_guide_app/features/city_search/data/model/city_model.dart';

abstract interface class LocalCitySearchDatasource {
  Future<ApiResult<List<CityModel>>> search(String query);

  Future<ApiResult<CityModel?>> getRecentCity();

  Future<ApiResult<CityModel?>> getPersistedSearchCenter();

  Future<ApiResult<void>> saveRecentCity(CityModel city);

  Future<ApiResult<void>> saveSearchCenter(CityModel city);
}

abstract interface class RemoteCitySearchDatasource {
  Future<ApiResult<CityModel>> geocode(String query);
}

abstract interface class CitySearchPersistenceStore {
  Future<String?> read(String key);

  Future<void> write(String key, String value);
}
