import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/config/constants.dart';
import '../../../../features/auth/presentation/providers/auth_controller.dart';
import '../../../../features/paywall/application/subscription_controller.dart';
import '../../../../ui/components/ai_button.dart';
import '../../../../ui/components/app_card.dart';
import '../../../../ui/components/assistant_orb.dart';
import '../../../../ui/components/feature_card.dart';
import '../../../../ui/components/section_header.dart';
import '../providers/recent_documents_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const _primaryFeatures = <_FeatureMeta>[
    _FeatureMeta(
      title: 'Resume Builder',
      description: 'Create a professional AI resume',
      route: AppRoutes.resume,
      icon: Icons.article_outlined,
    ),
    _FeatureMeta(
      title: 'Cover Letter Generator',
      description: 'Generate tailored cover letters',
      route: AppRoutes.coverLetter,
      icon: Icons.draw_outlined,
    ),
    _FeatureMeta(
      title: 'Interview Prep',
      description: 'Practice with AI interview questions',
      route: AppRoutes.interview,
      icon: Icons.record_voice_over_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authState = ref.watch(authControllerProvider);
    final subscriptionState = ref.watch(subscriptionControllerProvider);
    final session = authState.session;
    final firstName =
        session?.fullName?.trim().split(' ').firstOrNull ??
        session?.email.split('@').first ??
        'there';
    final userId = session?.userId;
    final recentDocuments = userId == null
        ? const AsyncData(RecentDocumentsState())
        : ref.watch(recentDocumentsProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            AssistantOrb(size: 34),
            SizedBox(width: 12),
            Text('AI Career Copilot'),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          children: [
            AppCard(
              backgroundColor: colorScheme.primary.withValues(alpha: 0.08),
              borderColor: colorScheme.primary.withValues(alpha: 0.18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, $firstName',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Let\'s advance your career today',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      AIButton(
                        label: 'Import CV',
                        variant: AIButtonVariant.tonal,
                        expanded: false,
                        icon: const Icon(Icons.upload_file_rounded),
                        onPressed: () => context.go(AppRoutes.profileImport),
                      ),
                      AIButton(
                        label: 'Find jobs',
                        variant: AIButtonVariant.secondary,
                        expanded: false,
                        icon: const Icon(Icons.work_outline_rounded),
                        onPressed: () => context.go(AppRoutes.jobMatching),
                      ),
                      AIButton(
                        label: 'Video intro',
                        variant: AIButtonVariant.secondary,
                        expanded: false,
                        icon: const Icon(Icons.videocam_outlined),
                        onPressed: () =>
                            context.go(AppRoutes.videoIntroduction),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(
              title: 'Workspace',
              subtitle:
                  'Use one focused action at a time and keep each output aligned to your target role.',
            ),
            const SizedBox(height: 16),
            for (final feature in _primaryFeatures) ...[
              FeatureCard(
                title: feature.title,
                description: feature.description,
                icon: feature.icon,
                badgeLabel: feature.title == 'Resume Builder' ? 'Core' : null,
                onTap: () => context.go(feature.route),
              ),
              if (feature != _primaryFeatures.last) const SizedBox(height: 16),
            ],
            const SizedBox(height: 24),
            SectionHeader(
              title: 'Recently saved',
              subtitle:
                  'Jump back into the latest career assets you generated.',
              action: TextButton(
                onPressed: () => context.go(AppRoutes.history),
                child: const Text('Open full history'),
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
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
                        const SizedBox(height: 8),
                        Text(
                          'Generate your first resume, cover letter or interview set and it will appear here.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        AIButton(
                          label: 'Open history',
                          expanded: false,
                          variant: AIButtonVariant.tonal,
                          icon: const Icon(Icons.history_rounded),
                          onPressed: () => context.go(AppRoutes.history),
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      for (var i = 0; i < state.items.length; i++) ...[
                        _RecentDocumentTile(item: state.items[i]),
                        if (i != state.items.length - 1)
                          Divider(color: colorScheme.outlineVariant),
                      ],
                      if (state.hasSectionErrors) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Some history sources are temporarily unavailable, but your latest available items are shown below.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.error,
                          ),
                        ),
                      ],
                    ],
                  );
                },
                loading: () => const _LoadingCardContent(
                  lines: [
                    'Analyzing your experience...',
                    'Matching skills with job requirements...',
                    'Crafting your professional summary...',
                  ],
                ),
                error: (_, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent activity is unavailable right now',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You can still open full history while we retry the recent feed.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AIButton(
                      label: 'Open history',
                      expanded: false,
                      variant: AIButtonVariant.tonal,
                      icon: const Icon(Icons.history_rounded),
                      onPressed: () => context.go(AppRoutes.history),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            AppCard(
              backgroundColor: subscriptionState.isPremium
                  ? colorScheme.secondaryContainer
                  : colorScheme.surface,
              borderColor: subscriptionState.isPremium
                  ? colorScheme.secondary.withValues(alpha: 0.22)
                  : colorScheme.outlineVariant,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subscriptionState.isPremium
                        ? 'Pro active'
                        : 'Upgrade to Pro',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subscriptionState.isPremium
                        ? 'Unlimited AI generations are available on your account.'
                        : 'Unlimited AI career tools, smart cover letters and advanced interview prep.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AIButton(
                    label: subscriptionState.isPremium
                        ? 'Manage plan'
                        : 'Start Pro',
                    expanded: false,
                    icon: Icon(
                      subscriptionState.isPremium
                          ? Icons.workspace_premium_outlined
                          : Icons.auto_awesome_rounded,
                    ),
                    onPressed: () => context.go(AppRoutes.paywall),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppConstants.homeHeadline,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureMeta {
  const _FeatureMeta({
    required this.title,
    required this.description,
    required this.route,
    required this.icon,
  });

  final String title;
  final String description;
  final String route;
  final IconData icon;
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
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: colorScheme.primaryContainer,
              ),
              child: Icon(item.icon, color: colorScheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.typeLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.arrow_forward_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingCardContent extends StatelessWidget {
  const _LoadingCardContent({required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            const SizedBox(height: 4),
            Icon(
              Icons.auto_awesome_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              lines.first,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

extension on List<String> {
  String? get firstOrNull => isEmpty ? null : first;
}
