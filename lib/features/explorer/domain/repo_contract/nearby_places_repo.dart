import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/explorer/domain/entity/nearby_search_request.dart';
import 'package:city_guide_app/shared/domain/place_summary.dart';

abstract interface class NearbyPlacesRepo {
  Future<AppResult<List<PlaceSummary>>> searchNearby(
    NearbySearchRequest request,
  );
}
