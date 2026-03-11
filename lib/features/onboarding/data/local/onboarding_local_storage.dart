import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/config/app_config.dart';

abstract interface class OnboardingLocalStorage {
  Future<bool> readIsCompleted();
  Future<void> writeIsCompleted(bool value);
}

class SharedPreferencesOnboardingLocalStorage
    implements OnboardingLocalStorage {
  SharedPreferencesOnboardingLocalStorage(this._preferences);

  final SharedPreferencesAsync _preferences;

  @override
  Future<bool> readIsCompleted() async {
    return await _preferences.getBool(AppConfig.onboardingStorageKey) ?? false;
  }

  @override
  Future<void> writeIsCompleted(bool value) {
    return _preferences.setBool(AppConfig.onboardingStorageKey, value);
  }
}
