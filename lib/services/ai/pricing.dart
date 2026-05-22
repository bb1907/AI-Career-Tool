/// Pricing configuration for subscription plans.
///
/// When RevenueCat is live, call [PlanPricing.fromPrices] to derive labels
/// dynamically from store prices. Until then the static constants below are
/// used directly by the paywall.
class PlanPricing {
  final String name;
  final String monthlyPrice;
  final String yearlyPrice;
  final String yearlyMonthly;
  final String monthlyBadge;

  /// Human-readable savings label shown on the annual billing badge,
  /// e.g. "Save 33%" or "Best Value • Save 38%".
  final String savingsLabel;

  const PlanPricing({
    required this.name,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.yearlyMonthly,
    required this.monthlyBadge,
    required this.savingsLabel,
  });

  /// Derive savings from actual store prices when RevenueCat is available.
  factory PlanPricing.fromPrices({
    required String name,
    required double monthlyUsd,
    required double yearlyUsd,
    required String monthlyBadge,
    bool isBestValue = false,
  }) {
    final yearlyMonthly = yearlyUsd / 12;
    final savingsPct = ((monthlyUsd - yearlyMonthly) / monthlyUsd * 100)
        .round()
        .clamp(0, 99);
    final label = isBestValue
        ? 'Best Value • Save $savingsPct%'
        : 'Save $savingsPct%';
    return PlanPricing(
      name: name,
      monthlyPrice: '\$${monthlyUsd.toStringAsFixed(2)}',
      yearlyPrice: '\$${yearlyUsd.toStringAsFixed(2)}',
      yearlyMonthly: '\$${yearlyMonthly.toStringAsFixed(2)}/mo',
      monthlyBadge: monthlyBadge,
      savingsLabel: label,
    );
  }
}

// ── Static defaults used until RevenueCat is wired ────────────────────────────

const proPricing = PlanPricing(
  name: 'Pro',
  monthlyPrice: r'$9.99',
  yearlyPrice: r'$79.99',
  yearlyMonthly: r'$6.67/mo',
  monthlyBadge: '3 Days Free',
  savingsLabel: 'Save 33%',
);

const proMaxPricing = PlanPricing(
  name: 'Pro Max',
  monthlyPrice: r'$19.99',
  yearlyPrice: r'$149.99',
  yearlyMonthly: r'$12.50/mo',
  monthlyBadge: '3 Days Free',
  savingsLabel: 'Best Value • Save 38%',
);
