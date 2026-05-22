import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kAiDataConsentKey = 'consent_ai_data_v1';
const _kBiometricConsentKey = 'consent_biometric_v1';

class ConsentState {
  final bool aiDataGranted;
  final bool biometricGranted;

  const ConsentState({
    required this.aiDataGranted,
    required this.biometricGranted,
  });

  ConsentState copyWith({bool? aiDataGranted, bool? biometricGranted}) =>
      ConsentState(
        aiDataGranted: aiDataGranted ?? this.aiDataGranted,
        biometricGranted: biometricGranted ?? this.biometricGranted,
      );
}

class ConsentController extends AsyncNotifier<ConsentState> {
  @override
  Future<ConsentState> build() async {
    final prefs = await SharedPreferences.getInstance();
    return ConsentState(
      aiDataGranted: prefs.getBool(_kAiDataConsentKey) ?? false,
      biometricGranted: prefs.getBool(_kBiometricConsentKey) ?? false,
    );
  }

  Future<void> grantAiData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAiDataConsentKey, true);
    state = AsyncData(
      (state.value ??
              const ConsentState(aiDataGranted: false, biometricGranted: false))
          .copyWith(aiDataGranted: true),
    );
  }

  Future<void> revokeAiData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAiDataConsentKey, false);
    state = AsyncData(
      (state.value ??
              const ConsentState(aiDataGranted: false, biometricGranted: false))
          .copyWith(aiDataGranted: false),
    );
  }

  Future<void> grantBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kBiometricConsentKey, true);
    state = AsyncData(
      (state.value ??
              const ConsentState(aiDataGranted: false, biometricGranted: false))
          .copyWith(biometricGranted: true),
    );
  }

  Future<void> revokeBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kBiometricConsentKey, false);
    state = AsyncData(
      (state.value ??
              const ConsentState(aiDataGranted: false, biometricGranted: false))
          .copyWith(biometricGranted: false),
    );
  }

  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAiDataConsentKey);
    await prefs.remove(_kBiometricConsentKey);
    state = const AsyncData(
      ConsentState(aiDataGranted: false, biometricGranted: false),
    );
  }
}

final consentControllerProvider =
    AsyncNotifierProvider<ConsentController, ConsentState>(
      ConsentController.new,
    );
