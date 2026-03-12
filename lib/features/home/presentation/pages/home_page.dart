import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/config/constants.dart';
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
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.section),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saved work now lives in History.',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.compact),
                    Text(
                      'Open one place to review saved resumes, cover letters and interview prep as soon as you store them.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.section),
                    FilledButton.tonalIcon(
                      onPressed: () => context.go(AppRoutes.history),
                      icon: const Icon(Icons.history_outlined),
                      label: const Text('Open history'),
                    ),
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
