import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../ui/components/ai_button.dart';
import '../../../../ui/components/app_card.dart';
import '../../../../ui/components/assistant_orb.dart';
import '../../../../ui/components/section_header.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../paywall/application/subscription_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final subscriptionState = ref.watch(subscriptionControllerProvider);
    final session = authState.session;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Future<void> signOut() async {
      try {
        await ref.read(authControllerProvider.notifier).signOut();
      } on AppException catch (error) {
        if (!context.mounted) {
          return;
        }
        AppFeedback.showError(context, error.message);
      }
    }

    Future<void> restore() async {
      try {
        await ref
            .read(subscriptionControllerProvider.notifier)
            .restorePurchases();
        if (!context.mounted) {
          return;
        }
        AppFeedback.showSuccess(context, 'Purchases restored successfully.');
      } on AppException catch (error) {
        if (!context.mounted) {
          return;
        }
        AppFeedback.showError(context, error.message);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          children: [
            AppCard(
              backgroundColor: colorScheme.primary.withValues(alpha: 0.08),
              borderColor: colorScheme.primary.withValues(alpha: 0.18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AssistantOrb(size: 52),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session?.fullName ??
                              session?.email ??
                              'AI Career Copilot',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          session?.email ?? 'Signed in user',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          session?.targetRole ?? 'Target role not set yet',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(
              title: 'Account',
              subtitle: 'Keep subscription and session settings in one place.',
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Subscription',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subscriptionState.isPremium
                        ? '${subscriptionState.status.plan.label} plan is active.'
                        : 'Free plan active.',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subscriptionState.isPremium
                        ? 'Unlimited AI generations are available for your account.'
                        : 'Upgrade to unlock unlimited AI tools and advanced career support.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (subscriptionState.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      subscriptionState.errorMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      AIButton(
                        label: 'View plans',
                        expanded: false,
                        icon: const Icon(Icons.workspace_premium_outlined),
                        onPressed: () => context.go(AppRoutes.paywall),
                      ),
                      AIButton(
                        label: 'Restore purchases',
                        expanded: false,
                        variant: AIButtonVariant.secondary,
                        icon: const Icon(Icons.restore_rounded),
                        isLoading: subscriptionState.isRestoring,
                        onPressed: subscriptionState.isRestoring
                            ? null
                            : restore,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Session',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Signed in as ${session?.email ?? 'unknown user'}.',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),
                  AIButton(
                    label: 'Sign out',
                    icon: const Icon(Icons.logout_rounded),
                    isLoading: authState.isSubmitting,
                    onPressed: authState.isSubmitting ? null : signOut,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
