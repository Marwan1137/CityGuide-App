import 'package:city_guide_app/features/explorer/domain/entity/explorer_filters.dart';
import 'package:city_guide_app/shared/domain/place_category.dart';

final class ExplorerFiltersModel {
  const ExplorerFiltersModel({
    required this.category,
    required this.radiusMeters,
  });

  factory ExplorerFiltersModel.fromEntity(ExplorerFilters filters) =>
      ExplorerFiltersModel(
        category: filters.category.name,
        radiusMeters: filters.radiusMeters,
      );

  factory ExplorerFiltersModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'];
    final radiusMeters = json['radius_meters'];
    if (category is! String || radiusMeters is! int) {
      throw const FormatException('Invalid Explorer filters.');
    }
    final model = ExplorerFiltersModel(
      category: category,
      radiusMeters: radiusMeters,
    );
    model.toEntity();
    return model;
  }

  final String category;
  final int radiusMeters;

  Map<String, Object> toJson() => {
    'category': category,
    'radius_meters': radiusMeters,
  };

  ExplorerFilters toEntity() {
    final parsedCategory = PlaceCategory.values
        .where((value) => value.name == category)
        .firstOrNull;
    final filters = ExplorerFilters(
      category: parsedCategory ?? PlaceCategory.custom,
      radiusMeters: radiusMeters,
    );
    if (!filters.isSupported) {
      throw const FormatException('Unsupported Explorer filters.');
    }
    return filters;
  }
}
