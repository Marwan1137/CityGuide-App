import 'package:city_guide_app/core/error/failure.dart';
import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/location/domain/entity/location_access.dart';
import 'package:city_guide_app/features/location/domain/use_cases/check_location_access_usecase.dart';
import 'package:city_guide_app/features/location/domain/use_cases/get_current_location_usecase.dart';
import 'package:city_guide_app/features/location/domain/use_cases/open_location_settings_usecase.dart';
import 'package:city_guide_app/features/location/domain/use_cases/request_location_access_usecase.dart';
import 'package:city_guide_app/features/location/presentation/view_model/location_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class LocationCubit extends Cubit<LocationState> {
  LocationCubit(
    this._checkAccess,
    this._requestAccess,
    this._getCurrentLocation,
    this._openSettings,
  ) : super(const LocationLoading());

  final CheckLocationAccessUseCase _checkAccess;
  final RequestLocationAccessUseCase _requestAccess;
  final GetCurrentLocationUseCase _getCurrentLocation;
  final OpenLocationSettingsUseCase _openSettings;

  bool _waitingForSettingsReturn = false;

  Future<void> initialize() => _emitResult(_checkAccess());

  Future<void> retry() => initialize();

  Future<void> requestPermission() async {
    emit(const LocationLoading());
    final result = await _requestAccess();
    await result.fold(
      onSuccess: (access) async {
        if (access.canUseDeviceLocation) {
          await _emitResult(_getCurrentLocation(), showLoading: false);
        } else {
          emit(LocationLoaded(access));
        }
      },
      onFailure: (failure) async => emit(LocationError(failure.message)),
    );
  }

  Future<void> locateMe() => _emitResult(_getCurrentLocation());

  Future<void> openAppSettings() =>
      _openSettingsAndWait(_openSettings.openAppSettings());

  Future<void> openLocationSettings() =>
      _openSettingsAndWait(_openSettings.openLocationSettings());

  Future<void> onAppResumed() async {
    if (!_waitingForSettingsReturn) return;
    _waitingForSettingsReturn = false;
    await initialize();
  }

  Future<void> _openSettingsAndWait(Future<AppResult<bool>> result) async {
    final currentAccess = switch (state) {
      LocationLoaded(:final access) => access,
      _ => null,
    };
    final outcome = await result;
    outcome.fold(
      onSuccess: (opened) {
        if (opened) {
          _waitingForSettingsReturn = true;
          if (currentAccess != null) emit(LocationLoaded(currentAccess));
        } else {
          emit(
            const LocationError(
              'We could not open Settings. Please open it manually and return.',
            ),
          );
        }
      },
      onFailure: (failure) => emit(LocationError(failure.message)),
    );
  }

  Future<void> _emitResult(
    Future<AppResult<LocationAccess>> result, {
    bool showLoading = true,
  }) async {
    if (showLoading) emit(const LocationLoading());
    final outcome = await result;
    outcome.fold(
      onSuccess: (access) => emit(LocationLoaded(access)),
      onFailure: (failure) => emit(LocationError(_friendlyMessage(failure))),
    );
  }

  String _friendlyMessage(Failure failure) => failure.message.trim().isEmpty
      ? 'We could not check your location. Please try again.'
      : failure.message;
}
