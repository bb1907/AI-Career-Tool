import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../core/config/env.dart';
import '../../core/errors/app_exception.dart';
import 'subscription_error_mapper.dart';
import 'subscription_package.dart';
import 'subscription_plan.dart';
import 'subscription_service.dart';
import 'subscription_status.dart';

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  final service = RevenueCatSubscriptionService(
    apiKey: Env.resolvedRevenueCatAppleApiKey,
    entitlementId: Env.resolvedRevenueCatEntitlementId,
  );
  ref.onDispose(service.dispose);
  return service;
});

class RevenueCatSubscriptionService implements SubscriptionService {
  RevenueCatSubscriptionService({
    required String apiKey,
    required String entitlementId,
  }) : _apiKey = apiKey,
       _entitlementId = entitlementId;

  final String _apiKey;
  final String _entitlementId;
  final StreamController<SubscriptionStatus> _statusController =
      StreamController<SubscriptionStatus>.broadcast();

  CustomerInfoUpdateListener? _customerInfoListener;
  final Map<String, Package> _packagesByIdentifier = <String, Package>{};
  String? _currentAppUserId;
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    if (_apiKey.isEmpty) {
      Env.requireRevenueCatAppleApiKey();
    }

    try {
      await Purchases.configure(PurchasesConfiguration(_apiKey));
      _customerInfoListener ??= (customerInfo) {
        _statusController.add(
          _mapCustomerInfo(customerInfo, appUserId: _currentAppUserId),
        );
      };
      Purchases.addCustomerInfoUpdateListener(_customerInfoListener!);
      _isInitialized = true;
    } catch (error) {
      throw SubscriptionErrorMapper.map(
        error,
        fallbackMessage:
            'Subscriptions could not be initialized right now. Please try again later.',
      );
    }
  }

  @override
  Stream<SubscriptionStatus> observeSubscriptionStatus() {
    return _statusController.stream;
  }

  @override
  Future<SubscriptionStatus> syncUser(String? appUserId) async {
    await initialize();
    final normalizedUserId = _normalizeUserId(appUserId);

    if (normalizedUserId == _currentAppUserId) {
      return refreshStatus();
    }

    if (normalizedUserId == null) {
      return _logOutCurrentUser();
    }

    try {
      final result = await Purchases.logIn(normalizedUserId);
      _currentAppUserId = normalizedUserId;
      final status = _mapCustomerInfo(
        result.customerInfo,
        appUserId: normalizedUserId,
      );
      _statusController.add(status);
      return status;
    } catch (error) {
      throw SubscriptionErrorMapper.map(
        error,
        fallbackMessage:
            'Subscription access could not be refreshed right now.',
      );
    }
  }

  @override
  Future<SubscriptionStatus> refreshStatus() async {
    await initialize();

    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final status = _mapCustomerInfo(
        customerInfo,
        appUserId: _currentAppUserId,
      );
      _statusController.add(status);
      return status;
    } catch (error) {
      throw SubscriptionErrorMapper.map(
        error,
        fallbackMessage: 'Subscription status could not be loaded right now.',
      );
    }
  }

  @override
  Future<List<SubscriptionPackage>> loadPackages() async {
    await initialize();

    try {
      final offerings = await Purchases.getOfferings();
      final currentOffering = offerings.current;

      _packagesByIdentifier
        ..clear()
        ..addEntries(
          (currentOffering?.availablePackages ?? const <Package>[]).map(
            (package) => MapEntry(package.identifier, package),
          ),
        );

      final mappedPackages =
          (currentOffering?.availablePackages ?? const <Package>[])
              .map(_mapPackage)
              .where((package) => package.plan.isPremium)
              .toList(growable: false);

      mappedPackages.sort((left, right) {
        return _planOrder(left.plan).compareTo(_planOrder(right.plan));
      });

      return mappedPackages;
    } catch (error) {
      throw SubscriptionErrorMapper.map(
        error,
        fallbackMessage: 'Subscription plans could not be loaded right now.',
      );
    }
  }

  @override
  Future<SubscriptionStatus> purchasePackage(
    SubscriptionPackage package,
  ) async {
    await initialize();

    final revenueCatPackage =
        _packagesByIdentifier[package.identifier] ??
        await _reloadPackage(package.identifier);

    if (revenueCatPackage == null) {
      throw const AppException(
        'This subscription plan is not available right now.',
      );
    }

    try {
      final purchaseResult = await Purchases.purchase(
        PurchaseParams.package(revenueCatPackage),
      );
      final status = _mapCustomerInfo(
        purchaseResult.customerInfo,
        appUserId: _currentAppUserId,
      );
      _statusController.add(status);
      return status;
    } catch (error) {
      throw SubscriptionErrorMapper.map(
        error,
        fallbackMessage: 'The subscription purchase could not be completed.',
      );
    }
  }

  @override
  Future<SubscriptionStatus> restorePurchases() async {
    await initialize();

    try {
      final customerInfo = await Purchases.restorePurchases();
      final status = _mapCustomerInfo(
        customerInfo,
        appUserId: _currentAppUserId,
      );
      _statusController.add(status);
      return status;
    } catch (error) {
      throw SubscriptionErrorMapper.map(
        error,
        fallbackMessage: 'Purchases could not be restored right now.',
      );
    }
  }

  @override
  void dispose() {
    final listener = _customerInfoListener;
    if (listener != null) {
      Purchases.removeCustomerInfoUpdateListener(listener);
    }
    _customerInfoListener = null;
    _statusController.close();
  }

  Future<SubscriptionStatus> _logOutCurrentUser() async {
    try {
      final customerInfo = await Purchases.logOut();
      _currentAppUserId = null;
      final status = _mapCustomerInfo(customerInfo, appUserId: null);
      _statusController.add(status);
      return status;
    } catch (error) {
      final mappedError = SubscriptionErrorMapper.map(
        error,
        fallbackMessage: 'Subscription state could not be cleared right now.',
      );

      if (mappedError.code == 'subscription_already_logged_out') {
        final status = const SubscriptionStatus();
        _currentAppUserId = null;
        _statusController.add(status);
        return status;
      }

      throw mappedError;
    }
  }

  Future<Package?> _reloadPackage(String identifier) async {
    final packages = await loadPackages();
    final selectedPackage = packages.where(
      (item) => item.identifier == identifier,
    );

    if (selectedPackage.isEmpty) {
      return null;
    }

    return _packagesByIdentifier[identifier];
  }

  SubscriptionPackage _mapPackage(Package package) {
    final plan = _mapPlanFromPackage(package);

    return SubscriptionPackage(
      identifier: package.identifier,
      productIdentifier: package.storeProduct.identifier,
      plan: plan,
      title: package.storeProduct.title.trim(),
      description: package.storeProduct.description.trim(),
      priceLabel: package.storeProduct.priceString,
      billingLabel: _buildBillingLabel(package),
    );
  }

  SubscriptionStatus _mapCustomerInfo(
    CustomerInfo customerInfo, {
    required String? appUserId,
  }) {
    final activeEntitlement = customerInfo.entitlements.active[_entitlementId];

    if (activeEntitlement == null || !activeEntitlement.isActive) {
      return SubscriptionStatus(
        appUserId: appUserId,
        managementUrl: customerInfo.managementURL,
      );
    }

    return SubscriptionStatus(
      appUserId: appUserId,
      plan: _resolvePlanForEntitlement(activeEntitlement),
      isPremium: true,
      entitlementId: activeEntitlement.identifier,
      productIdentifier: activeEntitlement.productIdentifier,
      expiresAt: _tryParseDateTime(activeEntitlement.expirationDate),
      managementUrl: customerInfo.managementURL,
      willRenew: activeEntitlement.willRenew,
    );
  }

  SubscriptionPlan _resolvePlanForEntitlement(EntitlementInfo entitlement) {
    for (final package in _packagesByIdentifier.values) {
      if (package.storeProduct.identifier == entitlement.productIdentifier) {
        return _mapPlanFromPackage(package);
      }
    }

    final normalizedProductId = entitlement.productIdentifier.toLowerCase();

    if (normalizedProductId.contains('annual') ||
        normalizedProductId.contains('year')) {
      return SubscriptionPlan.annual;
    }

    if (normalizedProductId.contains('month')) {
      return SubscriptionPlan.monthly;
    }

    if (normalizedProductId.contains('week')) {
      return SubscriptionPlan.weekly;
    }

    return SubscriptionPlan.monthly;
  }

  SubscriptionPlan _mapPlanFromPackage(Package package) {
    return switch (package.packageType) {
      PackageType.weekly => SubscriptionPlan.weekly,
      PackageType.monthly => SubscriptionPlan.monthly,
      PackageType.annual => SubscriptionPlan.annual,
      _ => _inferPlanFromProductIdentifier(package.storeProduct.identifier),
    };
  }

  SubscriptionPlan _inferPlanFromProductIdentifier(String productIdentifier) {
    final normalizedProductIdentifier = productIdentifier.toLowerCase();

    if (normalizedProductIdentifier.contains('annual') ||
        normalizedProductIdentifier.contains('year')) {
      return SubscriptionPlan.annual;
    }

    if (normalizedProductIdentifier.contains('month')) {
      return SubscriptionPlan.monthly;
    }

    if (normalizedProductIdentifier.contains('week')) {
      return SubscriptionPlan.weekly;
    }

    return SubscriptionPlan.monthly;
  }

  String? _buildBillingLabel(Package package) {
    final product = package.storeProduct;

    return switch (_mapPlanFromPackage(package)) {
      SubscriptionPlan.weekly => product.pricePerWeekString ?? 'Billed weekly',
      SubscriptionPlan.monthly =>
        product.pricePerMonthString ?? 'Billed monthly',
      SubscriptionPlan.annual =>
        product.pricePerYearString ?? 'Billed annually',
      SubscriptionPlan.free => null,
    };
  }

  DateTime? _tryParseDateTime(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return DateTime.tryParse(value)?.toUtc();
  }

  String? _normalizeUserId(String? appUserId) {
    final normalizedUserId = appUserId?.trim() ?? '';
    return normalizedUserId.isEmpty ? null : normalizedUserId;
  }

  int _planOrder(SubscriptionPlan plan) {
    return switch (plan) {
      SubscriptionPlan.weekly => 0,
      SubscriptionPlan.monthly => 1,
      SubscriptionPlan.annual => 2,
      SubscriptionPlan.free => 3,
    };
  }
}
