import 'package:city_guide_app/core/error/failure.dart';
import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/city_search/domain/entity/city.dart';
import 'package:city_guide_app/features/city_search/domain/repo_contract/city_search_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class GeocodeCityUseCase {
  const GeocodeCityUseCase(this._repo);

  final CitySearchRepo _repo;

  Future<AppResult<City>> call(String query) {
    final normalized = query.trim();
    if (normalized.length < 2 || normalized.length > 80) {
      return Future.value(
        const Error(
          ValidationFailure(
            'Enter a city name between 2 and 80 characters.',
            code: 'invalid_city_query',
          ),
        ),
      );
    }
    return _repo.geocodeUnknownCity(normalized);
  }
}
