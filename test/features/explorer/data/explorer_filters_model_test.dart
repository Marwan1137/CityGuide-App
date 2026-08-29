import 'package:city_guide_app/features/explorer/data/model/explorer_filters_model.dart';
import 'package:city_guide_app/features/explorer/domain/entity/explorer_filters.dart';
import 'package:city_guide_app/shared/domain/place_category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps supported preferences between data and domain', () {
    const filters = ExplorerFilters(
      category: PlaceCategory.pharmacy,
      radiusMeters: 5000,
    );

    final model = ExplorerFiltersModel.fromEntity(filters);
    final restored = ExplorerFiltersModel.fromJson(model.toJson()).toEntity();

    expect(restored, filters);
  });

  test('rejects unsupported persisted category and radius', () {
    expect(
      () => ExplorerFiltersModel.fromJson(const {
        'category': 'custom',
        'radius_meters': 3000,
      }),
      throwsFormatException,
    );
    expect(
      () => ExplorerFiltersModel.fromJson(const {
        'category': 'cafe',
        'radius_meters': 2000,
      }),
      throwsFormatException,
    );
  });
}
