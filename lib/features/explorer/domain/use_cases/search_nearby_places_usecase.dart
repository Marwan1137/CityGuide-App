import 'package:city_guide_app/core/error/failure.dart';
import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/explorer/domain/entity/explorer_filters.dart';
import 'package:city_guide_app/features/explorer/domain/entity/nearby_search_request.dart';
import 'package:city_guide_app/features/explorer/domain/repo_contract/nearby_places_repo.dart';
import 'package:city_guide_app/shared/domain/place_summary.dart';
import 'package:injectable/injectable.dart';

@injectable
class SearchNearbyPlacesUseCase {
  const SearchNearbyPlacesUseCase(this._repo);

  final NearbyPlacesRepo _repo;

  Future<AppResult<List<PlaceSummary>>> call(NearbySearchRequest request) {
    if (!ExplorerFilters.supportedCategories.contains(request.category)) {
      return Future.value(
        const Error(ValidationFailure('Custom places are stored locally.')),
      );
    }
    if (!ExplorerFilters.supportedRadiiMeters.contains(request.radiusMeters)) {
      return Future.value(
        const Error(
          ValidationFailure('Search radius must be 1, 3, 5, or 10 km.'),
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
