import 'package:equatable/equatable.dart';

final class GeoPoint extends Equatable {
  const GeoPoint({required this.latitude, required this.longitude})
    : assert(latitude >= -90 && latitude <= 90),
      assert(longitude >= -180 && longitude <= 180);

  final double latitude;
  final double longitude;

  @override
  List<Object> get props => [latitude, longitude];
}
