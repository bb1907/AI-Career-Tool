enum SubscriptionPlan {
  free,
  weekly,
  monthly,
  annual;

  String get label => switch (this) {
    SubscriptionPlan.free => 'Free',
    SubscriptionPlan.weekly => 'Weekly',
    SubscriptionPlan.monthly => 'Monthly',
    SubscriptionPlan.annual => 'Annual',
  };

  String get shortDescription => switch (this) {
    SubscriptionPlan.free => 'Basic access',
    SubscriptionPlan.weekly => 'Flexible short-term access',
    SubscriptionPlan.monthly => 'Balanced recurring access',
    SubscriptionPlan.annual => 'Best long-term value',
  };

  bool get isPremium => this != SubscriptionPlan.free;
}
