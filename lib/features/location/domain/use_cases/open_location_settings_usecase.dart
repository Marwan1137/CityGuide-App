import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/location/domain/repo_contract/location_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class OpenLocationSettingsUseCase {
  const OpenLocationSettingsUseCase(this._repo);

  final LocationRepo _repo;

  Future<AppResult<bool>> openAppSettings() => _repo.openAppSettings();

  Future<AppResult<bool>> openLocationSettings() =>
      _repo.openLocationSettings();
}
