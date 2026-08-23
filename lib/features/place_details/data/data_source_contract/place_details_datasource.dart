import 'package:city_guide_app/core/api/api_result.dart';
import 'package:city_guide_app/features/place_details/data/model/place_detail_model.dart';

abstract interface class PlaceDetailsDatasource {
  Future<ApiResult<PlaceDetailModel>> getPlaceDetail(String placeId);
}