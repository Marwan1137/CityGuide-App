import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/place_details/domain/entity/place_detail.dart';
import 'package:city_guide_app/features/place_details/domain/repo_contract/place_details_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetPlaceDetailUseCase {
  const GetPlaceDetailUseCase(this._repo);

  final PlaceDetailsRepo _repo;

  Future<AppResult<PlaceDetail>> call(String placeId) =>
      _repo.getPlaceDetail(placeId);
}