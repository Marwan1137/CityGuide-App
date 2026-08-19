import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/city_search/domain/repo_contract/city_search_repo.dart';
import 'package:city_guide_app/shared/domain/search_center.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetSearchCenterUseCase {
  const GetSearchCenterUseCase(this._repo);

  final CitySearchRepo _repo;

  Future<AppResult<SearchCenter?>> call() => _repo.getPersistedSearchCenter();
}
