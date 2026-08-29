import 'package:city_guide_app/features/location/data/data_source_contract/location_platform_gateway.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@LazySingleton(as: PermissionRequestStore)
class SharedPreferencesPermissionRequestStore
    implements PermissionRequestStore {
  SharedPreferencesPermissionRequestStore()
    : _preferences = SharedPreferencesAsync();

  static const _key = 'location_permission_requested';

  final SharedPreferencesAsync _preferences;

  @override
  Future<void> markRequested() => _preferences.setBool(_key, true);

  @override
  Future<bool> wasRequested() async =>
      await _preferences.getBool(_key) ?? false;
}
