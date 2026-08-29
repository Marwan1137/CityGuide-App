import 'package:city_guide_app/core/api/api_manager.dart';
import 'package:city_guide_app/core/api/api_result.dart';
import 'package:city_guide_app/core/config/app_config.dart';
import 'package:city_guide_app/core/services/supabase_session_service.dart';
import 'package:city_guide_app/features/city_search/data/data_source_contract/city_search_datasource.dart';
import 'package:city_guide_app/features/city_search/data/model/city_model.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: RemoteCitySearchDatasource)
class RemoteCitySearchDatasourceImpl implements RemoteCitySearchDatasource {
  const RemoteCitySearchDatasourceImpl(
    this._apiManager,
    this._config,
    this._sessionService,
  );

  final ApiManager _apiManager;
  final AppConfig _config;
  final SupabaseSessionService _sessionService;

  @override
  Future<ApiResult<CityModel>> geocode(String query) async {
    final accessToken = await _sessionService.getAccessToken();
    if (accessToken == null) {
      return const ApiFailure(
        ApiError(
          type: ApiErrorType.unauthorized,
          message:
              'City search needs an active session. Please check anonymous sign-in.',
        ),
      );
    }

    final result = await _apiManager.post(
      '${_config.supabaseUrl}/functions/v1/geocode-city',
      data: {'query': query},
      headers: {
        'authorization': 'Bearer $accessToken',
        'apikey': _config.supabasePublishableKey,
        'content-type': 'application/json',
      },
    );

    return result.fold(
      onSuccess: (json) {
        final data = json['data'];
        if (data is! Map<String, dynamic>) {
          return const ApiFailure(
            ApiError(
              type: ApiErrorType.parsing,
              message: 'The city service returned an unexpected response.',
            ),
          );
        }
        return ApiSuccess(CityModel.fromJson(data));
      },
      onFailure: (error) => ApiFailure(_friendlyRemoteError(error)),
    );
  }

  ApiError _friendlyRemoteError(ApiError error) => switch (error.statusCode) {
    404 => const ApiError(
      type: ApiErrorType.server,
      statusCode: 404,
      message: 'We could not find that city inside Egypt.',
    ),
    429 => const ApiError(
      type: ApiErrorType.server,
      statusCode: 429,
      message: 'City search is busy right now. Please try again later.',
    ),
    504 => const ApiError(
      type: ApiErrorType.timeout,
      statusCode: 504,
      message: 'City search took too long. Please try again.',
    ),
    _ => error,
  };
}
