import 'package:city_guide_app/core/api/api_executor.dart';
import 'package:city_guide_app/core/api/api_result.dart';
import 'package:city_guide_app/core/error/failure.dart';
import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/place_details/data/data_source_contract/directions_launcher_gateway.dart';
import 'package:city_guide_app/features/place_details/domain/repo_contract/directions_repo.dart';
import 'package:city_guide_app/shared/domain/place_summary.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: DirectionsRepo)
class DirectionsRepoImpl implements DirectionsRepo {
  const DirectionsRepoImpl(this._executor, this._gateway);

  final ApiExecutor _executor;
  final DirectionsLauncherGateway _gateway;

  @override
  Future<AppResult<bool>> openDirections(PlaceSummary place) async {
    final result = await _executor.execute(
          () => _gateway.launchDirections(
        latitude: place.location.latitude,
        longitude: place.location.longitude,
        label: place.name,
      ),
    );
    return result.fold(
      onSuccess: Success.new,
      onFailure: (error) => Error(_mapFailure(error)),
    );
  }

  Failure _mapFailure(ApiError error) => switch (error.type) {
    ApiErrorType.network => NetworkFailure(error.message),
    _ => UnknownFailure(message: error.message),
  };
}