import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/widgets/app_placeholder_scaffold.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../cover_letter/domain/entities/cover_letter_result.dart';
import '../../../interview/domain/entities/interview_result.dart';
import '../../../resume/domain/entities/resume_result.dart';
import '../../application/history_controller.dart';
import '../../domain/entities/history_snapshot.dart';
import '../widgets/history_empty_state.dart';
import '../widgets/history_section_card.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(
      authControllerProvider.select((authState) => authState.session?.userId),
    );

    if (userId == null) {
      return const AppPlaceholderScaffold(
        eyebrow: 'History',
        title: 'Preparing history...',
        description: 'We are waiting for your account session.',
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.page),
          child: LoadingView(),
        ),
      );
    }

    final state = ref.watch(historyControllerProvider(userId));

    if (state.isLoading && state.isEmpty) {
      return const AppPlaceholderScaffold(
        eyebrow: 'History',
        title: 'Loading saved work...',
        description: 'We are gathering your saved resumes and drafts.',
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.page),
          child: LoadingView(),
        ),
      );
    }

    if (state.errorMessage != null && state.isEmpty) {
      return AppPlaceholderScaffold(
        eyebrow: 'History',
        title: 'History unavailable',
        description: 'Your saved work could not be loaded right now.',
        child: ErrorView(
          message: state.errorMessage!,
          onRetry: () => ref
              .read(historyControllerProvider(userId).notifier)
              .loadHistory(),
        ),
      );
    }

    if (state.isEmpty) {
      return AppPlaceholderScaffold(
        eyebrow: 'History',
        title: 'Your saved work will appear here',
        description:
            'Resumes, cover letters and interview sets are grouped in one place for faster review.',
        child: HistoryEmptyState(
          onPrimaryAction: () => context.go(AppRoutes.home),
        ),
      );
    }

    return Scaffold(
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
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_outlined),
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
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HistoryOverviewCard(snapshot: state.snapshot),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.page),
                    ErrorView(
                      message: state.errorMessage!,
                      onRetry: () => ref
                          .read(historyControllerProvider(userId).notifier)
                          .loadHistory(),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.page),
                  _ResumeHistorySection(items: state.snapshot.resumes),
                  const SizedBox(height: AppSpacing.page),
                  _CoverLetterHistorySection(
                    items: state.snapshot.coverLetters,
                  ),
                  const SizedBox(height: AppSpacing.page),
                  _InterviewHistorySection(items: state.snapshot.interviewSets),
                ],
              ),
            ),
          ],
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
    final totalCount =
        snapshot.resumes.length +
        snapshot.coverLetters.length +
        snapshot.interviewSets.length;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.surfaceContainerHighest,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saved outputs',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.compact),
          Text(
            '$totalCount saved items across resumes, cover letters and interview prep.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumeHistorySection extends StatelessWidget {
  const _ResumeHistorySection({required this.items});

  final List<ResumeResult> items;

  @override
  Widget build(BuildContext context) {
    return HistorySectionCard(
      title: 'Resumes',
      subtitle: '${items.length} saved',
      icon: Icons.description_outlined,
      child: items.isEmpty
          ? const Text('No saved resumes yet.')
          : Column(
              children: [
                for (var index = 0; index < items.length; index++) ...[
                  _ResumeHistoryTile(item: items[index]),
                  if (index != items.length - 1)
                    const Divider(height: AppSpacing.page),
                ],
              ],
            ),
    );
  }
}

class _ResumeHistoryTile extends StatelessWidget {
  const _ResumeHistoryTile({required this.item});

  final ResumeResult item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.summary,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '${item.experienceBullets.length} bullets • ${item.skills.length} skills',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (item.skills.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final skill in item.skills.take(4))
                Chip(label: Text(skill), visualDensity: VisualDensity.compact),
            ],
          ),
        ],
      ],
    );
  }
}

class _CoverLetterHistorySection extends StatelessWidget {
  const _CoverLetterHistorySection({required this.items});

  final List<CoverLetterResult> items;

  @override
  Widget build(BuildContext context) {
    return HistorySectionCard(
      title: 'Cover Letters',
      subtitle: '${items.length} saved',
      icon: Icons.edit_note_outlined,
      child: items.isEmpty
          ? const Text('No saved cover letters yet.')
          : Column(
              children: [
                for (var index = 0; index < items.length; index++) ...[
                  _CoverLetterHistoryTile(item: items[index]),
                  if (index != items.length - 1)
                    const Divider(height: AppSpacing.page),
                ],
              ],
            ),
    );
  }
}

class _CoverLetterHistoryTile extends StatelessWidget {
  const _CoverLetterHistoryTile({required this.item});

  final CoverLetterResult item;

  @override
  Widget build(BuildContext context) {
    final preview = item.coverLetter.replaceAll('\n', ' ').trim();

    return Text(
      preview.length > 220 ? '${preview.substring(0, 220)}...' : preview,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.55),
    );
  }
}

class _InterviewHistorySection extends StatelessWidget {
  const _InterviewHistorySection({required this.items});

  final List<InterviewResult> items;

  @override
  Widget build(BuildContext context) {
    return HistorySectionCard(
      title: 'Interview Sets',
      subtitle: '${items.length} saved',
      icon: Icons.record_voice_over_outlined,
      child: items.isEmpty
          ? const Text('No saved interview prep yet.')
          : Column(
              children: [
                for (var index = 0; index < items.length; index++) ...[
                  _InterviewHistoryTile(item: items[index]),
                  if (index != items.length - 1)
                    const Divider(height: AppSpacing.page),
                ],
              ],
            ),
    );
  }
}

class _InterviewHistoryTile extends StatelessWidget {
  const _InterviewHistoryTile({required this.item});

  final InterviewResult item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstQuestion = item.technicalQuestions.isNotEmpty
        ? item.technicalQuestions.first.question
        : item.behavioralQuestions.isNotEmpty
        ? item.behavioralQuestions.first.question
        : 'Saved interview set';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          firstQuestion,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '${item.technicalQuestions.length} technical • ${item.behavioralQuestions.length} behavioral',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
