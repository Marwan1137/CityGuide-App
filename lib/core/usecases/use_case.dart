import 'package:city_guide_app/core/utils/app_result.dart';

abstract interface class UseCase<Output, Input> {
  Future<AppResult<Output>> call(Input input);
}

final class NoParams {
  const NoParams();
}
