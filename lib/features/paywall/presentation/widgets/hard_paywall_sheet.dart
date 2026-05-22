import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../services/subscription/subscription_provider.dart';

enum HardPaywallType {
  resumeGenerate,
  photoStudio,
  mockInterview,
  videoScript,
  pdfExport,
}

void showHardPaywall(BuildContext context, HardPaywallType type) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _HardPaywallSheet(type: type),
  );
}

class _HardPaywallSheet extends ConsumerStatefulWidget {
  final HardPaywallType type;

  const _HardPaywallSheet({required this.type});

  @override
  ConsumerState<_HardPaywallSheet> createState() => _HardPaywallSheetState();
}

class _HardPaywallSheetState extends ConsumerState<_HardPaywallSheet> {
  int _selectedPlan = 0;

  _TypeInfo get _info => switch (widget.type) {
    HardPaywallType.resumeGenerate => const _TypeInfo(
      icon: Icons.description_rounded,
      color: AppColors.primary,
      title: 'Your resume is ready!',
      subtitle: 'Start your free trial to generate unlimited resumes',
    ),
    HardPaywallType.photoStudio => const _TypeInfo(
      icon: Icons.camera_enhance_rounded,
      color: Color(0xFF00C2A8),
      title: 'Unlock AI Photo Studio',
      subtitle: 'Transform your photo for any job interview',
    ),
    HardPaywallType.mockInterview => const _TypeInfo(
      icon: Icons.mic_rounded,
      color: Color(0xFF8B5CF6),
      title: 'Practice with AI Interviewer',
      subtitle: 'Get real-time feedback on your answers',
    ),
    HardPaywallType.videoScript => const _TypeInfo(
      icon: Icons.videocam_rounded,
      color: AppColors.error,
      title: 'Create Video Cover Letters',
      subtitle: 'Stand out with professional video applications',
    ),
    HardPaywallType.pdfExport => const _TypeInfo(
      icon: Icons.picture_as_pdf_rounded,
      color: Color(0xFFF59E0B),
      title: 'Download Clean PDF',
      subtitle: 'Export your resume without watermark',
    ),
  };

  Future<void> _startTrial(BuildContext context) async {
    Navigator.pop(context);
    final notifier = ref.read(subscriptionProvider.notifier);
    if (_selectedPlan <= 1) {
      await notifier.upgradeToPro();
    } else {
      await notifier.upgradeToProMax();
    }
    if (context.mounted) context.push('/congratulations');
  }

  @override
  Widget build(BuildContext context) {
    final info = _info;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Close button
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),

                // Icon + title
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: info.color.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(info.icon, size: 32, color: info.color),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        info.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          info.subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // Plan cards — 2×2 grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
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
                              bigBadge: '90% OFF',
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
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Comparison table
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _ComparisonTable(),
                ),

                const SizedBox(height: 20),

                // CTA button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
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
                        onPressed: () => _startTrial(context),
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
                ),

                const SizedBox(height: 8),

                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Restore Purchases',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),

                // Footer
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () {},
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
                        onPressed: () {},
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

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TypeInfo {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _TypeInfo({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
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
