import 'package:city_guide_app/core/api/api_result.dart';
import 'package:city_guide_app/features/explorer/data/model/nearby_search_request_model.dart';
import 'package:city_guide_app/features/explorer/data/model/place_model.dart';
import 'package:city_guide_app/features/explorer/domain/entity/search_request_cancellation.dart';

abstract interface class NearbyPlacesDatasource {
  Future<ApiResult<List<PlaceModel>>> searchNearby(
    NearbySearchRequestModel request, {
    SearchRequestCancellation? cancellation,
  });
}
