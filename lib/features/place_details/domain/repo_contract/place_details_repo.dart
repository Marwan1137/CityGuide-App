import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/place_details/domain/entity/place_detail.dart';

abstract interface class PlaceDetailsRepo {
  Future<AppResult<PlaceDetail>> getPlaceDetail(String placeId);
}