import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../services/analytics/analytics_events.dart';
import '../../../../services/analytics/analytics_service.dart';
import '../../../../ui/components/ai_button.dart';
import '../../../../ui/components/app_card.dart';
import '../../../../ui/components/assistant_orb.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../cover_letter/domain/entities/cover_letter_result.dart';
import '../../../interview/domain/entities/interview_result.dart';
import '../../../resume/domain/entities/resume_result.dart';
import '../../application/history_controller.dart';
import '../../domain/entities/history_section.dart';
import '../../domain/entities/history_snapshot.dart';
import '../widgets/history_empty_state.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      unawaited(
        ref
            .read(analyticsServiceProvider)
            .logEvent(AnalyticsEvents.historyOpened),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final userId = ref.watch(
      authControllerProvider.select((authState) => authState.session?.userId),
    );

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('History')),
        body: const SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      );
    }

    final state = ref.watch(historyControllerProvider(userId));

    if (state.isLoading && !state.hasRenderableSections) {
      return Scaffold(
        appBar: AppBar(title: const Text('History')),
        body: const SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      );
    }

    if (state.errorMessage != null && !state.hasRenderableSections) {
      return Scaffold(
        appBar: AppBar(title: const Text('History')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'History unavailable',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.errorMessage!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AIButton(
                    label: 'Retry',
                    expanded: false,
                    onPressed: () => ref
                        .read(historyControllerProvider(userId).notifier)
                        .loadHistory(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (!state.hasRenderableSections) {
      return Scaffold(
        appBar: AppBar(title: const Text('History')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: HistoryEmptyState(
              onPrimaryAction: () => context.go(AppRoutes.home),
            ),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('History'),
          actions: [
            IconButton(
              tooltip: 'Refresh',
              onPressed: state.isLoading
                  ? null
                  : () => ref
                        .read(historyControllerProvider(userId).notifier)
                        .loadHistory(),
              icon: state.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Column(
                  children: [
                    _HistoryOverviewCard(snapshot: state.snapshot),
                    if (state.isLoading) ...[
                      const SizedBox(height: 16),
                      const LinearProgressIndicator(),
                    ],
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: 16),
                      AppCard(
                        backgroundColor: colorScheme.errorContainer.withValues(
                          alpha: 0.55,
                        ),
                        borderColor: colorScheme.error.withValues(alpha: 0.18),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.error_outline, color: colorScheme.error),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                state.errorMessage!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: TabBar(
                        tabs: const [
                          Tab(text: 'Resumes'),
                          Tab(text: 'Cover Letters'),
                          Tab(text: 'Interview Sets'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  children: [
                    _ResumeHistoryTab(
                      section: state.snapshot.resumes,
                      onRetry: () => ref
                          .read(historyControllerProvider(userId).notifier)
                          .loadHistory(),
                    ),
                    _CoverLetterHistoryTab(
                      section: state.snapshot.coverLetters,
                      onRetry: () => ref
                          .read(historyControllerProvider(userId).notifier)
                          .loadHistory(),
                    ),
                    _InterviewHistoryTab(
                      section: state.snapshot.interviewSets,
                      onRetry: () => ref
                          .read(historyControllerProvider(userId).notifier)
                          .loadHistory(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryOverviewCard extends StatelessWidget {
  const _HistoryOverviewCard({required this.snapshot});

  final HistorySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      backgroundColor: colorScheme.primary.withValues(alpha: 0.08),
      borderColor: colorScheme.primary.withValues(alpha: 0.18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              AssistantOrb(size: 40),
              SizedBox(width: 14),
              Expanded(child: Text('Your saved AI work')),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${snapshot.totalCount} saved items across resumes, cover letters and interview prep.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatBadge(
                label: 'Resumes',
                value: snapshot.resumes.count.toString(),
              ),
              _StatBadge(
                label: 'Cover Letters',
                value: snapshot.coverLetters.count.toString(),
              ),
              _StatBadge(
                label: 'Interview Sets',
                value: snapshot.interviewSets.count.toString(),
              ),
            ],
          ),
          if (snapshot.hasAnyError) ...[
            const SizedBox(height: 16),
            Text(
              'Some sections are temporarily unavailable, but available items are still shown below.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumeHistoryTab extends StatelessWidget {
  const _ResumeHistoryTab({required this.section, required this.onRetry});

  final HistorySection<ResumeResult> section;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (section.hasError) {
      return _SectionStateCard(
        title: 'Resumes unavailable',
        message: section.errorMessage!,
        onRetry: onRetry,
      );
    }

    if (section.isEmpty) {
      return const _SectionEmptyCard(
        title: 'No saved resumes yet',
        message: 'Save your first generated resume and it will appear here.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: section.items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = section.items[index];
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.summary,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                '${item.experienceBullets.length} bullets • ${item.skills.length} skills • ${_formatDate(item.createdAt)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              if (item.skills.isNotEmpty) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final skill in item.skills.take(5))
                      Chip(
                        label: Text(skill),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _CoverLetterHistoryTab extends StatelessWidget {
  const _CoverLetterHistoryTab({required this.section, required this.onRetry});

  final HistorySection<CoverLetterResult> section;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (section.hasError) {
      return _SectionStateCard(
        title: 'Cover letters unavailable',
        message: section.errorMessage!,
        onRetry: onRetry,
      );
    }

    if (section.isEmpty) {
      return const _SectionEmptyCard(
        title: 'No saved cover letters yet',
        message:
            'Tailored letters you save from the generator will show up here.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: section.items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = section.items[index];
        final preview = item.coverLetter.replaceAll('\n', ' ').trim();
        final clipped = preview.length > 220
            ? '${preview.substring(0, 220)}...'
            : preview;
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                clipped,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(height: 1.55),
              ),
              const SizedBox(height: 12),
              Text(
                _formatDate(item.createdAt),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InterviewHistoryTab extends StatelessWidget {
  const _InterviewHistoryTab({required this.section, required this.onRetry});

  final HistorySection<InterviewResult> section;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (section.hasError) {
      return _SectionStateCard(
        title: 'Interview sets unavailable',
        message: section.errorMessage!,
        onRetry: onRetry,
      );
    }

    if (section.isEmpty) {
      return const _SectionEmptyCard(
        title: 'No saved interview sets yet',
        message:
            'Saved question sets and sample answers will appear in this tab.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: section.items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = section.items[index];
        final firstQuestion = item.technicalQuestions.isNotEmpty
            ? item.technicalQuestions.first.question
            : item.behavioralQuestions.isNotEmpty
            ? item.behavioralQuestions.first.question
            : 'Saved interview set';
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                firstQuestion,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                '${item.technicalQuestions.length} technical • ${item.behavioralQuestions.length} behavioral • ${_formatDate(item.createdAt)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionStateCard extends StatelessWidget {
  const _SectionStateCard({
    required this.title,
    required this.message,
    required this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              AIButton(
                label: 'Retry section load',
                expanded: false,
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionEmptyCard extends StatelessWidget {
  const _SectionEmptyCard({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDate(DateTime? date) {
  if (date == null) {
    return 'Saved recently';
  }

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
