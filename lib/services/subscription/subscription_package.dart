import 'subscription_plan.dart';

class SubscriptionPackage {
  const SubscriptionPackage({
    required this.identifier,
    required this.productIdentifier,
    required this.plan,
    required this.title,
    required this.description,
    required this.priceLabel,
    this.billingLabel,
  });

  final String identifier;
  final String productIdentifier;
  final SubscriptionPlan plan;
  final String title;
  final String description;
  final String priceLabel;
  final String? billingLabel;
}
