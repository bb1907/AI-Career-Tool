import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/constants.dart';
import 'generation_usage_local_storage.dart';
import 'premium_access_feature.dart';

final premiumAccessServiceProvider = Provider<PremiumAccessService>(
  (ref) =>
      LocalPremiumAccessService(ref.watch(generationUsageLocalStorageProvider)),
);

class PremiumAccessSnapshot {
  const PremiumAccessSnapshot({
    required this.userId,
    required this.isPremium,
    required this.usedFreeGenerations,
    this.freeGenerationLimit = AppConstants.freeGenerationsLimit,
  });

  final String? userId;
  final bool isPremium;
  final int usedFreeGenerations;
  final int freeGenerationLimit;

  int get remainingFreeGenerations =>
      math.max(0, freeGenerationLimit - usedFreeGenerations);

  bool get hasReachedLimit =>
      !isPremium && usedFreeGenerations >= freeGenerationLimit;
}

class PremiumAccessDecision {
  const PremiumAccessDecision({
    required this.feature,
    required this.snapshot,
    required this.isAllowed,
    this.message,
  });

  final PremiumAccessFeature feature;
  final PremiumAccessSnapshot snapshot;
  final bool isAllowed;
  final String? message;

  bool get requiresPaywall => !isAllowed;
}

abstract class PremiumAccessService {
  const PremiumAccessService();

  Future<PremiumAccessSnapshot> loadSnapshot({
    required String? userId,
    required bool isPremium,
  });

  Future<PremiumAccessDecision> evaluateAccess({
    required String? userId,
    required bool isPremium,
    required PremiumAccessFeature feature,
  });

  Future<PremiumAccessSnapshot> recordSuccessfulUse({
    required String? userId,
    required bool isPremium,
    required PremiumAccessFeature feature,
  });
}

class LocalPremiumAccessService implements PremiumAccessService {
  const LocalPremiumAccessService(this._localStorage);

  final GenerationUsageLocalStorage _localStorage;

  @override
  Future<PremiumAccessSnapshot> loadSnapshot({
    required String? userId,
    required bool isPremium,
  }) async {
    final normalizedUserId = _normalizeUserId(userId);
    if (normalizedUserId == null) {
      return PremiumAccessSnapshot(
        userId: null,
        isPremium: isPremium,
        usedFreeGenerations: 0,
      );
    }

    final usedFreeGenerations = await _localStorage.readUsageCount(
      normalizedUserId,
    );

    return PremiumAccessSnapshot(
      userId: normalizedUserId,
      isPremium: isPremium,
      usedFreeGenerations: usedFreeGenerations,
    );
  }

  @override
  Future<PremiumAccessDecision> evaluateAccess({
    required String? userId,
    required bool isPremium,
    required PremiumAccessFeature feature,
  }) async {
    final snapshot = await loadSnapshot(userId: userId, isPremium: isPremium);

    if (snapshot.isPremium || !snapshot.hasReachedLimit) {
      return PremiumAccessDecision(
        feature: feature,
        snapshot: snapshot,
        isAllowed: true,
      );
    }

    return PremiumAccessDecision(
      feature: feature,
      snapshot: snapshot,
      isAllowed: false,
      message:
          'You have used all ${snapshot.freeGenerationLimit} free generations. Upgrade to continue with ${feature.label}.',
    );
  }

  @override
  Future<PremiumAccessSnapshot> recordSuccessfulUse({
    required String? userId,
    required bool isPremium,
    required PremiumAccessFeature feature,
  }) async {
    final snapshot = await loadSnapshot(userId: userId, isPremium: isPremium);

    if (snapshot.isPremium || snapshot.userId == null) {
      return snapshot;
    }

    final nextUsageCount = snapshot.usedFreeGenerations + 1;
    await _localStorage.writeUsageCount(snapshot.userId!, nextUsageCount);

    return PremiumAccessSnapshot(
      userId: snapshot.userId,
      isPremium: false,
      usedFreeGenerations: nextUsageCount,
    );
  }

  String? _normalizeUserId(String? userId) {
    final normalizedUserId = userId?.trim() ?? '';
    return normalizedUserId.isEmpty ? null : normalizedUserId;
  }
}
