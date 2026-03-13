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
  final Map<PremiumAccessFeature, List<String>> _pendingReservations = {};

  @override
  PremiumAccessState build() {
    ref.listen(authControllerProvider, (previous, next) {
      final previousUserId = previous?.session?.userId;
      final nextUserId = next.session?.userId;

      if (previousUserId == nextUserId) {
        return;
      }

      _clearPendingReservations();
      Future<void>.microtask(_reloadSnapshot);
    });

    ref.listen(subscriptionControllerProvider, (previous, next) {
      if (previous?.status.isPremium == next.status.isPremium &&
          previous?.userId == next.userId) {
        return;
      }

      _clearPendingReservations();
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

    _storeReservation(decision.feature, decision.reservationId);

    if (ref.mounted) {
      state = state.copyWith(snapshot: decision.snapshot, clearError: true);
    }

    return decision;
  }

  Future<void> recordSuccessfulUse(PremiumAccessFeature feature) async {
    final service = ref.read(premiumAccessServiceProvider);
    final subscriptionState = ref.read(subscriptionControllerProvider);
    final userId = ref.read(authControllerProvider).session?.userId;
    final reservationId = _takeReservation(feature);

    final snapshot = await service.recordSuccessfulUse(
      userId: userId,
      isPremium: subscriptionState.isPremium,
      feature: feature,
      reservationId: reservationId,
    );

    if (!ref.mounted) {
      return;
    }

    state = state.copyWith(snapshot: snapshot, clearError: true);
  }

  Future<void> releasePendingUse(PremiumAccessFeature feature) async {
    final service = ref.read(premiumAccessServiceProvider);
    final subscriptionState = ref.read(subscriptionControllerProvider);
    final userId = ref.read(authControllerProvider).session?.userId;
    final reservationId = _takeReservation(feature);

    if (reservationId == null) {
      return;
    }

    try {
      final snapshot = await service.releasePendingUse(
        userId: userId,
        isPremium: subscriptionState.isPremium,
        feature: feature,
        reservationId: reservationId,
      );

      if (!ref.mounted) {
        return;
      }

      state = state.copyWith(snapshot: snapshot, clearError: true);
    } catch (_) {
      // Usage cleanup should not replace the original generation error.
    }
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

  void _storeReservation(PremiumAccessFeature feature, String? reservationId) {
    if (reservationId == null) {
      return;
    }

    _pendingReservations
        .putIfAbsent(feature, () => <String>[])
        .add(reservationId);
  }

  String? _takeReservation(PremiumAccessFeature feature) {
    final reservations = _pendingReservations[feature];

    if (reservations == null || reservations.isEmpty) {
      return null;
    }

    final reservationId = reservations.removeLast();
    if (reservations.isEmpty) {
      _pendingReservations.remove(feature);
    }

    return reservationId;
  }

  void _clearPendingReservations() {
    _pendingReservations.clear();
  }
}
