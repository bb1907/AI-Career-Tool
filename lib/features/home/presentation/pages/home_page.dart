import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/app_spacing.dart';

class HomePage extends StatelessWidget {
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

  static const _recentItems = <_RecentItemData>[
    _RecentItemData(
      title: 'Product Designer Resume',
      subtitle: 'Updated 2 hours ago',
      route: AppRoutes.resume,
      typeLabel: 'Resume',
    ),
    _RecentItemData(
      title: 'Growth Lead Cover Letter',
      subtitle: 'Edited yesterday',
      route: AppRoutes.coverLetter,
      typeLabel: 'Cover Letter',
    ),
    _RecentItemData(
      title: 'Series A PM Interview Pack',
      subtitle: 'Prepared 2 days ago',
      route: AppRoutes.interview,
      typeLabel: 'Interview',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
              AppConfig.homeHeadline,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
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
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.section),
                child: Column(
                  children: [
                    for (
                      var index = 0;
                      index < _recentItems.length;
                      index++
                    ) ...[
                      _RecentItemTile(
                        data: _recentItems[index],
                        onTap: () => context.go(_recentItems[index].route),
                      ),
                      if (index != _recentItems.length - 1)
                        const Divider(height: AppSpacing.page),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.page),
            _PremiumUpsellCard(onPressed: () => context.go(AppRoutes.paywall)),
          ],
        ),
      ),
    );
  }
}

class _HeroSummaryCard extends StatelessWidget {
  const _HeroSummaryCard({required this.onSettingsPressed});

  final VoidCallback onSettingsPressed;

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

class _RecentItemTile extends StatelessWidget {
  const _RecentItemTile({required this.data, required this.onTap});

  final _RecentItemData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                data.typeLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.section),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.compact),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _PremiumUpsellCard extends StatelessWidget {
  const _PremiumUpsellCard({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            'Premium',
            style: theme.textTheme.labelLarge?.copyWith(
              color: const Color(0xFFFDE68A),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.compact),
          Text(
            'Unlock richer feedback and faster drafts.',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.compact),
          Text(
            'Get deeper ATS suggestions, sharper cover letter personalization and more advanced interview prep flows.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.page),
          SizedBox(
            width: 220,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF111827),
              ),
              child: const Text('Explore Premium'),
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

class _RecentItemData {
  const _RecentItemData({
    required this.title,
    required this.subtitle,
    required this.route,
    required this.typeLabel,
  });

  final String title;
  final String subtitle;
  final String route;
  final String typeLabel;
}
