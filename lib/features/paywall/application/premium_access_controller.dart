import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/subscription/premium_access_feature.dart';
import '../../../services/subscription/premium_access_service.dart';
import '../../auth/presentation/providers/auth_controller.dart';
import 'subscription_controller.dart';
import 'premium_access_state.dart';

final premiumAccessControllerProvider =
    NotifierProvider<PremiumAccessController, PremiumAccessState>(
      PremiumAccessController.new,
    );

class PremiumAccessController extends Notifier<PremiumAccessState> {
  int _revision = 0;

  @override
  PremiumAccessState build() {
    ref.listen(authControllerProvider, (previous, next) {
      final previousUserId = previous?.session?.userId;
      final nextUserId = next.session?.userId;

      if (previousUserId == nextUserId) {
        return;
      }

      Future<void>.microtask(_reloadSnapshot);
    });

    ref.listen(subscriptionControllerProvider, (previous, next) {
      if (previous?.status.isPremium == next.status.isPremium &&
          previous?.userId == next.userId) {
        return;
      }

      Future<void>.microtask(_reloadSnapshot);
    });

    Future<void>.microtask(_reloadSnapshot);
    return const PremiumAccessState(isLoading: true);
  }

  Future<PremiumAccessDecision> requestAccess(
    PremiumAccessFeature feature,
  ) async {
    final service = ref.read(premiumAccessServiceProvider);
    final subscriptionState = ref.read(subscriptionControllerProvider);
    final userId = ref.read(authControllerProvider).session?.userId;

    final decision = await service.evaluateAccess(
      userId: userId,
      isPremium: subscriptionState.isPremium,
      feature: feature,
    );

    if (ref.mounted) {
      state = state.copyWith(snapshot: decision.snapshot, clearError: true);
    }

    return decision;
  }

  Future<void> recordSuccessfulUse(PremiumAccessFeature feature) async {
    final service = ref.read(premiumAccessServiceProvider);
    final subscriptionState = ref.read(subscriptionControllerProvider);
    final userId = ref.read(authControllerProvider).session?.userId;

    final snapshot = await service.recordSuccessfulUse(
      userId: userId,
      isPremium: subscriptionState.isPremium,
      feature: feature,
    );

    if (!ref.mounted) {
      return;
    }

    state = state.copyWith(snapshot: snapshot, clearError: true);
  }

  Future<void> refresh() => _reloadSnapshot();

  Future<void> _reloadSnapshot() async {
    final revision = ++_revision;
    final service = ref.read(premiumAccessServiceProvider);
    final subscriptionState = ref.read(subscriptionControllerProvider);
    final userId = ref.read(authControllerProvider).session?.userId;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final snapshot = await service.loadSnapshot(
        userId: userId,
        isPremium: subscriptionState.isPremium,
      );

      if (!ref.mounted || revision != _revision) {
        return;
      }

      state = state.copyWith(
        snapshot: snapshot,
        isLoading: false,
        clearError: true,
      );
    } catch (_) {
      if (!ref.mounted || revision != _revision) {
        return;
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Usage limits could not be refreshed right now.',
      );
    }
  }
}
