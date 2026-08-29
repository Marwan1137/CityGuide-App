import 'package:city_guide_app/core/api/api_result.dart';
import 'package:city_guide_app/core/error/failure.dart';
import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/city_search/data/data_source_contract/city_search_datasource.dart';
import 'package:city_guide_app/features/city_search/data/model/city_model.dart';
import 'package:city_guide_app/features/city_search/domain/entity/city.dart';
import 'package:city_guide_app/features/city_search/domain/repo_contract/city_search_repo.dart';
import 'package:city_guide_app/shared/domain/geo_point.dart';
import 'package:city_guide_app/shared/domain/search_center.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: CitySearchRepo)
class CitySearchRepoImpl implements CitySearchRepo {
  const CitySearchRepoImpl(this._localDatasource, this._remoteDatasource);

  final LocalCitySearchDatasource _localDatasource;
  final RemoteCitySearchDatasource _remoteDatasource;

  @override
  Future<AppResult<List<City>>> searchLocal(String query) async {
    final result = await _localDatasource.search(query);
    return result.fold(
      onSuccess: (models) =>
          Success(models.map(_toEntity).toList(growable: false)),
      onFailure: (error) => Error(_mapFailure(error)),
    );
  }

  @override
  Future<AppResult<City>> geocodeUnknownCity(String query) async {
    final result = await _remoteDatasource.geocode(query);
    return result.fold(
      onSuccess: (model) => Success(_toEntity(model)),
      onFailure: (error) => Error(_mapFailure(error)),
    );
  }

  @override
  Future<AppResult<City?>> getRecentCity() async {
    final result = await _localDatasource.getRecentCity();
    return result.fold(
      onSuccess: (model) => Success(model == null ? null : _toEntity(model)),
      onFailure: (error) => Error(_mapFailure(error)),
    );
  }

  @override
  Future<AppResult<SearchCenter?>> getPersistedSearchCenter() async {
    final result = await _localDatasource.getPersistedSearchCenter();
    return result.fold(
      onSuccess: (model) =>
          Success(model == null ? null : _toSearchCenter(model)),
      onFailure: (error) => Error(_mapFailure(error)),
    );
  }

  @override
  Future<AppResult<SearchCenter>> selectCity(City city) async {
    final model = _fromEntity(city);
    final recentResult = await _localDatasource.saveRecentCity(model);
    if (recentResult case ApiFailure<void>(:final error)) {
      return Error(_mapFailure(error));
    }

    final centerResult = await _localDatasource.saveSearchCenter(model);
    return centerResult.fold(
      onSuccess: (_) => Success(_toSearchCenter(model)),
      onFailure: (error) => Error(_mapFailure(error)),
    );
  }

  City _toEntity(CityModel model) => City(
    id: model.id,
    nameEn: model.nameEn,
    nameAr: model.nameAr,
    governorateEn: model.governorateEn,
    governorateAr: model.governorateAr,
    location: GeoPoint(latitude: model.latitude, longitude: model.longitude),
    isRemoteResult: model.isRemoteResult,
  );

  CityModel _fromEntity(City city) => CityModel(
    id: city.id,
    nameEn: city.nameEn,
    nameAr: city.nameAr,
    governorateEn: city.governorateEn,
    governorateAr: city.governorateAr,
    latitude: city.location.latitude,
    longitude: city.location.longitude,
    aliases: const [],
    isRemoteResult: city.isRemoteResult,
  );

  SearchCenter _toSearchCenter(CityModel model) => SearchCenter(
    point: GeoPoint(latitude: model.latitude, longitude: model.longitude),
    source: SearchCenterSource.selectedCity,
    label: model.nameEn,
  );

  Failure _mapFailure(ApiError error) => switch (error.type) {
    ApiErrorType.network => NetworkFailure(error.message),
    ApiErrorType.parsing => CacheFailure(error.message),
    ApiErrorType.unauthorized || ApiErrorType.server => ServerFailure(
      error.message,
      code: error.statusCode?.toString(),
    ),
    _ => UnknownFailure(message: error.message),
  };
}
