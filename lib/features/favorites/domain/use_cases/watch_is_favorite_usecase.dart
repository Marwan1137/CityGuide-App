import 'package:city_guide_app/features/favorites/domain/repo_contract/favorites_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class WatchIsFavoriteUseCase {
  const WatchIsFavoriteUseCase(this._repo);

  final FavoritesRepo _repo;

  Stream<bool> call(String placeId) => _repo.watchIsFavorite(placeId);
}