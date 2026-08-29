import 'package:city_guide_app/core/api/api_result.dart';
import 'package:city_guide_app/features/explorer/data/model/explorer_filters_model.dart';

abstract interface class ExplorerFilterPreferencesDatasource {
  Future<ApiResult<ExplorerFiltersModel?>> load();

  Future<ApiResult<void>> save(ExplorerFiltersModel filters);

  Future<ApiResult<void>> reset();
}

abstract interface class ExplorerFilterPreferencesStore {
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> remove(String key);
}
