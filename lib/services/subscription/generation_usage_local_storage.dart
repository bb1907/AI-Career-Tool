import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/constants.dart';

final generationUsageLocalStorageProvider =
    Provider<GenerationUsageLocalStorage>(
      (ref) => SharedPreferencesGenerationUsageLocalStorage(
        SharedPreferencesAsync(),
      ),
    );

abstract interface class GenerationUsageLocalStorage {
  Future<int> readUsageCount(String userId);
  Future<void> writeUsageCount(String userId, int value);
}

class SharedPreferencesGenerationUsageLocalStorage
    implements GenerationUsageLocalStorage {
  SharedPreferencesGenerationUsageLocalStorage(this._preferences);

  final SharedPreferencesAsync _preferences;

  @override
  Future<int> readUsageCount(String userId) async {
    return await _preferences.getInt(_buildKey(userId)) ?? 0;
  }

  @override
  Future<void> writeUsageCount(String userId, int value) {
    return _preferences.setInt(_buildKey(userId), value);
  }

  String _buildKey(String userId) {
    return '${AppConstants.freeGenerationUsageStorageKeyPrefix}$userId';
  }
}
