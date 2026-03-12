import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../services/subscription/revenuecat_subscription_service.dart';
import '../../../services/subscription/subscription_package.dart';
import '../../../services/subscription/subscription_status.dart';
import '../../../services/subscription/subscription_sync_service.dart';
import '../../auth/presentation/providers/auth_controller.dart';
import 'subscription_state.dart';

final subscriptionControllerProvider =
    NotifierProvider<SubscriptionController, SubscriptionState>(
      SubscriptionController.new,
    );

class SubscriptionController extends Notifier<SubscriptionState> {
  StreamSubscription<SubscriptionStatus>? _statusSubscription;
  int _authRevision = 0;

  @override
  SubscriptionState build() {
    _statusSubscription ??= ref
        .read(subscriptionServiceProvider)
        .observeSubscriptionStatus()
        .listen(_handleStatusStreamUpdate);

    ref.onDispose(() {
      _statusSubscription?.cancel();
      _statusSubscription = null;
    });

    ref.listen(authControllerProvider, (previous, next) {
      final previousUserId = previous?.session?.userId;
      final nextUserId = next.session?.userId;

      if (previousUserId == nextUserId) {
        return;
      }

      Future<void>.microtask(() => _synchronizeWithUser(nextUserId));
    });

    Future<void>.microtask(_initialize);
    return const SubscriptionState(isLoading: true);
  }

  Future<void> refresh() async {
    final activeUserId = state.userId;
    final revision = ++_authRevision;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final refreshedStatus = await ref
          .read(subscriptionServiceProvider)
          .refreshStatus();
      final packages = await ref
          .read(subscriptionServiceProvider)
          .loadPackages();

      if (!_isCurrentRevision(revision)) {
        return;
      }

      state = state.copyWith(
        status: refreshedStatus,
        packages: packages,
        isLoading: false,
        isRestoring: false,
        clearPurchasingPackageId: true,
        clearError: true,
      );

      await _syncStatus(activeUserId, refreshedStatus, revision);
    } on AppException catch (error) {
      if (!_isCurrentRevision(revision)) {
        return;
      }

      state = state.copyWith(isLoading: false, errorMessage: error.message);
    } catch (_) {
      if (!_isCurrentRevision(revision)) {
        return;
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Subscription details could not be refreshed right now.',
      );
    }
  }

  Future<void> purchase(SubscriptionPackage package) async {
    final activeUserId = state.userId;

    state = state.copyWith(
      purchasingPackageId: package.identifier,
      clearError: true,
    );

    try {
      final updatedStatus = await ref
          .read(subscriptionServiceProvider)
          .purchasePackage(package);

      if (!ref.mounted || state.userId != activeUserId) {
        return;
      }

      state = state.copyWith(
        status: updatedStatus,
        clearPurchasingPackageId: true,
        clearError: true,
      );

      await _syncStatus(activeUserId, updatedStatus, _authRevision);
    } on AppException catch (error) {
      if (!ref.mounted || state.userId != activeUserId) {
        return;
      }

      state = state.copyWith(
        errorMessage: error.code == 'subscription_purchase_cancelled'
            ? null
            : error.message,
        clearPurchasingPackageId: true,
      );

      rethrow;
    } catch (_) {
      if (!ref.mounted || state.userId != activeUserId) {
        return;
      }

      state = state.copyWith(
        errorMessage: 'The subscription purchase could not be completed.',
        clearPurchasingPackageId: true,
      );
      rethrow;
    }
  }

  Future<void> restorePurchases() async {
    final activeUserId = state.userId;

    state = state.copyWith(isRestoring: true, clearError: true);

    try {
      final restoredStatus = await ref
          .read(subscriptionServiceProvider)
          .restorePurchases();

      if (!ref.mounted || state.userId != activeUserId) {
        return;
      }

      state = state.copyWith(
        status: restoredStatus,
        isRestoring: false,
        clearError: true,
      );

      await _syncStatus(activeUserId, restoredStatus, _authRevision);
    } on AppException catch (error) {
      if (!ref.mounted || state.userId != activeUserId) {
        return;
      }

      state = state.copyWith(isRestoring: false, errorMessage: error.message);
      rethrow;
    } catch (_) {
      if (!ref.mounted || state.userId != activeUserId) {
        return;
      }

      state = state.copyWith(
        isRestoring: false,
        errorMessage: 'Purchases could not be restored right now.',
      );
      rethrow;
    }
  }

  Future<void> _initialize() async {
    try {
      await ref.read(subscriptionServiceProvider).initialize();
    } on AppException catch (error) {
      if (!ref.mounted) {
        return;
      }

      state = state.copyWith(isLoading: false, errorMessage: error.message);
      return;
    } catch (_) {
      if (!ref.mounted) {
        return;
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Subscriptions are unavailable right now.',
      );
      return;
    }

    await _synchronizeWithUser(
      ref.read(authControllerProvider).session?.userId,
    );
  }

  Future<void> _synchronizeWithUser(String? userId) async {
    final revision = ++_authRevision;
    final normalizedUserId = _normalizeUserId(userId);

    state = state.copyWith(
      userId: normalizedUserId,
      status: normalizedUserId == null
          ? const SubscriptionStatus()
          : state.status,
      isLoading: true,
      isRestoring: false,
      clearPurchasingPackageId: true,
      clearError: true,
    );

    try {
      final synchronizedStatus = await ref
          .read(subscriptionServiceProvider)
          .syncUser(normalizedUserId);
      final packages = await ref
          .read(subscriptionServiceProvider)
          .loadPackages();

      if (!_isCurrentRevision(revision)) {
        return;
      }

      state = state.copyWith(
        userId: normalizedUserId,
        status: synchronizedStatus,
        packages: packages,
        isLoading: false,
        isRestoring: false,
        clearPurchasingPackageId: true,
        clearError: true,
      );

      await _syncStatus(normalizedUserId, synchronizedStatus, revision);
    } on AppException catch (error) {
      if (!_isCurrentRevision(revision)) {
        return;
      }

      state = state.copyWith(
        userId: normalizedUserId,
        status: normalizedUserId == null
            ? const SubscriptionStatus()
            : state.status,
        isLoading: false,
        errorMessage: error.message,
      );
    } catch (_) {
      if (!_isCurrentRevision(revision)) {
        return;
      }

      state = state.copyWith(
        userId: normalizedUserId,
        status: normalizedUserId == null
            ? const SubscriptionStatus()
            : state.status,
        isLoading: false,
        errorMessage: 'Subscription details could not be loaded right now.',
      );
    }
  }

  void _handleStatusStreamUpdate(SubscriptionStatus status) {
    if (!ref.mounted) {
      return;
    }

    if (status.appUserId != state.userId) {
      return;
    }

    state = state.copyWith(status: status);
  }

  Future<void> _syncStatus(
    String? userId,
    SubscriptionStatus status,
    int revision,
  ) async {
    if (userId == null) {
      return;
    }

    await ref
        .read(subscriptionSyncServiceProvider)
        .syncStatus(userId: userId, status: status);

    if (!_isCurrentRevision(revision)) {
      return;
    }
  }

  bool _isCurrentRevision(int revision) {
    return ref.mounted && revision == _authRevision;
  }

  String? _normalizeUserId(String? userId) {
    final normalizedUserId = userId?.trim() ?? '';
    return normalizedUserId.isEmpty ? null : normalizedUserId;
  }
}
