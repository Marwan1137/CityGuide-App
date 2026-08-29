import 'package:city_guide_app/core/error/failure.dart';
import 'package:city_guide_app/features/city_search/domain/entity/city.dart';
import 'package:city_guide_app/features/city_search/domain/use_cases/geocode_city_usecase.dart';
import 'package:city_guide_app/features/city_search/domain/use_cases/get_recent_city_usecase.dart';
import 'package:city_guide_app/features/city_search/domain/use_cases/search_cities_usecase.dart';
import 'package:city_guide_app/features/city_search/domain/use_cases/select_city_usecase.dart';
import 'package:city_guide_app/features/city_search/presentation/view_model/city_search_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class CitySearchCubit extends Cubit<CitySearchState> {
  CitySearchCubit(
    this._searchCities,
    this._geocodeCity,
    this._getRecentCity,
    this._selectCity,
  ) : super(const CitySearchLoading());

  final SearchCitiesUseCase _searchCities;
  final GeocodeCityUseCase _geocodeCity;
  final GetRecentCityUseCase _getRecentCity;
  final SelectCityUseCase _selectCity;

  String _query = '';
  List<City> _cities = const [];
  City? _recentCity;
  bool _retryOnline = false;

  Future<void> initialize() async {
    emit(const CitySearchLoading());
    final recentResult = await _getRecentCity();
    recentResult.fold(
      onSuccess: (city) => _recentCity = city,
      onFailure: (_) => _recentCity = null,
    );
    await search('');
  }

  Future<void> search(String query) async {
    _retryOnline = false;
    _query = query.trim();
    final result = await _searchCities(_query);
    result.fold(
      onSuccess: (cities) {
        _cities = cities;
        emit(
          CitySearchLoaded(
            query: _query,
            cities: cities,
            recentCity: _recentCity,
          ),
        );
      },
      onFailure: (failure) => emit(CitySearchError(_message(failure))),
    );
  }

  Future<void> searchOnline() async {
    _retryOnline = true;
    emit(
      CitySearchLoaded(
        query: _query,
        cities: _cities,
        recentCity: _recentCity,
        isSearchingOnline: true,
      ),
    );
    final result = await _geocodeCity(_query);
    result.fold(
      onSuccess: (city) {
        _cities = [city];
        emit(
          CitySearchLoaded(
            query: _query,
            cities: _cities,
            recentCity: _recentCity,
          ),
        );
      },
      onFailure: (failure) => emit(CitySearchError(_message(failure))),
    );
  }

  Future<void> chooseCity(City city) async {
    emit(const CitySearchLoading());
    final result = await _selectCity(city);
    result.fold(
      onSuccess: (center) {
        _recentCity = city;
        emit(
          CitySearchLoaded(
            query: _query,
            cities: _cities,
            recentCity: city,
            selectedCenter: center,
          ),
        );
      },
      onFailure: (failure) => emit(CitySearchError(_message(failure))),
    );
  }

  Future<void> retry() => _retryOnline ? searchOnline() : initialize();

  String _message(Failure failure) => failure.message.trim().isEmpty
      ? 'City search is unavailable right now. Please try again.'
      : failure.message;
}
