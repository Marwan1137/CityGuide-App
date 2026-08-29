import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/shared/domain/place_summary.dart';

abstract interface class DirectionsRepo {
  Future<AppResult<bool>> openDirections(PlaceSummary place);
}