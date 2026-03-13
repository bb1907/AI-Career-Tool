import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_analytics_service.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final service = FirebaseAnalyticsService();
  ref.onDispose(service.dispose);
  return service;
});

final analyticsBootstrapProvider = FutureProvider<void>((ref) async {
  await ref.read(analyticsServiceProvider).initialize();
});

abstract class AnalyticsService {
  const AnalyticsService();

  Future<void> initialize();

  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const <String, Object?>{},
  });

  Future<void> setUserId(String? userId);

  void dispose();
}
