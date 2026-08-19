import 'package:city_guide_app/core/api/api_result.dart';
import 'package:city_guide_app/core/error/failure.dart';
import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/explorer/data/data_source_contract/explorer_filter_preferences_datasource.dart';
import 'package:city_guide_app/features/explorer/data/model/explorer_filters_model.dart';
import 'package:city_guide_app/features/explorer/domain/entity/explorer_filters.dart';
import 'package:city_guide_app/features/explorer/domain/repo_contract/explorer_filter_preferences_repo.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ExplorerFilterPreferencesRepo)
class ExplorerFilterPreferencesRepoImpl
    implements ExplorerFilterPreferencesRepo {
  const ExplorerFilterPreferencesRepoImpl(this._datasource);

  final ExplorerFilterPreferencesDatasource _datasource;

  @override
  Future<AppResult<ExplorerFilters>> load() async {
    final result = await _datasource.load();
    return result.fold(
      onSuccess: (model) =>
          Success(model?.toEntity() ?? const ExplorerFilters()),
      onFailure: (error) => Error(_mapFailure(error)),
    );
  }

  @override
  Future<AppResult<void>> save(ExplorerFilters filters) async {
    final result = await _datasource.save(
      ExplorerFiltersModel.fromEntity(filters),
    );
    return result.fold(
      onSuccess: (_) => const Success(null),
      onFailure: (error) => Error(_mapFailure(error)),
    );
  }

  @override
  Future<AppResult<void>> reset() async {
    final result = await _datasource.reset();
    return result.fold(
      onSuccess: (_) => const Success(null),
      onFailure: (error) => Error(_mapFailure(error)),
    );
  }

  Failure _mapFailure(ApiError error) => CacheFailure(error.message);
}
