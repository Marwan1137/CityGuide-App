import 'dart:convert';

import 'package:city_guide_app/core/api/api_executor.dart';
import 'package:city_guide_app/core/api/api_result.dart';
import 'package:city_guide_app/features/explorer/data/data_source_contract/explorer_filter_preferences_datasource.dart';
import 'package:city_guide_app/features/explorer/data/model/explorer_filters_model.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ExplorerFilterPreferencesDatasource)
class LocalExplorerFilterPreferencesDatasourceImpl
    implements ExplorerFilterPreferencesDatasource {
  const LocalExplorerFilterPreferencesDatasourceImpl(
    this._executor,
    this._store,
  );

  static const _key = 'explorer_filters';

  final ApiExecutor _executor;
  final ExplorerFilterPreferencesStore _store;

  @override
  Future<ApiResult<ExplorerFiltersModel?>> load() =>
      _executor.execute(() async {
        final value = await _store.read(_key);
        if (value == null || value.isEmpty) return null;
        return ExplorerFiltersModel.fromJson(
          jsonDecode(value) as Map<String, dynamic>,
        );
      });

  @override
  Future<ApiResult<void>> save(ExplorerFiltersModel filters) =>
      _executor.execute(() => _store.write(_key, jsonEncode(filters.toJson())));

  @override
  Future<ApiResult<void>> reset() =>
      _executor.execute(() => _store.remove(_key));
}
