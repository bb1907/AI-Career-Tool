import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../app/core/app_config.dart';
import '../subscription/subscription_provider.dart';

/// Wraps the RevenueCat SDK and maps entitlements to [PlanType].
///
/// When [AppConfig.hasRevenueCatKey] is false the service stays dormant and
/// the app continues using the local SharedPreferences-based subscription state.
class RevenueCatService {
  RevenueCatService._();
  static final RevenueCatService instance = RevenueCatService._();

  bool _initialized = false;

  /// Whether RevenueCat has been successfully initialized.
  bool get isInitialized => _initialized;

  // ── Entitlement IDs ─────────────────────────────────────────────────────────

  static const _proEntitlement = 'pro';
  static const _proMaxEntitlement = 'pro_max';

  // ── Initialization ──────────────────────────────────────────────────────────

  /// Initialize RevenueCat. Safe to call multiple times.
  /// Returns false if the API key is missing.
  Future<bool> initialize() async {
    if (_initialized) return true;

    if (!AppConfig.hasRevenueCatKey) {
      debugPrint('[RevenueCat] No API key found -- running without purchases');
      return false;
    }

    try {
      final configuration = PurchasesConfiguration(AppConfig.revenueCatApiKey);
      await Purchases.configure(configuration);
      _initialized = true;
      debugPrint('[RevenueCat] Initialized successfully');
      return true;
    } catch (e) {
      debugPrint('[RevenueCat] Initialization failed: $e');
      return false;
    }
  }

  /// Identify a user (call after successful sign-in).
  Future<void> identify(String userId) async {
    if (!_initialized) return;
    try {
      await Purchases.logIn(userId);
    } catch (e) {
      debugPrint('[RevenueCat] identify failed: $e');
    }
  }

  /// Reset identity on sign-out.
  Future<void> reset() async {
    if (!_initialized) return;
    try {
      await Purchases.logOut();
    } catch (e) {
      debugPrint('[RevenueCat] reset failed: $e');
    }
  }

  // ── Offerings ───────────────────────────────────────────────────────────────

  /// Fetch available offerings (subscription packages).
  Future<Offerings?> getOfferings() async {
    if (!_initialized) return null;
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('[RevenueCat] getOfferings failed: $e');
      return null;
    }
  }

  // ── Purchases ───────────────────────────────────────────────────────────────

  /// Purchase a specific package. Returns the updated [CustomerInfo] on success.
  Future<CustomerInfo?> purchasePackage(Package package) async {
    if (!_initialized) return null;
    try {
      final result = await Purchases.purchasePackage(package);
      return result;
    } catch (e) {
      debugPrint('[RevenueCat] purchasePackage failed: $e');
      return null;
    }
  }

  /// Restore purchases (e.g. after reinstall).
  Future<CustomerInfo?> restorePurchases() async {
    if (!_initialized) return null;
    try {
      return await Purchases.restorePurchases();
    } catch (e) {
      debugPrint('[RevenueCat] restorePurchases failed: $e');
      return null;
    }
  }

  // ── Customer Info ───────────────────────────────────────────────────────────

  /// Get the current customer info.
  Future<CustomerInfo?> getCustomerInfo() async {
    if (!_initialized) return null;
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      debugPrint('[RevenueCat] getCustomerInfo failed: $e');
      return null;
    }
  }

  /// Derive [PlanType] from current entitlements.
  PlanType planTypeFromCustomerInfo(CustomerInfo info) {
    final entitlements = info.entitlements.active;
    if (entitlements.containsKey(_proMaxEntitlement)) return PlanType.proMax;
    if (entitlements.containsKey(_proEntitlement)) return PlanType.pro;
    return PlanType.free;
  }

  /// Convenience: fetch customer info and return the plan type.
  Future<PlanType> getCurrentPlan() async {
    final info = await getCustomerInfo();
    if (info == null) return PlanType.free;
    return planTypeFromCustomerInfo(info);
  }

  // ── Listener ────────────────────────────────────────────────────────────────

  /// Listen for real-time entitlement changes (e.g. subscription
  /// renewals / cancellations).
  void addCustomerInfoListener(void Function(CustomerInfo) listener) {
    if (!_initialized) return;
    Purchases.addCustomerInfoUpdateListener(listener);
  }
}

/// Riverpod provider for the RevenueCat singleton.
final revenueCatProvider = Provider<RevenueCatService>((ref) {
  return RevenueCatService.instance;
});
