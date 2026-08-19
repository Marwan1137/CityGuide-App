import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/location/domain/entity/location_access.dart';
import 'package:city_guide_app/features/location/domain/repo_contract/location_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class RequestLocationAccessUseCase {
  const RequestLocationAccessUseCase(this._repo);

  final LocationRepo _repo;

  Future<AppResult<LocationAccess>> call() => _repo.requestAccess();
}
