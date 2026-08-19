import 'package:city_guide_app/features/city_search/domain/entity/city.dart';
import 'package:city_guide_app/shared/domain/search_center.dart';
import 'package:equatable/equatable.dart';

sealed class CitySearchState extends Equatable {
  const CitySearchState();
}

final class CitySearchLoading extends CitySearchState {
  const CitySearchLoading();

  @override
  List<Object?> get props => [];
}

final class CitySearchLoaded extends CitySearchState {
  const CitySearchLoaded({
    required this.query,
    required this.cities,
    this.recentCity,
    this.isSearchingOnline = false,
    this.selectedCenter,
  });

  final String query;
  final List<City> cities;
  final City? recentCity;
  final bool isSearchingOnline;
  final SearchCenter? selectedCenter;

  @override
  List<Object?> get props => [
    query,
    cities,
    recentCity,
    isSearchingOnline,
    selectedCenter,
  ];
}

final class CitySearchError extends CitySearchState {
  const CitySearchError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
