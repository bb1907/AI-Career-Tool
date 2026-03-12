import 'subscription_plan.dart';

class SubscriptionStatus {
  const SubscriptionStatus({
    this.appUserId,
    this.plan = SubscriptionPlan.free,
    this.isPremium = false,
    this.entitlementId,
    this.productIdentifier,
    this.expiresAt,
    this.managementUrl,
    this.willRenew = false,
  });

  final String? appUserId;
  final SubscriptionPlan plan;
  final bool isPremium;
  final String? entitlementId;
  final String? productIdentifier;
  final DateTime? expiresAt;
  final String? managementUrl;
  final bool willRenew;

  SubscriptionStatus copyWith({
    String? appUserId,
    SubscriptionPlan? plan,
    bool? isPremium,
    String? entitlementId,
    String? productIdentifier,
    DateTime? expiresAt,
    String? managementUrl,
    bool? willRenew,
    bool clearEntitlement = false,
    bool clearProductIdentifier = false,
    bool clearExpiresAt = false,
    bool clearManagementUrl = false,
    bool clearAppUserId = false,
  }) {
    return SubscriptionStatus(
      appUserId: clearAppUserId ? null : appUserId ?? this.appUserId,
      plan: plan ?? this.plan,
      isPremium: isPremium ?? this.isPremium,
      entitlementId: clearEntitlement
          ? null
          : entitlementId ?? this.entitlementId,
      productIdentifier: clearProductIdentifier
          ? null
          : productIdentifier ?? this.productIdentifier,
      expiresAt: clearExpiresAt ? null : expiresAt ?? this.expiresAt,
      managementUrl: clearManagementUrl
          ? null
          : managementUrl ?? this.managementUrl,
      willRenew: willRenew ?? this.willRenew,
    );
  }
}
