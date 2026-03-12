import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  Future<void> writeBool(String key, bool value) {
    return _preferences.setBool(key, value);
  }

  Future<bool?> readBool(String key) {
    return _preferences.getBool(key);
  }
}
