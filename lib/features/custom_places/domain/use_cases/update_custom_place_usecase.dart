import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/custom_places/domain/repo_contract/custom_places_repo.dart';
import 'package:city_guide_app/shared/domain/place_category.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdateCustomPlaceUseCase {
  const UpdateCustomPlaceUseCase(this._repo);

  final CustomPlacesRepo _repo;

  Future<AppResult<void>> call({
    required String id,
    required String name,
    required PlaceCategory category,
    String? address,
    String? note,
  }) => _repo.updateCustomPlace(
    id: id,
    name: name,
    category: category,
    address: address,
    note: note,
  );
}