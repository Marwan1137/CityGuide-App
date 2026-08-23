import 'package:city_guide_app/shared/domain/geo_point.dart';
import 'package:city_guide_app/shared/domain/place_category.dart';
import 'package:equatable/equatable.dart';

final class CustomPlaceFormState extends Equatable {
  const CustomPlaceFormState({
    required this.location,
    this.name = '',
    this.category = PlaceCategory.custom,
    this.address = '',
    this.note = '',
    this.isSaving = false,
    this.errorMessage,
    this.saved = false,
  });

  final GeoPoint location;
  final String name;
  final PlaceCategory category;
  final String address;
  final String note;
  final bool isSaving;
  final String? errorMessage;
  final bool saved;

  bool get canSave => name.trim().isNotEmpty && !isSaving;

  CustomPlaceFormState copyWith({
    GeoPoint? location,
    String? name,
    PlaceCategory? category,
    String? address,
    String? note,
    bool? isSaving,
    String? errorMessage,
    bool? saved,
  }) => CustomPlaceFormState(
    location: location ?? this.location,
    name: name ?? this.name,
    category: category ?? this.category,
    address: address ?? this.address,
    note: note ?? this.note,
    isSaving: isSaving ?? this.isSaving,
    errorMessage: errorMessage,
    saved: saved ?? this.saved,
  );

  @override
  List<Object?> get props => [
    location,
    name,
    category,
    address,
    note,
    isSaving,
    errorMessage,
    saved,
  ];
}