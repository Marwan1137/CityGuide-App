import 'package:bloc_test/bloc_test.dart';
import 'package:city_guide_app/core/error/failure.dart';
import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/city_search/domain/entity/city.dart';
import 'package:city_guide_app/features/city_search/domain/repo_contract/city_search_repo.dart';
import 'package:city_guide_app/features/city_search/domain/use_cases/geocode_city_usecase.dart';
import 'package:city_guide_app/features/city_search/domain/use_cases/get_recent_city_usecase.dart';
import 'package:city_guide_app/features/city_search/domain/use_cases/search_cities_usecase.dart';
import 'package:city_guide_app/features/city_search/domain/use_cases/select_city_usecase.dart';
import 'package:city_guide_app/features/city_search/presentation/view_model/city_search_cubit.dart';
import 'package:city_guide_app/features/city_search/presentation/view_model/city_search_state.dart';
import 'package:city_guide_app/shared/domain/geo_point.dart';
import 'package:city_guide_app/shared/domain/search_center.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCitySearchRepo extends Mock implements CitySearchRepo {}

void main() {
  late _MockCitySearchRepo repo;

  const cairo = City(
    id: 'cairo',
    nameEn: 'Cairo',
    nameAr: 'القاهرة',
    governorateEn: 'Cairo',
    governorateAr: 'القاهرة',
    location: GeoPoint(latitude: 30.0444, longitude: 31.2357),
  );
  const zamalek = City(
    id: 'google:zamalek',
    nameEn: 'Zamalek',
    nameAr: 'الزمالك',
    governorateEn: 'Cairo Governorate',
    governorateAr: '',
    location: GeoPoint(latitude: 30.0626, longitude: 31.2197),
    isRemoteResult: true,
  );
  const cairoCenter = SearchCenter(
    point: GeoPoint(latitude: 30.0444, longitude: 31.2357),
    source: SearchCenterSource.selectedCity,
    label: 'Cairo',
  );

  CitySearchCubit buildCubit() => CitySearchCubit(
    SearchCitiesUseCase(repo),
    GeocodeCityUseCase(repo),
    GetRecentCityUseCase(repo),
    SelectCityUseCase(repo),
  );

  setUp(() {
    repo = _MockCitySearchRepo();
    when(
      () => repo.getRecentCity(),
    ).thenAnswer((_) async => const Success(null));
  });

  blocTest<CitySearchCubit, CitySearchState>(
    'initializes with the offline capital catalog',
    build: () {
      when(
        () => repo.searchLocal(''),
      ).thenAnswer((_) async => const Success([cairo]));
      return buildCubit();
    },
    act: (cubit) => cubit.initialize(),
    expect: () => const [
      CitySearchLoading(),
      CitySearchLoaded(query: '', cities: [cairo]),
    ],
  );

  blocTest<CitySearchCubit, CitySearchState>(
    'searches English or Arabic aliases locally',
    build: () {
      when(
        () => repo.searchLocal('القاهرة'),
      ).thenAnswer((_) async => const Success([cairo]));
      return buildCubit();
    },
    act: (cubit) => cubit.search('القاهرة'),
    expect: () => const [
      CitySearchLoaded(query: 'القاهرة', cities: [cairo]),
    ],
  );

  blocTest<CitySearchCubit, CitySearchState>(
    'uses remote geocoding only after explicit online search',
    build: () {
      when(
        () => repo.searchLocal('Zamalek'),
      ).thenAnswer((_) async => const Success([]));
      when(
        () => repo.geocodeUnknownCity('Zamalek'),
      ).thenAnswer((_) async => const Success(zamalek));
      return buildCubit();
    },
    act: (cubit) async {
      await cubit.search('Zamalek');
      await cubit.searchOnline();
    },
    expect: () => const [
      CitySearchLoaded(query: 'Zamalek', cities: []),
      CitySearchLoaded(query: 'Zamalek', cities: [], isSearchingOnline: true),
      CitySearchLoaded(query: 'Zamalek', cities: [zamalek]),
    ],
    verify: (_) => verify(() => repo.geocodeUnknownCity('Zamalek')).called(1),
  );

  blocTest<CitySearchCubit, CitySearchState>(
    'persists a selected city and exposes its SearchCenter',
    build: () {
      when(
        () => repo.selectCity(cairo),
      ).thenAnswer((_) async => const Success(cairoCenter));
      return buildCubit();
    },
    act: (cubit) => cubit.chooseCity(cairo),
    expect: () => const [
      CitySearchLoading(),
      CitySearchLoaded(
        query: '',
        cities: [],
        recentCity: cairo,
        selectedCenter: cairoCenter,
      ),
    ],
  );

  blocTest<CitySearchCubit, CitySearchState>(
    'shows a friendly quota error',
    build: () {
      when(
        () => repo.searchLocal('Zamalek'),
      ).thenAnswer((_) async => const Success([]));
      when(() => repo.geocodeUnknownCity('Zamalek')).thenAnswer(
        (_) async =>
            const Error(ServerFailure('City search is busy right now.')),
      );
      return buildCubit();
    },
    act: (cubit) async {
      await cubit.search('Zamalek');
      await cubit.searchOnline();
    },
    expect: () => const [
      CitySearchLoaded(query: 'Zamalek', cities: []),
      CitySearchLoaded(query: 'Zamalek', cities: [], isSearchingOnline: true),
      CitySearchError('City search is busy right now.'),
    ],
  );
}
