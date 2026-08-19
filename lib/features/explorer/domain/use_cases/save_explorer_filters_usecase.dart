import 'package:city_guide_app/core/error/failure.dart';
import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/explorer/domain/entity/explorer_filters.dart';
import 'package:city_guide_app/features/explorer/domain/repo_contract/explorer_filter_preferences_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class SaveExplorerFiltersUseCase {
  const SaveExplorerFiltersUseCase(this._repo);

  final ExplorerFilterPreferencesRepo _repo;

  Future<AppResult<void>> call(ExplorerFilters filters) {
    if (!filters.isSupported) {
      return Future.value(
        const Error(ValidationFailure('Unsupported Explorer filters.')),
      );
    }
    return _repo.save(filters);
  }
}
