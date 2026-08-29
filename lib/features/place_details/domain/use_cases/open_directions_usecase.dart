import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/place_details/domain/repo_contract/directions_repo.dart';
import 'package:city_guide_app/shared/domain/place_summary.dart';
import 'package:injectable/injectable.dart';

@injectable
class OpenDirectionsUseCase {
  const OpenDirectionsUseCase(this._repo);

  final DirectionsRepo _repo;

  Future<AppResult<bool>> call(PlaceSummary place) =>
      _repo.openDirections(place);
}