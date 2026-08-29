import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/custom_places/domain/repo_contract/custom_places_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class DeleteCustomPlaceUseCase {
  const DeleteCustomPlaceUseCase(this._repo);

  final CustomPlacesRepo _repo;

  Future<AppResult<void>> call(String id) => _repo.deleteCustomPlace(id);
}