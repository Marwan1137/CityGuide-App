import 'package:city_guide_app/core/api/api_manager.dart';
import 'package:city_guide_app/core/api/api_result.dart';
import 'package:city_guide_app/core/config/app_config.dart';
import 'package:city_guide_app/core/services/supabase_session_service.dart';
import 'package:city_guide_app/features/explorer/data/data_source_contract/nearby_places_datasource.dart';
import 'package:city_guide_app/features/explorer/data/model/nearby_search_request_model.dart';
import 'package:city_guide_app/features/explorer/data/model/place_model.dart';
import 'package:city_guide_app/features/explorer/domain/entity/search_request_cancellation.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: NearbyPlacesDatasource)
class RemoteNearbyPlacesDatasourceImpl implements NearbyPlacesDatasource {
  const RemoteNearbyPlacesDatasourceImpl(
    this._apiManager,
    this._config,
    this._sessionService,
  );

  final ApiManager _apiManager;
  final AppConfig _config;
  final SupabaseSessionService _sessionService;

  @override
  Future<ApiResult<List<PlaceModel>>> searchNearby(
    NearbySearchRequestModel request, {
    SearchRequestCancellation? cancellation,
  }) async {
    final accessToken = await _sessionService.getAccessToken();
    if (accessToken == null) {
      return const ApiFailure(
        ApiError(
          type: ApiErrorType.unauthorized,
          message: 'Nearby search needs an active CityGuide session.',
        ),
      );
    }

    final url = '${_config.supabaseUrl}/functions/v1/places-nearby';
    final headers = {
      'authorization': 'Bearer $accessToken',
      'apikey': _config.supabasePublishableKey,
      'content-type': 'application/json',
    };
    final ApiResult<Map<String, dynamic>> result;
    if (cancellation == null) {
      result = await _apiManager.post(
        url,
        data: request.toJson(),
        headers: headers,
      );
    } else {
      final cancelToken = CancelToken();
      cancellation.onCancel(
        () => cancelToken.cancel('Superseded by a newer nearby search.'),
      );
      result = await _apiManager.post(
        url,
        data: request.toJson(),
        headers: headers,
        cancelToken: cancelToken,
      );
    }

    return result.fold(
      onSuccess: (json) {
        try {
          final data = json['data'];
          if (data is! Map<String, dynamic>) {
            throw const FormatException('Missing data object.');
          }
          final places = data['places'];
          if (places is! List) {
            throw const FormatException('Missing places list.');
          }
          return ApiSuccess(
            places
                .map(
                  (item) => PlaceModel.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ),
                )
                .toList(growable: false),
          );
        } on FormatException {
          return const ApiFailure(
            ApiError(
              type: ApiErrorType.parsing,
              message: 'Nearby places returned an unexpected response.',
            ),
          );
        } on TypeError {
          return const ApiFailure(
            ApiError(
              type: ApiErrorType.parsing,
              message: 'Nearby places returned an unexpected response.',
            ),
          );
        }
      },
      onFailure: (error) => ApiFailure(_friendlyError(error)),
    );
  }

  ApiError _friendlyError(ApiError error) => switch (error.statusCode) {
    400 => const ApiError(
      type: ApiErrorType.server,
      statusCode: 400,
      message: 'The selected nearby search is not supported.',
    ),
    429 => const ApiError(
      type: ApiErrorType.server,
      statusCode: 429,
      message: 'Nearby search is busy. Please wait a moment and try again.',
    ),
    504 => const ApiError(
      type: ApiErrorType.timeout,
      statusCode: 504,
      message: 'Nearby search took too long. Please try again.',
    ),
    _ => error,
  };
}
