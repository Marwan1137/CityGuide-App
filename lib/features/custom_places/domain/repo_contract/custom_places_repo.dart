import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/custom_places/domain/entity/custom_place.dart';
import 'package:city_guide_app/shared/domain/geo_point.dart';
import 'package:city_guide_app/shared/domain/place_category.dart';

abstract interface class CustomPlacesRepo {
  Stream<List<CustomPlace>> watchCustomPlaces();

  Future<AppResult<CustomPlace>> createCustomPlace({
    required String name,
    required PlaceCategory category,
    required GeoPoint location,
    String? address,
    String? note,
  });

  Future<AppResult<void>> updateCustomPlace({
    required String id,
    required String name,
    required PlaceCategory category,
    String? address,
    String? note,
  });

  Future<AppResult<void>> deleteCustomPlace(String id);
}