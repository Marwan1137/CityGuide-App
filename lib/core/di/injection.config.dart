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
import 'package:city_guide_app/core/di/register_module.dart' as _i378;
import 'package:city_guide_app/core/services/supabase_session_service.dart'
    as _i150;
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
    gh.lazySingleton<_i310.AppConfig>(() => registerModule.appConfig);
    gh.lazySingleton<_i798.LocationPlatformGateway>(
      () => _i247.GeolocatorGateway(),
    );
    gh.lazySingleton<_i798.PermissionRequestStore>(
      () => _i610.SharedPreferencesPermissionRequestStore(),
    );
    gh.lazySingleton<_i632.LocationDatasource>(
      () => _i1046.GeolocatorLocationDatasource(
        gh<_i945.ApiExecutor>(),
        gh<_i798.LocationPlatformGateway>(),
        gh<_i798.PermissionRequestStore>(),
      ),
    );
    gh.lazySingleton<_i361.Dio>(
      () => registerModule.dio(gh<_i310.AppConfig>()),
    );
    gh.lazySingleton<_i150.SupabaseSessionService>(
      () => _i150.SupabaseSessionService(gh<_i310.AppConfig>()),
    );
    gh.lazySingleton<_i307.ApiManager>(
      () => _i307.ApiManager(gh<_i361.Dio>(), gh<_i945.ApiExecutor>()),
    );
    gh.lazySingleton<_i733.LocationRepo>(
      () => _i28.LocationRepoImpl(gh<_i632.LocationDatasource>()),
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
    gh.factory<_i154.LocationCubit>(
      () => _i154.LocationCubit(
        gh<_i792.CheckLocationAccessUseCase>(),
        gh<_i1060.RequestLocationAccessUseCase>(),
        gh<_i830.GetCurrentLocationUseCase>(),
        gh<_i663.OpenLocationSettingsUseCase>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i378.RegisterModule {}
