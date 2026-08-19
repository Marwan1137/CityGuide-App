import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/city_search/domain/entity/city.dart';
import 'package:city_guide_app/features/city_search/domain/repo_contract/city_search_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetRecentCityUseCase {
  const GetRecentCityUseCase(this._repo);

  final CitySearchRepo _repo;

  Future<AppResult<City?>> call() => _repo.getRecentCity();
}
