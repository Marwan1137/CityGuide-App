import 'package:city_guide_app/core/api/api_manager.dart';
import 'package:city_guide_app/core/api/api_result.dart';
import 'package:city_guide_app/core/config/app_config.dart';
import 'package:city_guide_app/core/services/supabase_session_service.dart';
import 'package:city_guide_app/features/place_details/data/data_source_contract/place_details_datasource.dart';
import 'package:city_guide_app/features/place_details/data/model/place_detail_model.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: PlaceDetailsDatasource)
class RemotePlaceDetailsDatasourceImpl implements PlaceDetailsDatasource {
  const RemotePlaceDetailsDatasourceImpl(
      this._apiManager,
      this._config,
      this._sessionService,
      );

  final ApiManager _apiManager;
  final AppConfig _config;
  final SupabaseSessionService _sessionService;

  @override
  Future<ApiResult<PlaceDetailModel>> getPlaceDetail(String placeId) async {
    final accessToken = await _sessionService.getAccessToken();
    if (accessToken == null) {
      return const ApiFailure(
        ApiError(
          type: ApiErrorType.unauthorized,
          message: 'Place details needs an active CityGuide session.',
        ),
      );
    }

    final url = '${_config.supabaseUrl}/functions/v1/places-details';
    final headers = {
      'authorization': 'Bearer $accessToken',
      'apikey': _config.supabasePublishableKey,
      'content-type': 'application/json',
    };
    final result = await _apiManager.post(
      url,
      data: {'place_id': placeId},
      headers: headers,
    );

    return result.fold(
      onSuccess: (json) {
        try {
          final data = json['data'];
          if (data is! Map<String, dynamic>) {
            throw const FormatException('Missing data object.');
          }
          return ApiSuccess(PlaceDetailModel.fromJson(data));
        } on FormatException {
          return const ApiFailure(
            ApiError(
              type: ApiErrorType.parsing,
              message: 'Place details returned an unexpected response.',
            ),
          );
        } on TypeError {
          return const ApiFailure(
            ApiError(
              type: ApiErrorType.parsing,
              message: 'Place details returned an unexpected response.',
            ),
          );
        }
      },
      onFailure: (error) => ApiFailure(error),
    );
  }
}