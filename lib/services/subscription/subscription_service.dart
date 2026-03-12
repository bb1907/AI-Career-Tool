import 'dart:async';

import 'subscription_package.dart';
import 'subscription_status.dart';

abstract class SubscriptionService {
  const SubscriptionService();

  Future<void> initialize();

  Stream<SubscriptionStatus> observeSubscriptionStatus();

  Future<SubscriptionStatus> syncUser(String? appUserId);

  Future<SubscriptionStatus> refreshStatus();

  Future<List<SubscriptionPackage>> loadPackages();

  Future<SubscriptionStatus> purchasePackage(SubscriptionPackage package);

  Future<SubscriptionStatus> restorePurchases();

  void dispose();
}
