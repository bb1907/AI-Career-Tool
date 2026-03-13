import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../services/analytics/analytics_events.dart';
import '../../../../services/analytics/analytics_service.dart';
import '../../../../services/subscription/subscription_package.dart';
import '../../../../services/subscription/subscription_plan.dart';
import '../../../../services/subscription/subscription_status.dart';
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
      appBar: AppBar(title: const Text('Premium')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.compact,
            AppSpacing.page,
            AppSpacing.page,
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: const Color(0xFF111827),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subscriptionState.isPremium ? 'Premium active' : 'Premium',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: const Color(0xFFFDE68A),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.compact),
                  Text(
                    subscriptionState.isPremium
                        ? '${subscriptionState.status.plan.label} access is unlocked'
                        : 'Upgrade for deeper career tools',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.compact),
                  Text(
                    subscriptionState.isPremium
                        ? 'Your account can use premium resume guidance, cover letter generation and richer interview prep flows.'
                        : 'Choose a plan to unlock richer ATS feedback, more tailored cover letters and stronger interview prep.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.84),
                      height: 1.5,
                    ),
                  ),
                  if (subscriptionState.status.expiresAt != null) ...[
                    const SizedBox(height: AppSpacing.compact),
                    Text(
                      subscriptionState.status.willRenew
                          ? 'Renews automatically after ${_formatDate(subscriptionState.status.expiresAt!)}.'
                          : 'Access remains active until ${_formatDate(subscriptionState.status.expiresAt!)}.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.78),
                      ),
                    ),
                  ],
                  if (shouldShowLimitMessage) ...[
                    const SizedBox(height: AppSpacing.section),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: Colors.white.withValues(alpha: 0.08),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
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
                          const SizedBox(height: AppSpacing.compact),
                          Text(
                            'You have used ${accessState.usedFreeGenerations} of ${accessState.freeGenerationLimit} free generations${widget.sourceFeature == null ? '' : ' for ${_formatSourceFeature(widget.sourceFeature!)}'}. Upgrade to continue from this flow without limits.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.84),
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
            const SizedBox(height: AppSpacing.page),
            Text(
              'Available plans',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.compact),
            if (subscriptionState.isLoading && !subscriptionState.hasPackages)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.section),
                  child: LoadingView(label: 'Loading premium plans...'),
                ),
              )
            else if (!subscriptionState.hasPackages &&
                subscriptionState.errorMessage != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.section),
                  child: ErrorView(
                    message: subscriptionState.errorMessage!,
                    onRetry: () {
                      ref
                          .read(subscriptionControllerProvider.notifier)
                          .refresh();
                    },
                  ),
                ),
              )
            else if (!subscriptionState.hasPackages)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.section),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No plans available yet',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.compact),
                      Text(
                        'Configure the current RevenueCat offering to show weekly, monthly or annual plans here.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.section),
                      FilledButton.tonalIcon(
                        onPressed: () {
                          ref
                              .read(subscriptionControllerProvider.notifier)
                              .refresh();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reload plans'),
                      ),
                    ],
                  ),
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
                      const SizedBox(height: AppSpacing.section),
                  ],
                ],
              ),
            const SizedBox(height: AppSpacing.page),
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.section),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Need to restore a purchase?',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.compact),
                    Text(
                      'Use restore if you already bought premium on this Apple account.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                    if (subscriptionState.errorMessage != null &&
                        subscriptionState.hasPackages) ...[
                      const SizedBox(height: AppSpacing.compact),
                      Text(
                        subscriptionState.errorMessage!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.section),
                    FilledButton.tonalIcon(
                      onPressed: subscriptionState.isRestoring
                          ? null
                          : () => _restorePurchases(context),
                      icon: subscriptionState.isRestoring
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.restore),
                      label: const Text('Restore purchases'),
                    ),
                  ],
                ),
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
    final messenger = ScaffoldMessenger.of(context);

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

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('${package.plan.label} premium unlocked.')),
        );

      _continueToOrigin(context, status);
    } on AppException catch (error) {
      if (!context.mounted || error.code == 'subscription_purchase_cancelled') {
        return;
      }

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
    }
  }

  Future<void> _restorePurchases(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      final status = await ref
          .read(subscriptionControllerProvider.notifier)
          .restorePurchases();
      if (!context.mounted) {
        return;
      }

      if (status.isPremium) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('Purchases restored successfully.')),
          );
        _continueToOrigin(context, status);
      } else {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('No active premium purchase found.')),
          );
      }
    } on AppException catch (error) {
      if (!context.mounted) {
        return;
      }

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
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
      _ => 'this feature',
    };
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

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.section),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  package.plan.label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (isHighlighted) ...[
                  const SizedBox(width: AppSpacing.compact),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Best value',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  package.priceLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.compact),
            Text(
              package.description.isEmpty
                  ? package.plan.shortDescription
                  : package.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            if (package.billingLabel != null) ...[
              const SizedBox(height: AppSpacing.compact),
              Text(
                package.billingLabel!,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.section),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isCurrentPlan ? null : onPressed,
                child: isPurchasing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isCurrentPlan ? 'Current plan' : 'Choose plan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
