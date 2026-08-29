import 'package:city_guide_app/core/api/api_executor.dart';
import 'package:city_guide_app/core/api/api_result.dart';
import 'package:city_guide_app/features/explorer/data/data_source_contract/explorer_filter_preferences_datasource.dart';
import 'package:city_guide_app/features/explorer/data/data_source_impl/local_explorer_filter_preferences_datasource_impl.dart';
import 'package:city_guide_app/features/explorer/data/model/explorer_filters_model.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryStore implements ExplorerFilterPreferencesStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> remove(String key) async => values.remove(key);

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}

void main() {
  late _MemoryStore store;
  late LocalExplorerFilterPreferencesDatasourceImpl datasource;

  setUp(() {
    store = _MemoryStore();
    datasource = LocalExplorerFilterPreferencesDatasourceImpl(
      const ApiExecutor(),
      store,
    );
  });

  test('returns null when no preferences were saved', () async {
    final result = await datasource.load();

    expect((result as ApiSuccess<ExplorerFiltersModel?>).data, isNull);
  });

  test('saves, restores, and resets supported filters', () async {
    const model = ExplorerFiltersModel(
      category: 'restaurant',
      radiusMeters: 10000,
    );

    expect(await datasource.save(model), isA<ApiSuccess<void>>());
    final loaded = await datasource.load();
    expect(
      (loaded as ApiSuccess<ExplorerFiltersModel?>).data?.category,
      'restaurant',
    );
    expect(loaded.data?.radiusMeters, 10000);

    expect(await datasource.reset(), isA<ApiSuccess<void>>());
    expect((await datasource.load() as ApiSuccess).data, isNull);
  });

  test('maps malformed persisted filters to an ApiFailure', () async {
    store.values['explorer_filters'] =
        '{"category":"cafe","radius_meters":2000}';

    final result = await datasource.load();

    expect(result, isA<ApiFailure<ExplorerFiltersModel?>>());
  });
}
