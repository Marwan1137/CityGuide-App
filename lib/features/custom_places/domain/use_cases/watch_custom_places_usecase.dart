import 'package:city_guide_app/features/custom_places/domain/entity/custom_place.dart';
import 'package:city_guide_app/features/custom_places/domain/repo_contract/custom_places_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class WatchCustomPlacesUseCase {
  const WatchCustomPlacesUseCase(this._repo);

  final CustomPlacesRepo _repo;

  Stream<List<CustomPlace>> call() => _repo.watchCustomPlaces();
}