import 'package:city_guide_app/shared/domain/geo_point.dart';
import 'package:city_guide_app/shared/domain/place_category.dart';
import 'package:equatable/equatable.dart';

final class PlaceSummary extends Equatable {
  const PlaceSummary({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    this.address,
    this.note,
    this.rating,
    this.photoUrl,
    this.distanceMeters,
  });

  final String id;
  final String name;
  final PlaceCategory category;
  final GeoPoint location;
  final String? address;
  final String? note;
  final double? rating;
  final String? photoUrl;
  final double? distanceMeters;

  @override
  List<Object?> get props => [
    id,
    name,
    category,
    location,
    address,
    note,
    rating,
    photoUrl,
    distanceMeters,
  ];
}
