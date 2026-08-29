import 'package:city_guide_app/core/api/api_result.dart';
import 'package:city_guide_app/core/error/failure.dart';
import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/explorer/data/data_source_contract/explorer_filter_preferences_datasource.dart';
import 'package:city_guide_app/features/explorer/data/model/explorer_filters_model.dart';
import 'package:city_guide_app/features/explorer/data/repo_impl/explorer_filter_preferences_repo_impl.dart';
import 'package:city_guide_app/features/explorer/domain/entity/explorer_filters.dart';
import 'package:city_guide_app/shared/domain/place_category.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDatasource extends Mock
    implements ExplorerFilterPreferencesDatasource {}

void main() {
  late _MockDatasource datasource;
  late ExplorerFilterPreferencesRepoImpl repo;

  setUpAll(
    () => registerFallbackValue(
      const ExplorerFiltersModel(category: 'cafe', radiusMeters: 3000),
    ),
  );

  setUp(() {
    datasource = _MockDatasource();
    repo = ExplorerFilterPreferencesRepoImpl(datasource);
  });

  test('uses defaults when no filters were persisted', () async {
    when(
      () => datasource.load(),
    ).thenAnswer((_) async => const ApiSuccess(null));

    final result = await repo.load();

    expect((result as Success<ExplorerFilters>).data, const ExplorerFilters());
  });

  test(
    'maps models and writes domain filters through the repository',
    () async {
      when(() => datasource.load()).thenAnswer(
        (_) async => const ApiSuccess(
          ExplorerFiltersModel(category: 'pharmacy', radiusMeters: 5000),
        ),
      );
      when(
        () => datasource.save(any()),
      ).thenAnswer((_) async => const ApiSuccess(null));

      final loaded = await repo.load();
      const filters = ExplorerFilters(
        category: PlaceCategory.pharmacy,
        radiusMeters: 5000,
      );
      final saved = await repo.save(filters);

      expect((loaded as Success<ExplorerFilters>).data, filters);
      expect(saved, isA<Success<void>>());
      final model =
          verify(() => datasource.save(captureAny())).captured.single
              as ExplorerFiltersModel;
      expect(model.category, 'pharmacy');
      expect(model.radiusMeters, 5000);
    },
  );

  test('maps local datasource failures into CacheFailure', () async {
    when(() => datasource.load()).thenAnswer(
      (_) async => const ApiFailure(
        ApiError(type: ApiErrorType.parsing, message: 'bad cache'),
      ),
    );

    final result = await repo.load();

    expect((result as Error<ExplorerFilters>).failure, isA<CacheFailure>());
  });
}
