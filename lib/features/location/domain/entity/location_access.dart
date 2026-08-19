import 'package:city_guide_app/shared/domain/geo_point.dart';
import 'package:equatable/equatable.dart';

enum LocationAccessStatus {
  notRequested,
  granted,
  denied,
  permanentlyDenied,
  servicesDisabled,
  reducedAccuracy,
  timedOut,
}

final class LocationAccess extends Equatable {
  const LocationAccess({required this.status, this.point, this.accuracyMeters});

  final LocationAccessStatus status;
  final GeoPoint? point;
  final double? accuracyMeters;

  bool get canUseDeviceLocation =>
      status == LocationAccessStatus.granted ||
      status == LocationAccessStatus.reducedAccuracy;

  @override
  List<Object?> get props => [status, point, accuracyMeters];
}
