import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/explorer/domain/repo_contract/explorer_filter_preferences_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class ResetExplorerFiltersUseCase {
  const ResetExplorerFiltersUseCase(this._repo);

  final ExplorerFilterPreferencesRepo _repo;

  Future<AppResult<void>> call() => _repo.reset();
}
