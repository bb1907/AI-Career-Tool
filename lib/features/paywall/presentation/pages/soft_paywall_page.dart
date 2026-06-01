import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/core/app_links.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../services/subscription/subscription_provider.dart';

class SoftPaywallPage extends ConsumerStatefulWidget {
  const SoftPaywallPage({super.key});

  @override
  ConsumerState<SoftPaywallPage> createState() => _SoftPaywallPageState();
}

class _SoftPaywallPageState extends ConsumerState<SoftPaywallPage> {
  int _selectedPlan =
      0; // 0=Pro Monthly, 1=Pro Yearly, 2=ProMax Monthly, 3=ProMax Yearly

  static const _features = [
    (
      Icons.auto_awesome_rounded,
      Color(0xFF5B5FEF),
      'Unlimited AI Resume & Cover Letters',
    ),
    (
      Icons.camera_enhance_rounded,
      Color(0xFF00C2A8),
      'AI Photo Studio - Professional headshots',
    ),
    (
      Icons.mic_rounded,
      Color(0xFF8B5CF6),
      'Mock Interview AI with real-time feedback',
    ),
    (
      Icons.videocam_rounded,
      Color(0xFFEF4444),
      'Video Cover Letter + Teleprompter',
    ),
    (
      Icons.bar_chart_rounded,
      Color(0xFFF59E0B),
      'Skill Gap Analyzer & Job Matching',
    ),
    (Icons.language_rounded, Color(0xFF3B82F6), '45 Languages supported'),
    (Icons.bolt_rounded, Color(0xFFF59E0B), 'Priority AI - Faster results'),
  ];

  void _skip() {
    ref.read(subscriptionProvider.notifier).markSoftPaywallShown();
    context.go('/home');
  }

  Future<void> _startTrial() async {
    ref.read(subscriptionProvider.notifier).markSoftPaywallShown();
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.of(context).pop();
    final notifier = ref.read(subscriptionProvider.notifier);
    if (_selectedPlan <= 1) {
      await notifier.upgradeToPro();
    } else {
      await notifier.upgradeToProMax();
    }
    if (!mounted) return;
    context.go('/congratulations');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBG,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top close button
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: _skip,
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: Colors.grey,
                  ),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),

              // Header
              Center(
                child: Column(
                  children: [
                    Text(
                      'AI Career Copilot',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5B5FEF), Color(0xFF9B5DE5)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.emoji_events,
                            size: 14,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Unlock Pro',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Feature list
              ..._features.map(
                (f) => _FeatureRow(icon: f.$1, color: f.$2, text: f.$3),
              ),

              const SizedBox(height: 20),

              // Plan cards — 2×2 grid
              Row(
                children: [
                  Expanded(
                    child: _PlanCard(
                      isSelected: _selectedPlan == 0,
                      badgeIcon: Icons.star_rounded,
                      badgeLabel: 'Free Trial',
                      badgeColor: AppColors.primary,
                      title: 'Pro',
                      price: '\$9.99',
                      priceUnit: '/Month',
                      chipLabel: '3 Days Free',
                      originalPrice: null,
                      totalLabel: null,
                      bigBadge: null,
                      accentColor: AppColors.primary,
                      onTap: () => setState(() => _selectedPlan = 0),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _PlanCard(
                      isSelected: _selectedPlan == 1,
                      badgeIcon: Icons.local_fire_department,
                      badgeLabel: 'Best Deal',
                      badgeColor: const Color(0xFFF97316),
                      title: 'Pro Yearly',
                      price: '\$6.67',
                      priceUnit: '/Month',
                      chipLabel: null,
                      originalPrice: '\$9.99',
                      totalLabel: '\$79.99/Year Total',
                      bigBadge: 'Save 33%',
                      accentColor: const Color(0xFFF97316),
                      onTap: () => setState(() => _selectedPlan = 1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _PlanCard(
                      isSelected: _selectedPlan == 2,
                      badgeIcon: Icons.auto_awesome,
                      badgeLabel: 'Pro Max',
                      badgeColor: const Color(0xFFF59E0B),
                      title: 'Pro Max',
                      price: '\$19.99',
                      priceUnit: '/Month',
                      chipLabel: '3 Days Free',
                      originalPrice: null,
                      totalLabel: null,
                      bigBadge: null,
                      accentColor: const Color(0xFFF59E0B),
                      onTap: () => setState(() => _selectedPlan = 2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _PlanCard(
                      isSelected: _selectedPlan == 3,
                      badgeIcon: Icons.diamond,
                      badgeLabel: 'Best Value',
                      badgeColor: const Color(0xFF00C2A8),
                      title: 'Pro Max Yearly',
                      price: '\$12.50',
                      priceUnit: '/Month',
                      chipLabel: null,
                      originalPrice: '\$19.99',
                      totalLabel: '\$149.99/Year Total',
                      bigBadge: 'Save 38%',
                      accentColor: const Color(0xFF00C2A8),
                      onTap: () => setState(() => _selectedPlan = 3),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Plan comparison table
              const _ComparisonTable(),

              const SizedBox(height: 20),

              // CTA button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: _selectedPlan >= 2
                        ? const LinearGradient(
                            colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
                          )
                        : const LinearGradient(
                            colors: [Color(0xFF5B5FEF), Color(0xFF9B5DE5)],
                          ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ElevatedButton(
                    onPressed: _startTrial,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Try For Free',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Below button text
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Auto renew, cancel anytime.',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No purchases to restore yet'),
                          ),
                        );
                      },
                      child: const Text(
                        'Restore Purchases',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Footer
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () =>
                          launchExternalUrl(AppLinks.terms, context: context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Terms',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ),
                    const Text(
                      ' | ',
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                    const Icon(
                      Icons.lock_rounded,
                      size: 11,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 2),
                    const Text(
                      'Secured Payment',
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                    const Text(
                      ' | ',
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                    TextButton(
                      onPressed: () =>
                          launchExternalUrl(AppLinks.privacy, context: context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Privacy',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const _FeatureRow({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final bool isSelected;
  final IconData badgeIcon;
  final String badgeLabel;
  final Color badgeColor;
  final String title;
  final String price;
  final String priceUnit;
  final String? chipLabel;
  final String? originalPrice;
  final String? totalLabel;
  final String? bigBadge;
  final Color accentColor;
  final VoidCallback onTap;

  const _PlanCard({
    required this.isSelected,
    required this.badgeIcon,
    required this.badgeLabel,
    required this.badgeColor,
    required this.title,
    required this.price,
    required this.priceUnit,
    required this.chipLabel,
    required this.originalPrice,
    required this.totalLabel,
    required this.bigBadge,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: accentColor, width: 2)
              : Border.all(color: const Color(0xFFE6E8EF), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(badgeIcon, size: 11, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      badgeLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle_rounded,
                          color: accentColor,
                          size: 16,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (bigBadge != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        bigBadge!,
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  if (originalPrice != null)
                    Text(
                      originalPrice!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        priceUnit,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  if (totalLabel != null)
                    Text(
                      totalLabel!,
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  if (chipLabel != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        chipLabel!,
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComparisonTable extends StatelessWidget {
  const _ComparisonTable();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final altBg = isDark ? const Color(0xFF1F2937) : const Color(0xFFF7F8FB);
    const rows = [
      ('Resume / Cover Letter', 'Unlimited', 'Unlimited'),
      ('Photo Studio', '5/month', 'Unlimited'),
      ('Video Script', '30s only', '30/60/90s'),
      ('AI Speed', 'Standard', 'Priority'),
      ('PDF Export', 'Clean', 'Clean'),
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFE6E8EF),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header row
          Container(
            color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF0F1FF),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Expanded(flex: 3, child: SizedBox()),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5B5FEF), Color(0xFF9B5DE5)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Pro',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Pro Max',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Data rows
          ...rows.asMap().entries.map((entry) {
            final i = entry.key;
            final row = entry.value;
            return Container(
              color: i.isOdd ? altBg : null,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(row.$1, style: const TextStyle(fontSize: 12)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      row.$2,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF5B5FEF),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      row.$3,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFF59E0B),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
