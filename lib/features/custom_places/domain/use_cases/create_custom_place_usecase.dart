import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/custom_places/domain/repo_contract/custom_places_repo.dart';
import 'package:city_guide_app/shared/domain/geo_point.dart';
import 'package:city_guide_app/shared/domain/place_category.dart';
import 'package:injectable/injectable.dart';

@injectable
class CreateCustomPlaceUseCase {
  const CreateCustomPlaceUseCase(this._repo);

  final CustomPlacesRepo _repo;

  Future<AppResult<void>> call({
    required String name,
    required PlaceCategory category,
    required GeoPoint location,
    String? address,
    String? note,
  }) => _repo.createCustomPlace(
    name: name,
    category: category,
    location: location,
    address: address,
    note: note,
  );
}