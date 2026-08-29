import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/favorites/domain/repo_contract/favorites_repo.dart';
import 'package:city_guide_app/shared/domain/place_summary.dart';
import 'package:injectable/injectable.dart';

@injectable
class ToggleFavoriteUseCase {
  const ToggleFavoriteUseCase(this._repo);

  final FavoritesRepo _repo;

  Future<AppResult<void>> call(PlaceSummary place, {required bool isFavorite}) =>
      isFavorite ? _repo.removeFavorite(place.id) : _repo.addFavorite(place);
}