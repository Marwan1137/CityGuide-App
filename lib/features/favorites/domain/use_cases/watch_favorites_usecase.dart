import 'package:city_guide_app/features/favorites/domain/entity/favorite.dart';
import 'package:city_guide_app/features/favorites/domain/repo_contract/favorites_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class WatchFavoritesUseCase {
  const WatchFavoritesUseCase(this._repo);

  final FavoritesRepo _repo;

  Stream<List<Favorite>> call() => _repo.watchFavorites();
}