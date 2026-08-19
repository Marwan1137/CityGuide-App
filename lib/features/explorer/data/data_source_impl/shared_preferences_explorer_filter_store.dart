import 'package:city_guide_app/features/explorer/data/data_source_contract/explorer_filter_preferences_datasource.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@LazySingleton(as: ExplorerFilterPreferencesStore)
class SharedPreferencesExplorerFilterStore
    implements ExplorerFilterPreferencesStore {
  SharedPreferencesExplorerFilterStore()
    : _preferences = SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  @override
  Future<String?> read(String key) => _preferences.getString(key);

  @override
  Future<void> remove(String key) => _preferences.remove(key);

  @override
  Future<void> write(String key, String value) =>
      _preferences.setString(key, value);
}
