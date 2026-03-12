import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/widgets/app_placeholder_scaffold.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../paywall/application/subscription_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final subscriptionState = ref.watch(subscriptionControllerProvider);
    final session = authState.session;

    return AppPlaceholderScaffold(
      eyebrow: 'Account',
      title: 'Profile & Settings',
      description:
          'Quick access to your account details and essential app actions.',
      actions: [
        SizedBox(
          width: 180,
          child: OutlinedButton(
            onPressed: () => context.go(AppRoutes.home),
            child: const Text('Back to Home'),
          ),
        ),
        SizedBox(
          width: 180,
          child: ElevatedButton(
            onPressed: authState.isSubmitting
                ? null
                : () async {
                    final messenger = ScaffoldMessenger.of(context);

                    try {
                      await ref.read(authControllerProvider.notifier).signOut();
                    } on AppException catch (error) {
                      if (!context.mounted) {
                        return;
                      }

                      messenger
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(error.message),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.error,
                          ),
                        );
                    }
                  },
            child: authState.isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Sign out'),
          ),
        ),
      ],
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.section),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session?.fullName ?? session?.email ?? 'Signed in user',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.compact),
                Text(session?.email ?? ''),
                const SizedBox(height: AppSpacing.compact),
                Text(session?.targetRole ?? 'Target role not set'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.page),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.section),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subscription',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.compact),
                Text(
                  subscriptionState.isPremium
                      ? '${subscriptionState.status.plan.label} premium is active.'
                      : 'Free plan active.',
                ),
                const SizedBox(height: AppSpacing.compact),
                Text(
                  subscriptionState.isPremium
                      ? 'Premium access is managed through the App Store and RevenueCat entitlements.'
                      : 'Upgrade to unlock premium resume, cover letter and interview experiences.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
                if (subscriptionState.status.managementUrl != null) ...[
                  const SizedBox(height: AppSpacing.compact),
                  Text(
                    'Manage renewals from your App Store subscription settings.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (subscriptionState.errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.compact),
                  Text(
                    subscriptionState.errorMessage!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.section),
                Wrap(
                  spacing: AppSpacing.compact,
                  runSpacing: AppSpacing.compact,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: subscriptionState.isRestoring
                          ? null
                          : () async {
                              final messenger = ScaffoldMessenger.of(context);

                              try {
                                await ref
                                    .read(
                                      subscriptionControllerProvider.notifier,
                                    )
                                    .restorePurchases();
                                if (!context.mounted) {
                                  return;
                                }

                                messenger
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Purchases restored successfully.',
                                      ),
                                    ),
                                  );
                              } on AppException catch (error) {
                                if (!context.mounted) {
                                  return;
                                }

                                messenger
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: Text(error.message),
                                      backgroundColor: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                  );
                              }
                            },
                      icon: subscriptionState.isRestoring
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.restore),
                      label: const Text('Restore purchases'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.go(AppRoutes.paywall),
                      icon: const Icon(Icons.workspace_premium_outlined),
                      label: Text(
                        subscriptionState.isPremium
                            ? 'Manage premium'
                            : 'View plans',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
