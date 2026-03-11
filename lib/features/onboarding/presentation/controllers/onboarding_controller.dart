import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/local/onboarding_local_storage.dart';

final onboardingLocalStorageProvider = Provider<OnboardingLocalStorage>(
  (ref) => SharedPreferencesOnboardingLocalStorage(SharedPreferencesAsync()),
);

final onboardingControllerProvider =
    AsyncNotifierProvider<OnboardingController, bool>(OnboardingController.new);

class OnboardingController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() {
    return ref.read(onboardingLocalStorageProvider).readIsCompleted();
  }

  Future<void> completeOnboarding() async {
    await ref.read(onboardingLocalStorageProvider).writeIsCompleted(true);
    state = const AsyncData(true);
  }
}
