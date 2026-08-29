import 'package:city_guide_app/core/error/failure.dart';
import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/city_search/domain/entity/city.dart';
import 'package:city_guide_app/features/city_search/domain/repo_contract/city_search_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class SearchCitiesUseCase {
  const SearchCitiesUseCase(this._repo);

  final CitySearchRepo _repo;

  Future<AppResult<List<City>>> call(String query) {
    if (query.trim().length > 80) {
      return Future.value(
        const Error(
          ValidationFailure(
            'Keep your city search under 80 characters.',
            code: 'query_too_long',
          ),
        ),
      );
    }
    return _repo.searchLocal(query.trim());
  }
}
