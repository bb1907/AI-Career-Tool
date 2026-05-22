import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/core/l10n_extension.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../services/ai/pricing.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data — sourced from pricing.dart so savings labels stay in sync
// ─────────────────────────────────────────────────────────────────────────────

enum _Billing { monthly, yearly }

class _PlanData {
  final String name;
  final String monthlyPrice;
  final String monthlyPeriod;
  final String yearlyPrice;
  final String yearlyMonthly;
  final String monthlyBadge;
  final String yearlyBadge;
  final bool isBestValue;

  const _PlanData({
    required this.name,
    required this.monthlyPrice,
    required this.monthlyPeriod,
    required this.yearlyPrice,
    required this.yearlyMonthly,
    required this.monthlyBadge,
    required this.yearlyBadge,
    this.isBestValue = false,
  });
}

_PlanData _fromPricing(PlanPricing p, {bool isBestValue = false}) => _PlanData(
  name: p.name,
  monthlyPrice: p.monthlyPrice,
  monthlyPeriod: '/month',
  yearlyPrice: p.yearlyPrice,
  yearlyMonthly: p.yearlyMonthly,
  monthlyBadge: p.monthlyBadge,
  yearlyBadge: p.savingsLabel,
  isBestValue: isBestValue,
);

final _plans = [
  _fromPricing(proPricing),
  _fromPricing(proMaxPricing, isBestValue: true),
];

const _features = [
  (Icons.auto_awesome_rounded, 'Unlimited AI Resumes & Cover Letters'),
  (Icons.camera_enhance_rounded, 'AI Photo Studio — Professional headshots'),
  (Icons.mic_rounded, 'Mock Interview AI with real feedback'),
  (Icons.video_camera_front_rounded, 'Video Cover Letter + Teleprompter'),
  (Icons.analytics_rounded, 'Skill Gap Analyzer & Job Matching'),
  (Icons.language_rounded, '45 Languages supported'),
];

// ─────────────────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────────────────

class PaywallPage extends StatefulWidget {
  const PaywallPage({super.key});

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  _Billing _billing = _Billing.yearly;
  int _selectedPlan = 1; // Pro Max default (best value)

  void _onSubscribe() {
    // TODO: RevenueCat purchase
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('RevenueCat integration coming soon!')),
    );
  }

  void _onRestore() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.paywallRestore)));
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final plan = _plans[_selectedPlan];
    final isYearly = _billing == _Billing.yearly;

    return Scaffold(
      backgroundColor: context.appBG,
      body: Column(
        children: [
          // ── Gradient header ───────────────────────────────────────────
          _Header(onClose: () => context.pop()),

          // ── Scrollable body ───────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg + bottomPad,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Features
                  ...(_features.map(
                    (f) => _FeatureRow(icon: f.$1, text: f.$2),
                  )),

                  const SizedBox(height: AppSpacing.xl),

                  // Billing toggle
                  _BillingToggle(
                    billing: _billing,
                    onChange: (b) => setState(() {
                      _billing = b;
                      _selectedPlan = b == _Billing.yearly ? 1 : 0;
                    }),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Plan cards
                  Row(
                    children: List.generate(_plans.length, (i) {
                      final p = _plans[i];
                      final sel = i == _selectedPlan;
                      final badge = isYearly ? p.yearlyBadge : p.monthlyBadge;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: i == 0 ? AppSpacing.sm : 0,
                          ),
                          child: _PlanCard(
                            plan: p,
                            isYearly: isYearly,
                            isSelected: sel,
                            badge: badge,
                            onTap: () => setState(() => _selectedPlan = i),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // CTA button
                  SizedBox(
                    height: 54,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5B5FEF), Color(0xFF9B5DE5)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.button),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: FilledButton(
                        onPressed: _onSubscribe,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadius.button,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Start Free Trial',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Trial disclaimer
                  Text(
                    isYearly
                        ? '${plan.yearlyPrice}/year after free trial. Cancel anytime.'
                        : '${plan.monthlyPrice}/month after 3-day free trial. Cancel anytime.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.appText2,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Restore
                  Center(
                    child: TextButton(
                      onPressed: _onRestore,
                      child: Text(
                        'Restore Purchases',
                        style: TextStyle(
                          fontSize: 13,
                          color: context.appText2,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Legal row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _LegalLink(label: 'Terms', onTap: () {}),
                      const SizedBox(width: AppSpacing.md),
                      Icon(
                        Icons.shield_rounded,
                        size: 13,
                        color: context.appText2,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Secured Payment',
                        style: TextStyle(fontSize: 12, color: context.appText2),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _LegalLink(label: 'Privacy', onTap: () {}),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final VoidCallback onClose;
  const _Header({required this.onClose});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5B5FEF), Color(0xFF9B5DE5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          topPad + AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        child: Column(
          children: [
            // Top row: restore (left) + close (right)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 36), // balance
                // PRO badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 11, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'PRO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                // X close — Apple required
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Sparkle icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            const Text(
              'AI Career Copilot Pro',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                height: 1.1,
              ),
            ),

            const SizedBox(height: AppSpacing.xs),

            Text(
              'Everything you need to land your dream job',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
                height: 1.3,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Feature row
// ─────────────────────────────────────────────────────────────────────────────

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Billing toggle
// ─────────────────────────────────────────────────────────────────────────────

class _BillingToggle extends StatelessWidget {
  final _Billing billing;
  final ValueChanged<_Billing> onChange;
  const _BillingToggle({required this.billing, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.appBorder),
      ),
      child: Row(
        children: [
          _ToggleOption(
            label: 'Monthly',
            isSelected: billing == _Billing.monthly,
            onTap: () => onChange(_Billing.monthly),
          ),
          _ToggleOption(
            label: 'Yearly',
            isSelected: billing == _Billing.yearly,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Save up to 38%',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
            ),
            onTap: () => onChange(_Billing.yearly),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? trailing;
  const _ToggleOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : context.appText2,
                ),
              ),
              if (trailing != null) ...[const SizedBox(height: 2), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Plan card
// ─────────────────────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final _PlanData plan;
  final bool isYearly;
  final bool isSelected;
  final String badge;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.isYearly,
    required this.isSelected,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.06)
              : context.appSurface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: isSelected ? AppColors.primary : context.appBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: plan.isBestValue
                    ? AppColors.primary
                    : (isSelected
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.1)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: (plan.isBestValue || isSelected)
                      ? Colors.white
                      : AppColors.primary,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Plan name
            Text(
              plan.name,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.primary : context.appText1,
              ),
            ),

            const SizedBox(height: 4),

            // Price
            Text(
              isYearly ? plan.yearlyPrice : plan.monthlyPrice,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isSelected ? AppColors.primary : context.appText1,
                letterSpacing: -0.5,
              ),
            ),

            // Period / monthly equiv
            Text(
              isYearly ? plan.yearlyMonthly : plan.monthlyPeriod,
              style: TextStyle(fontSize: 11, color: context.appText2),
            ),

            if (isSelected) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Selected',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Legal link
// ─────────────────────────────────────────────────────────────────────────────

class _LegalLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _LegalLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: context.appText2,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
