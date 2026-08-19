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
    gh.lazySingleton<_i361.Dio>(
      () => registerModule.dio(gh<_i310.AppConfig>()),
    );
    gh.lazySingleton<_i150.SupabaseSessionService>(
      () => _i150.SupabaseSessionService(gh<_i310.AppConfig>()),
    );
    gh.lazySingleton<_i307.ApiManager>(
      () => _i307.ApiManager(gh<_i361.Dio>(), gh<_i945.ApiExecutor>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i378.RegisterModule {}
