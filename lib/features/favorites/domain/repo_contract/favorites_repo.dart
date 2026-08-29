import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/favorites/domain/entity/favorite.dart';
import 'package:city_guide_app/shared/domain/place_summary.dart';

abstract interface class FavoritesRepo {
  Stream<List<Favorite>> watchFavorites();
  Stream<bool> watchIsFavorite(String placeId);
  Future<AppResult<void>> addFavorite(PlaceSummary place);
  Future<AppResult<void>> removeFavorite(String placeId);
}