import 'package:city_guide_app/features/city_search/data/data_source_contract/city_search_datasource.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@LazySingleton(as: CitySearchPersistenceStore)
class SharedPreferencesCitySearchStore implements CitySearchPersistenceStore {
  SharedPreferencesCitySearchStore() : _preferences = SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  @override
  Future<String?> read(String key) => _preferences.getString(key);

  @override
  Future<void> write(String key, String value) =>
      _preferences.setString(key, value);
}
