import 'package:city_guide_app/shared/domain/place_category.dart';
import 'package:equatable/equatable.dart';

final class ExplorerFilters extends Equatable {
  const ExplorerFilters({
    this.category = PlaceCategory.cafe,
    this.radiusMeters = defaultRadiusMeters,
  });

  static const defaultRadiusMeters = 3000;
  static const supportedRadiiMeters = [1000, 3000, 5000, 10000];
  static const supportedCategories = [
    PlaceCategory.cafe,
    PlaceCategory.restaurant,
    PlaceCategory.pharmacy,
  ];

  final PlaceCategory category;
  final int radiusMeters;

  bool get isSupported =>
      supportedCategories.contains(category) &&
      supportedRadiiMeters.contains(radiusMeters);

  ExplorerFilters copyWith({PlaceCategory? category, int? radiusMeters}) =>
      ExplorerFilters(
        category: category ?? this.category,
        radiusMeters: radiusMeters ?? this.radiusMeters,
      );

  @override
  List<Object> get props => [category, radiusMeters];
}
