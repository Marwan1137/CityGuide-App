import 'package:equatable/equatable.dart';

enum LocationAccessModelStatus {
  notRequested,
  granted,
  denied,
  permanentlyDenied,
  servicesDisabled,
  reducedAccuracy,
  timedOut,
}

final class LocationAccessModel extends Equatable {
  const LocationAccessModel({
    required this.status,
    this.latitude,
    this.longitude,
    this.accuracyMeters,
  });

  final LocationAccessModelStatus status;
  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;

  @override
  List<Object?> get props => [status, latitude, longitude, accuracyMeters];
}
