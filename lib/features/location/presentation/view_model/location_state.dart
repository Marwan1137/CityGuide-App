import 'package:city_guide_app/features/location/domain/entity/location_access.dart';
import 'package:equatable/equatable.dart';

sealed class LocationState extends Equatable {
  const LocationState();
}

final class LocationLoading extends LocationState {
  const LocationLoading();

  @override
  List<Object?> get props => [];
}

final class LocationLoaded extends LocationState {
  const LocationLoaded(this.access);

  final LocationAccess access;

  @override
  List<Object?> get props => [access];
}

final class LocationError extends LocationState {
  const LocationError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
