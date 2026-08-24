import 'package:city_guide_app/shared/domain/geo_point.dart';
import 'package:city_guide_app/shared/domain/place_category.dart';
import 'package:equatable/equatable.dart';
import 'package:city_guide_app/shared/domain/place_summary.dart';

extension CustomPlaceMapping on CustomPlace {
  PlaceSummary toPlaceSummary() => PlaceSummary(
    id: id,
    name: name,
    category: category,
    location: location,
    address: address,
  );
}

final class CustomPlace extends Equatable {
  const CustomPlace({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.createdAt,
    required this.updatedAt,
    this.address,
    this.note,
  });

  final String id;
  final String name;
  final PlaceCategory category;
  final GeoPoint location;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? address;
  final String? note;

  @override
  List<Object?> get props => [
    id,
    name,
    category,
    location,
    createdAt,
    updatedAt,
    address,
    note,
  ];
}