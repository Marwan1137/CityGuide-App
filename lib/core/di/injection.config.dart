// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:city_guide_app/core/api/api_executor.dart' as _i945;
import 'package:city_guide_app/core/api/api_manager.dart' as _i307;
import 'package:city_guide_app/core/config/app_config.dart' as _i310;
import 'package:city_guide_app/core/database/app_database.dart' as _i824;
import 'package:city_guide_app/core/di/register_module.dart' as _i378;
import 'package:city_guide_app/core/network/connectivity_network_info.dart'
    as _i534;
import 'package:city_guide_app/core/network/network_info.dart' as _i72;
import 'package:city_guide_app/core/services/supabase_session_service.dart'
    as _i151;
import 'package:city_guide_app/features/city_search/data/data_source_contract/city_search_datasource.dart'
    as _i529;
import 'package:city_guide_app/features/city_search/data/data_source_impl/local_city_search_datasource_impl.dart'
    as _i368;
import 'package:city_guide_app/features/city_search/data/data_source_impl/remote_city_search_datasource_impl.dart'
    as _i717;
import 'package:city_guide_app/features/city_search/data/data_source_impl/shared_preferences_city_search_store.dart'
    as _i903;
import 'package:city_guide_app/features/city_search/data/repo_impl/city_search_repo_impl.dart'
    as _i105;
import 'package:city_guide_app/features/city_search/domain/repo_contract/city_search_repo.dart'
    as _i730;
import 'package:city_guide_app/features/city_search/domain/use_cases/geocode_city_usecase.dart'
    as _i1035;
import 'package:city_guide_app/features/city_search/domain/use_cases/get_recent_city_usecase.dart'
    as _i521;
import 'package:city_guide_app/features/city_search/domain/use_cases/get_search_center_usecase.dart'
    as _i1062;
import 'package:city_guide_app/features/city_search/domain/use_cases/search_cities_usecase.dart'
    as _i624;
import 'package:city_guide_app/features/city_search/domain/use_cases/select_city_usecase.dart'
    as _i405;
import 'package:city_guide_app/features/city_search/presentation/view_model/city_search_cubit.dart'
    as _i109;
import 'package:city_guide_app/features/custom_places/data/repo_impl/custom_places_repo_impl.dart'
    as _i291;
import 'package:city_guide_app/features/custom_places/domain/repo_contract/custom_places_repo.dart'
    as _i644;
import 'package:city_guide_app/features/custom_places/domain/use_cases/create_custom_place_usecase.dart'
    as _i511;
import 'package:city_guide_app/features/custom_places/domain/use_cases/delete_custom_place_usecase.dart'
    as _i469;
import 'package:city_guide_app/features/custom_places/domain/use_cases/update_custom_place_usecase.dart'
    as _i349;
import 'package:city_guide_app/features/custom_places/domain/use_cases/watch_custom_places_usecase.dart'
    as _i322;
import 'package:city_guide_app/features/directions/data/data_source_contract/directions_launcher_gateway.dart'
    as _i426;
import 'package:city_guide_app/features/directions/data/data_source_impl/url_launcher_directions_gateway.dart'
    as _i631;
import 'package:city_guide_app/features/directions/data/repo_impl/directions_repo_impl.dart'
    as _i838;
import 'package:city_guide_app/features/directions/domain/repo_contract/directions_repo.dart'
    as _i970;
import 'package:city_guide_app/features/directions/domain/use_cases/open_directions_usecase.dart'
    as _i849;
import 'package:city_guide_app/features/explorer/data/data_source_contract/explorer_filter_preferences_datasource.dart'
    as _i229;
import 'package:city_guide_app/features/explorer/data/data_source_contract/nearby_places_datasource.dart'
    as _i745;
import 'package:city_guide_app/features/explorer/data/data_source_impl/local_explorer_filter_preferences_datasource_impl.dart'
    as _i759;
import 'package:city_guide_app/features/explorer/data/data_source_impl/remote_nearby_places_datasource_impl.dart'
    as _i872;
import 'package:city_guide_app/features/explorer/data/data_source_impl/shared_preferences_explorer_filter_store.dart'
    as _i990;
import 'package:city_guide_app/features/explorer/data/repo_impl/explorer_filter_preferences_repo_impl.dart'
    as _i749;
import 'package:city_guide_app/features/explorer/data/repo_impl/nearby_places_repo_impl.dart'
    as _i523;
import 'package:city_guide_app/features/explorer/domain/repo_contract/explorer_filter_preferences_repo.dart'
    as _i320;
import 'package:city_guide_app/features/explorer/domain/repo_contract/nearby_places_repo.dart'
    as _i263;
import 'package:city_guide_app/features/explorer/domain/use_cases/load_explorer_filters_usecase.dart'
    as _i566;
import 'package:city_guide_app/features/explorer/domain/use_cases/reset_explorer_filters_usecase.dart'
    as _i458;
import 'package:city_guide_app/features/explorer/domain/use_cases/save_explorer_filters_usecase.dart'
    as _i936;
import 'package:city_guide_app/features/explorer/domain/use_cases/search_nearby_places_usecase.dart'
    as _i942;
import 'package:city_guide_app/features/explorer/presentation/view_model/explorer_cubit.dart'
    as _i531;
import 'package:city_guide_app/features/favorites/data/repo_impl/favorites_repo_impl.dart'
    as _i242;
import 'package:city_guide_app/features/favorites/domain/repo_contract/favorites_repo.dart'
    as _i285;
import 'package:city_guide_app/features/favorites/domain/use_cases/toggle_favorite_usecase.dart'
    as _i99;
import 'package:city_guide_app/features/favorites/domain/use_cases/watch_favorites_usecase.dart'
    as _i150;
import 'package:city_guide_app/features/favorites/domain/use_cases/watch_is_favorite_usecase.dart'
    as _i823;
import 'package:city_guide_app/features/favorites/presentation/view_model/favorites_cubit.dart'
    as _i909;
import 'package:city_guide_app/features/location/data/data_source_contract/location_datasource.dart'
    as _i632;
import 'package:city_guide_app/features/location/data/data_source_contract/location_platform_gateway.dart'
    as _i798;
import 'package:city_guide_app/features/location/data/data_source_impl/geolocator_gateway.dart'
    as _i247;
import 'package:city_guide_app/features/location/data/data_source_impl/geolocator_location_datasource.dart'
    as _i1046;
import 'package:city_guide_app/features/location/data/data_source_impl/shared_preferences_permission_request_store.dart'
    as _i610;
import 'package:city_guide_app/features/location/data/repo_impl/location_repo_impl.dart'
    as _i28;
import 'package:city_guide_app/features/location/domain/repo_contract/location_repo.dart'
    as _i733;
import 'package:city_guide_app/features/location/domain/use_cases/check_location_access_usecase.dart'
    as _i792;
import 'package:city_guide_app/features/location/domain/use_cases/get_current_location_usecase.dart'
    as _i830;
import 'package:city_guide_app/features/location/domain/use_cases/open_location_settings_usecase.dart'
    as _i663;
import 'package:city_guide_app/features/location/domain/use_cases/request_location_access_usecase.dart'
    as _i1060;
import 'package:city_guide_app/features/location/presentation/view_model/location_cubit.dart'
    as _i154;
import 'package:city_guide_app/features/place_details/data/data_source_contract/directions_launcher_gateway.dart'
    as _i387;
import 'package:city_guide_app/features/place_details/data/data_source_contract/place_details_datasource.dart'
    as _i847;
import 'package:city_guide_app/features/place_details/data/data_source_impl/remote_place_details_datasource_impl.dart'
    as _i152;
import 'package:city_guide_app/features/place_details/data/data_source_impl/url_launcher_directions_gateway.dart'
    as _i620;
import 'package:city_guide_app/features/place_details/data/repo_impl/directions_repo_impl.dart'
    as _i1058;
import 'package:city_guide_app/features/place_details/data/repo_impl/place_details_repo_impl.dart'
    as _i595;
import 'package:city_guide_app/features/place_details/domain/repo_contract/directions_repo.dart'
    as _i299;
import 'package:city_guide_app/features/place_details/domain/repo_contract/place_details_repo.dart'
    as _i306;
import 'package:city_guide_app/features/place_details/domain/use_cases/get_place_detail_usecase.dart'
    as _i778;
import 'package:city_guide_app/features/place_details/domain/use_cases/open_directions_usecase.dart'
    as _i200;
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i945.ApiExecutor>(() => const _i945.ApiExecutor());
    gh.lazySingleton<_i824.AppDatabase>(() => _i824.AppDatabase());
    gh.lazySingleton<_i895.Connectivity>(() => registerModule.connectivity);
    gh.lazySingleton<_i310.AppConfig>(() => registerModule.appConfig);
    gh.lazySingleton<_i644.CustomPlacesRepo>(
      () => _i291.CustomPlacesRepoImpl(gh<_i824.AppDatabase>()),
    );
    gh.lazySingleton<_i285.FavoritesRepo>(
      () => _i242.FavoritesRepoImpl(gh<_i824.AppDatabase>()),
    );
    gh.lazySingleton<_i426.DirectionsLauncherGateway>(
      () => _i631.UrlLauncherDirectionsGateway(),
    );
    gh.lazySingleton<_i229.ExplorerFilterPreferencesStore>(
      () => _i990.SharedPreferencesExplorerFilterStore(),
    );
    gh.lazySingleton<_i798.LocationPlatformGateway>(
      () => _i247.GeolocatorGateway(),
    );
    gh.lazySingleton<_i387.DirectionsLauncherGateway>(
      () => _i620.UrlLauncherDirectionsGateway(),
    );
    gh.lazySingleton<_i798.PermissionRequestStore>(
      () => _i610.SharedPreferencesPermissionRequestStore(),
    );
    gh.lazySingleton<_i529.CitySearchPersistenceStore>(
      () => _i903.SharedPreferencesCitySearchStore(),
    );
    gh.factory<_i99.ToggleFavoriteUseCase>(
      () => _i99.ToggleFavoriteUseCase(gh<_i285.FavoritesRepo>()),
    );
    gh.factory<_i150.WatchFavoritesUseCase>(
      () => _i150.WatchFavoritesUseCase(gh<_i285.FavoritesRepo>()),
    );
    gh.factory<_i823.WatchIsFavoriteUseCase>(
      () => _i823.WatchIsFavoriteUseCase(gh<_i285.FavoritesRepo>()),
    );
    gh.lazySingleton<_i632.LocationDatasource>(
      () => _i1046.GeolocatorLocationDatasource(
        gh<_i945.ApiExecutor>(),
        gh<_i798.LocationPlatformGateway>(),
        gh<_i798.PermissionRequestStore>(),
      ),
    );
    gh.lazySingleton<_i970.DirectionsRepo>(
      () => _i838.DirectionsRepoImpl(
        gh<_i945.ApiExecutor>(),
        gh<_i426.DirectionsLauncherGateway>(),
      ),
    );
    gh.factory<_i849.OpenDirectionsUseCase>(
      () => _i849.OpenDirectionsUseCase(gh<_i970.DirectionsRepo>()),
    );
    gh.factory<_i511.CreateCustomPlaceUseCase>(
      () => _i511.CreateCustomPlaceUseCase(gh<_i644.CustomPlacesRepo>()),
    );
    gh.factory<_i469.DeleteCustomPlaceUseCase>(
      () => _i469.DeleteCustomPlaceUseCase(gh<_i644.CustomPlacesRepo>()),
    );
    gh.factory<_i349.UpdateCustomPlaceUseCase>(
      () => _i349.UpdateCustomPlaceUseCase(gh<_i644.CustomPlacesRepo>()),
    );
    gh.factory<_i322.WatchCustomPlacesUseCase>(
      () => _i322.WatchCustomPlacesUseCase(gh<_i644.CustomPlacesRepo>()),
    );
    gh.lazySingleton<_i299.DirectionsRepo>(
      () => _i1058.DirectionsRepoImpl(
        gh<_i945.ApiExecutor>(),
        gh<_i387.DirectionsLauncherGateway>(),
      ),
    );
    gh.lazySingleton<_i361.Dio>(
      () => registerModule.dio(gh<_i310.AppConfig>()),
    );
    gh.lazySingleton<_i529.LocalCitySearchDatasource>(
      () => _i368.LocalCitySearchDatasourceImpl(
        gh<_i945.ApiExecutor>(),
        gh<_i529.CitySearchPersistenceStore>(),
      ),
    );
    gh.factory<_i909.FavoritesCubit>(
      () => _i909.FavoritesCubit(gh<_i150.WatchFavoritesUseCase>()),
    );
    gh.lazySingleton<_i72.NetworkInfo>(
      () => _i534.ConnectivityNetworkInfo(gh<_i895.Connectivity>()),
    );
    gh.lazySingleton<_i151.SupabaseSessionService>(
      () => _i151.SupabaseSessionService(gh<_i310.AppConfig>()),
    );
    gh.lazySingleton<_i229.ExplorerFilterPreferencesDatasource>(
      () => _i759.LocalExplorerFilterPreferencesDatasourceImpl(
        gh<_i945.ApiExecutor>(),
        gh<_i229.ExplorerFilterPreferencesStore>(),
      ),
    );
    gh.lazySingleton<_i307.ApiManager>(
      () => _i307.ApiManager(gh<_i361.Dio>(), gh<_i945.ApiExecutor>()),
    );
    gh.lazySingleton<_i745.NearbyPlacesDatasource>(
      () => _i872.RemoteNearbyPlacesDatasourceImpl(
        gh<_i307.ApiManager>(),
        gh<_i310.AppConfig>(),
        gh<_i151.SupabaseSessionService>(),
      ),
    );
    gh.lazySingleton<_i847.PlaceDetailsDatasource>(
      () => _i152.RemotePlaceDetailsDatasourceImpl(
        gh<_i307.ApiManager>(),
        gh<_i310.AppConfig>(),
        gh<_i151.SupabaseSessionService>(),
      ),
    );
    gh.lazySingleton<_i529.RemoteCitySearchDatasource>(
      () => _i717.RemoteCitySearchDatasourceImpl(
        gh<_i307.ApiManager>(),
        gh<_i310.AppConfig>(),
        gh<_i151.SupabaseSessionService>(),
      ),
    );
    gh.lazySingleton<_i733.LocationRepo>(
      () => _i28.LocationRepoImpl(gh<_i632.LocationDatasource>()),
    );
    gh.lazySingleton<_i320.ExplorerFilterPreferencesRepo>(
      () => _i749.ExplorerFilterPreferencesRepoImpl(
        gh<_i229.ExplorerFilterPreferencesDatasource>(),
      ),
    );
    gh.lazySingleton<_i263.NearbyPlacesRepo>(
      () => _i523.NearbyPlacesRepoImpl(gh<_i745.NearbyPlacesDatasource>()),
    );
    gh.factory<_i792.CheckLocationAccessUseCase>(
      () => _i792.CheckLocationAccessUseCase(gh<_i733.LocationRepo>()),
    );
    gh.factory<_i830.GetCurrentLocationUseCase>(
      () => _i830.GetCurrentLocationUseCase(gh<_i733.LocationRepo>()),
    );
    gh.factory<_i663.OpenLocationSettingsUseCase>(
      () => _i663.OpenLocationSettingsUseCase(gh<_i733.LocationRepo>()),
    );
    gh.factory<_i1060.RequestLocationAccessUseCase>(
      () => _i1060.RequestLocationAccessUseCase(gh<_i733.LocationRepo>()),
    );
    gh.lazySingleton<_i306.PlaceDetailsRepo>(
      () => _i595.PlaceDetailsRepoImpl(gh<_i847.PlaceDetailsDatasource>()),
    );
    gh.factory<_i200.OpenDirectionsUseCase>(
      () => _i200.OpenDirectionsUseCase(gh<_i299.DirectionsRepo>()),
    );
    gh.lazySingleton<_i730.CitySearchRepo>(
      () => _i105.CitySearchRepoImpl(
        gh<_i529.LocalCitySearchDatasource>(),
        gh<_i529.RemoteCitySearchDatasource>(),
      ),
    );
    gh.factory<_i942.SearchNearbyPlacesUseCase>(
      () => _i942.SearchNearbyPlacesUseCase(gh<_i263.NearbyPlacesRepo>()),
    );
    gh.factory<_i566.LoadExplorerFiltersUseCase>(
      () => _i566.LoadExplorerFiltersUseCase(
        gh<_i320.ExplorerFilterPreferencesRepo>(),
      ),
    );
    gh.factory<_i458.ResetExplorerFiltersUseCase>(
      () => _i458.ResetExplorerFiltersUseCase(
        gh<_i320.ExplorerFilterPreferencesRepo>(),
      ),
    );
    gh.factory<_i936.SaveExplorerFiltersUseCase>(
      () => _i936.SaveExplorerFiltersUseCase(
        gh<_i320.ExplorerFilterPreferencesRepo>(),
      ),
    );
    gh.factory<_i778.GetPlaceDetailUseCase>(
      () => _i778.GetPlaceDetailUseCase(gh<_i306.PlaceDetailsRepo>()),
    );
    gh.factory<_i154.LocationCubit>(
      () => _i154.LocationCubit(
        gh<_i792.CheckLocationAccessUseCase>(),
        gh<_i1060.RequestLocationAccessUseCase>(),
        gh<_i830.GetCurrentLocationUseCase>(),
        gh<_i663.OpenLocationSettingsUseCase>(),
      ),
    );
    gh.factory<_i531.ExplorerCubit>(
      () => _i531.ExplorerCubit(
        gh<_i942.SearchNearbyPlacesUseCase>(),
        gh<_i566.LoadExplorerFiltersUseCase>(),
        gh<_i936.SaveExplorerFiltersUseCase>(),
        gh<_i458.ResetExplorerFiltersUseCase>(),
        gh<_i322.WatchCustomPlacesUseCase>(),
      ),
    );
    gh.factory<_i1035.GeocodeCityUseCase>(
      () => _i1035.GeocodeCityUseCase(gh<_i730.CitySearchRepo>()),
    );
    gh.factory<_i521.GetRecentCityUseCase>(
      () => _i521.GetRecentCityUseCase(gh<_i730.CitySearchRepo>()),
    );
    gh.factory<_i1062.GetSearchCenterUseCase>(
      () => _i1062.GetSearchCenterUseCase(gh<_i730.CitySearchRepo>()),
    );
    gh.factory<_i624.SearchCitiesUseCase>(
      () => _i624.SearchCitiesUseCase(gh<_i730.CitySearchRepo>()),
    );
    gh.factory<_i405.SelectCityUseCase>(
      () => _i405.SelectCityUseCase(gh<_i730.CitySearchRepo>()),
    );
    gh.factory<_i109.CitySearchCubit>(
      () => _i109.CitySearchCubit(
        gh<_i624.SearchCitiesUseCase>(),
        gh<_i1035.GeocodeCityUseCase>(),
        gh<_i521.GetRecentCityUseCase>(),
        gh<_i405.SelectCityUseCase>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i378.RegisterModule {}
