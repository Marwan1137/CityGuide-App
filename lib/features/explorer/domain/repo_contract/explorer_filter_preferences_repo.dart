import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/explorer/domain/entity/explorer_filters.dart';

abstract interface class ExplorerFilterPreferencesRepo {
  Future<AppResult<ExplorerFilters>> load();

  Future<AppResult<void>> save(ExplorerFilters filters);

  Future<AppResult<void>> reset();
}
