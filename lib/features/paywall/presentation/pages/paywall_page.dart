import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../services/analytics/analytics_events.dart';
import '../../../../services/analytics/analytics_service.dart';
import '../../../../services/subscription/subscription_package.dart';
import '../../../../services/subscription/subscription_plan.dart';
import '../../../../services/subscription/subscription_status.dart';
import '../../../../ui/components/ai_button.dart';
import '../../../../ui/components/app_card.dart';
import '../../../../ui/components/assistant_orb.dart';
import '../../../../ui/components/section_header.dart';
import '../../application/premium_access_controller.dart';
import '../../application/subscription_controller.dart';

class PaywallPage extends ConsumerStatefulWidget {
  const PaywallPage({
    super.key,
    this.redirectTo,
    this.sourceFeature,
    this.reason,
  });

  final String? redirectTo;
  final String? sourceFeature;
  final String? reason;

  @override
  ConsumerState<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends ConsumerState<PaywallPage> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      unawaited(
        ref
            .read(analyticsServiceProvider)
            .logEvent(
              AnalyticsEvents.paywallViewed,
              parameters: {
                'reason': widget.reason,
                'source_feature': widget.sourceFeature,
                'redirect_present':
                    widget.redirectTo != null &&
                    widget.redirectTo!.trim().isNotEmpty,
              },
            ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final subscriptionState = ref.watch(subscriptionControllerProvider);
    final accessState = ref.watch(premiumAccessControllerProvider);
    final shouldShowLimitMessage =
        !subscriptionState.isPremium &&
        (widget.reason == 'usage_limit' || accessState.hasReachedLimit);

    return Scaffold(
      appBar: AppBar(title: const Text('Upgrade to Pro')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  colors: [Color(0xFF111827), Color(0xFF1F2937)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.12),
                    blurRadius: 30,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      AssistantOrb(size: 44),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'AI Career Copilot Pro',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    subscriptionState.isPremium
                        ? '${subscriptionState.status.plan.label} is active on this account.'
                        : 'Unlimited AI career tools, smart cover letters and advanced interview prep.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: const [
                      _BenefitPill(label: 'Unlimited generations'),
                      _BenefitPill(label: 'Smart cover letters'),
                      _BenefitPill(label: 'Advanced interview prep'),
                    ],
                  ),
                  if (subscriptionState.status.expiresAt != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      subscriptionState.status.willRenew
                          ? 'Renews automatically after ${_formatDate(subscriptionState.status.expiresAt!)}.'
                          : 'Active until ${_formatDate(subscriptionState.status.expiresAt!)}.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                  if (shouldShowLimitMessage) ...[
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: Colors.white.withValues(alpha: 0.08),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.14),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Free limit reached',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You have used ${accessState.usedFreeGenerations} of ${accessState.freeGenerationLimit} free generations${widget.sourceFeature == null ? '' : ' for ${_formatSourceFeature(widget.sourceFeature!)}'}. Upgrade to continue without limits.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.82),
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(
              title: 'Available plans',
              subtitle:
                  'Weekly for quick momentum, monthly for active job search, annual for consistent long-term use.',
            ),
            if (subscriptionState.isLoading &&
                subscriptionState.hasPackages) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
            ],
            const SizedBox(height: 16),
            if (subscriptionState.isLoading && !subscriptionState.hasPackages)
              const AppCard(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            else if (!subscriptionState.hasPackages &&
                subscriptionState.errorMessage != null)
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plans are unavailable right now',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subscriptionState.errorMessage!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AIButton(
                      label: 'Reload plans',
                      expanded: false,
                      onPressed: () => ref
                          .read(subscriptionControllerProvider.notifier)
                          .refresh(),
                    ),
                  ],
                ),
              )
            else if (!subscriptionState.hasPackages)
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No plans available yet',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Configure the current RevenueCat offering to show weekly, monthly and annual plans here.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  for (
                    var index = 0;
                    index < subscriptionState.packages.length;
                    index++
                  ) ...[
                    _SubscriptionPackageCard(
                      package: subscriptionState.packages[index],
                      isCurrentPlan:
                          subscriptionState.status.plan ==
                              subscriptionState.packages[index].plan &&
                          subscriptionState.isPremium,
                      isPurchasing:
                          subscriptionState.purchasingPackageId ==
                          subscriptionState.packages[index].identifier,
                      onPressed: subscriptionState.isBusy
                          ? null
                          : () => _purchasePackage(
                              context,
                              subscriptionState.packages[index],
                            ),
                    ),
                    if (index != subscriptionState.packages.length - 1)
                      const SizedBox(height: 16),
                  ],
                ],
              ),
            const SizedBox(height: 24),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: 'Restore purchases',
                    subtitle:
                        'Already subscribed on this Apple account? Restore and continue without buying twice.',
                  ),
                  if (subscriptionState.errorMessage != null &&
                      subscriptionState.hasPackages) ...[
                    const SizedBox(height: 12),
                    Text(
                      subscriptionState.errorMessage!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  AIButton(
                    label: subscriptionState.isRestoring
                        ? 'Restoring purchases...'
                        : 'Restore purchases',
                    variant: AIButtonVariant.secondary,
                    icon: const Icon(Icons.restore_rounded),
                    isLoading: subscriptionState.isRestoring,
                    onPressed: subscriptionState.isRestoring
                        ? null
                        : () => _restorePurchases(context),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Subscriptions automatically renew unless canceled in your Apple account settings at least 24 hours before renewal.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _purchasePackage(
    BuildContext context,
    SubscriptionPackage package,
  ) async {
    try {
      final status = await ref
          .read(subscriptionControllerProvider.notifier)
          .purchase(
            package,
            sourceFeature: widget.sourceFeature,
            reason: widget.reason,
          );
      if (!context.mounted) {
        return;
      }

      AppFeedback.showSuccess(
        context,
        '${package.plan.label} premium unlocked successfully.',
      );

      _continueToOrigin(context, status);
    } on AppException catch (error) {
      if (!context.mounted || error.code == 'subscription_purchase_cancelled') {
        return;
      }

      AppFeedback.showError(context, error.message);
    }
  }

  Future<void> _restorePurchases(BuildContext context) async {
    try {
      final status = await ref
          .read(subscriptionControllerProvider.notifier)
          .restorePurchases();
      if (!context.mounted) {
        return;
      }

      if (status.isPremium) {
        AppFeedback.showSuccess(context, 'Purchases restored successfully.');
        _continueToOrigin(context, status);
      } else {
        AppFeedback.showInfo(context, 'No active premium purchase was found.');
      }
    } on AppException catch (error) {
      if (!context.mounted) {
        return;
      }

      AppFeedback.showError(context, error.message);
    }
  }

  void _continueToOrigin(BuildContext context, SubscriptionStatus status) {
    if (!status.isPremium) {
      return;
    }

    final normalizedRedirectTo = widget.redirectTo?.trim();
    if (normalizedRedirectTo != null &&
        normalizedRedirectTo.isNotEmpty &&
        Navigator.of(context).canPop()) {
      context.pop(true);
      return;
    }

    if (normalizedRedirectTo == null || normalizedRedirectTo.isEmpty) {
      context.go(AppRoutes.home);
      return;
    }

    context.go(normalizedRedirectTo);
  }

  static String _formatDate(DateTime date) {
    final month = switch (date.month) {
      1 => 'Jan',
      2 => 'Feb',
      3 => 'Mar',
      4 => 'Apr',
      5 => 'May',
      6 => 'Jun',
      7 => 'Jul',
      8 => 'Aug',
      9 => 'Sep',
      10 => 'Oct',
      11 => 'Nov',
      12 => 'Dec',
      _ => '',
    };

    return '$month ${date.day}, ${date.year}';
  }

  static String _formatSourceFeature(String rawFeature) {
    return switch (rawFeature) {
      'resumeGenerate' => 'Resume Builder',
      'coverLetterGenerate' => 'Cover Letter Generator',
      'interviewGenerate' => 'Interview Prep',
      'cvParse' => 'CV Parser',
      'voiceResume' => 'Voice Resume',
      'videoIntroductionGenerate' => 'Video Introduction',
      _ => 'this feature',
    };
  }
}

class _BenefitPill extends StatelessWidget {
  const _BenefitPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white.withValues(alpha: 0.9),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SubscriptionPackageCard extends StatelessWidget {
  const _SubscriptionPackageCard({
    required this.package,
    required this.isCurrentPlan,
    required this.isPurchasing,
    required this.onPressed,
  });

  final SubscriptionPackage package;
  final bool isCurrentPlan;
  final bool isPurchasing;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isHighlighted = package.plan == SubscriptionPlan.annual;

    return AppCard(
      backgroundColor: isHighlighted
          ? colorScheme.primary.withValues(alpha: 0.08)
          : colorScheme.surface,
      borderColor: isHighlighted
          ? colorScheme.primary.withValues(alpha: 0.18)
          : colorScheme.outlineVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  package.plan.label,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (isHighlighted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Best value',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            package.priceLabel,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            package.description.isEmpty
                ? package.plan.shortDescription
                : package.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          if (package.billingLabel != null) ...[
            const SizedBox(height: 8),
            Text(
              package.billingLabel!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 18),
          AIButton(
            label: isCurrentPlan ? 'Current plan' : 'Choose plan',
            icon: const Icon(Icons.auto_awesome_rounded),
            isLoading: isPurchasing,
            onPressed: isCurrentPlan ? null : onPressed,
          ),
        ],
      ),
    );
  }
}
