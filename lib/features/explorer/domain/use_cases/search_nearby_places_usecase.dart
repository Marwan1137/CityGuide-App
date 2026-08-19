import 'package:city_guide_app/core/error/failure.dart';
import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/explorer/domain/entity/nearby_search_request.dart';
import 'package:city_guide_app/features/explorer/domain/repo_contract/nearby_places_repo.dart';
import 'package:city_guide_app/shared/domain/place_category.dart';
import 'package:city_guide_app/shared/domain/place_summary.dart';
import 'package:injectable/injectable.dart';

@injectable
class SearchNearbyPlacesUseCase {
  const SearchNearbyPlacesUseCase(this._repo);

  final NearbyPlacesRepo _repo;

  Future<AppResult<List<PlaceSummary>>> call(NearbySearchRequest request) {
    if (request.category == PlaceCategory.custom) {
      return Future.value(
        const Error(ValidationFailure('Custom places are stored locally.')),
      );
    }
    if (request.radiusMeters < 100 || request.radiusMeters > 10000) {
      return Future.value(
        const Error(
          ValidationFailure('Search radius must be between 100 m and 10 km.'),
        ),
      );
    }
    if (request.maxResults < 1 || request.maxResults > 20) {
      return Future.value(
        const Error(
          ValidationFailure(
            'Nearby search can return between 1 and 20 places.',
          ),
        ),
      );
    }
    return _repo.searchNearby(request);
  }
}
