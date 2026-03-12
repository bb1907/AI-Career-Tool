import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../paywall/application/subscription_controller.dart';
import '../providers/recent_documents_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const _featureCards = <_FeatureCardData>[
    _FeatureCardData(
      title: 'Resume Builder',
      description:
          'Create focused resumes for each role with cleaner structure and faster edits.',
      route: AppRoutes.resume,
      icon: Icons.description_outlined,
      accent: Color(0xFF0F766E),
    ),
    _FeatureCardData(
      title: 'Cover Letter Generator',
      description:
          'Draft tailored letters with role-aware messaging and a sharper value proposition.',
      route: AppRoutes.coverLetter,
      icon: Icons.edit_note_outlined,
      accent: Color(0xFF2563EB),
    ),
    _FeatureCardData(
      title: 'Interview Prep',
      description:
          'Practice likely questions and tighten your answers before the real interview.',
      route: AppRoutes.interview,
      icon: Icons.record_voice_over_outlined,
      accent: Color(0xFFEA580C),
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final userId = ref.watch(
      authControllerProvider.select((authState) => authState.session?.userId),
    );
    final subscriptionState = ref.watch(subscriptionControllerProvider);
    final recentDocuments = userId == null
        ? const AsyncData(RecentDocumentsState())
        : ref.watch(recentDocumentsProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Workspace',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              AppConstants.homeHeadline,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'History',
            onPressed: () => context.go(AppRoutes.history),
            icon: const Icon(Icons.history_outlined),
          ),
          IconButton(
            tooltip: 'Profile & Settings',
            onPressed: () => context.go(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.compact,
            AppSpacing.page,
            AppSpacing.page,
          ),
          children: [
            _HeroSummaryCard(
              onSettingsPressed: () => context.go(AppRoutes.settings),
              onImportCvPressed: () => context.go(AppRoutes.profileImport),
            ),
            const SizedBox(height: AppSpacing.page),
            Text(
              'Core tools',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.compact),
            Column(
              children: [
                for (var index = 0; index < _featureCards.length; index++) ...[
                  _FeatureCard(
                    data: _featureCards[index],
                    onTap: () => context.go(_featureCards[index].route),
                  ),
                  if (index != _featureCards.length - 1)
                    const SizedBox(height: AppSpacing.section),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.page),
            Text(
              'Recent',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.compact),
            _RecentDocumentsCard(
              recentDocuments: recentDocuments,
              onHistoryPressed: () => context.go(AppRoutes.history),
            ),
            const SizedBox(height: AppSpacing.page),
            _PremiumUpsellCard(
              isPremium: subscriptionState.isPremium,
              isLoading: subscriptionState.isLoading,
              planLabel: subscriptionState.status.plan.label,
              hasError: subscriptionState.errorMessage != null,
              onPressed: () => context.go(AppRoutes.paywall),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentDocumentsCard extends StatelessWidget {
  const _RecentDocumentsCard({
    required this.recentDocuments,
    required this.onHistoryPressed,
  });

  final AsyncValue<RecentDocumentsState> recentDocuments;
  final VoidCallback onHistoryPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.section),
        child: recentDocuments.when(
          data: (state) {
            if (state.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No saved work yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.compact),
                  Text(
                    'Generate and save a resume, cover letter or interview set to see it here first.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.section),
                  FilledButton.tonalIcon(
                    onPressed: onHistoryPressed,
                    icon: const Icon(Icons.history_outlined),
                    label: const Text('Open history'),
                  ),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recently saved',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.compact),
                Text(
                  'Jump back into your latest saved outputs without opening the full history screen.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                if (state.hasSectionErrors) ...[
                  const SizedBox(height: AppSpacing.compact),
                  Text(
                    'Some saved sources are temporarily unavailable.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.section),
                for (var index = 0; index < state.items.length; index++) ...[
                  _RecentDocumentTile(item: state.items[index]),
                  if (index != state.items.length - 1)
                    const Divider(height: AppSpacing.page),
                ],
                const SizedBox(height: AppSpacing.section),
                FilledButton.tonalIcon(
                  onPressed: onHistoryPressed,
                  icon: const Icon(Icons.history_outlined),
                  label: const Text('Open full history'),
                ),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.section),
            child: LoadingView(label: 'Loading recent work...'),
          ),
          error: (_, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent activity unavailable',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.compact),
              ErrorView(
                message: 'Recent saved work could not be loaded right now.',
                onRetry: onHistoryPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentDocumentTile extends StatelessWidget {
  const _RecentDocumentTile({required this.item});

  final RecentDocumentItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => context.go(item.route),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(item.icon, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.typeLabel,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroSummaryCard extends StatelessWidget {
  const _HeroSummaryCard({
    required this.onSettingsPressed,
    required this.onImportCvPressed,
  });

  final VoidCallback onSettingsPressed;
  final VoidCallback onImportCvPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.72),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.auto_awesome, color: Colors.white),
              ),
              const Spacer(),
              FilledButton.tonalIcon(
                onPressed: onSettingsPressed,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.16),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.person_outline),
                label: const Text('Profile'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.page),
          Text(
            'Everything you need for the next application sprint.',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.compact),
          Text(
            'Move between resume drafting, cover letters and interview prep without losing your recent work.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.page),
          FilledButton.tonalIcon(
            onPressed: onImportCvPressed,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.16),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.upload_file_outlined),
            label: const Text('Import CV'),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.data, required this.onTap});

  final _FeatureCardData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: data.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Icon(data.icon, color: data.accent),
              ),
              const SizedBox(height: AppSpacing.page),
              Text(
                data.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.compact),
              Text(
                data.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: AppSpacing.section),
              Row(
                children: [
                  Text(
                    'Open tool',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: data.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward, color: data.accent),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumUpsellCard extends StatelessWidget {
  const _PremiumUpsellCard({
    required this.isPremium,
    required this.isLoading,
    required this.planLabel,
    required this.hasError,
    required this.onPressed,
  });

  final bool isPremium;
  final bool isLoading;
  final String planLabel;
  final bool hasError;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = isPremium ? 'Premium active' : 'Premium';
    final headline = isPremium
        ? '$planLabel plan enabled'
        : 'Unlock richer feedback and faster drafts.';
    final description = switch ((isPremium, isLoading)) {
      (true, _) =>
        'Your account already has premium access for deeper resume feedback, stronger cover letters and more advanced interview prep.',
      (false, true) => 'Checking your latest subscription status...',
      _ =>
        'Get deeper ATS suggestions, sharper cover letter personalization and more advanced interview prep flows.',
    };
    final buttonLabel = isPremium ? 'Manage subscription' : 'Explore Premium';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: const Color(0xFF111827),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: const Color(0xFFFDE68A),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.compact),
          Text(
            headline,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.compact),
          Text(
            description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
              height: 1.45,
            ),
          ),
          if (isLoading) ...[
            const SizedBox(height: AppSpacing.section),
            const LinearProgressIndicator(
              minHeight: 4,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
          ],
          if (hasError && !isPremium) ...[
            const SizedBox(height: AppSpacing.compact),
            Text(
              'Subscription details are temporarily unavailable.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.78),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.page),
          SizedBox(
            width: 220,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF111827),
              ),
              child: Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCardData {
  const _FeatureCardData({
    required this.title,
    required this.description,
    required this.route,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String description;
  final String route;
  final IconData icon;
  final Color accent;
}
