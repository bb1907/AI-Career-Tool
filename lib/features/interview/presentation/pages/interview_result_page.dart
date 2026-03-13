import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../ui/components/ai_button.dart';
import '../../../../ui/components/ai_loading_indicator.dart';
import '../../../../ui/components/ai_score_badge.dart';
import '../../../../ui/components/app_card.dart';
import '../../../../ui/components/section_header.dart';
import '../../application/interview_controller.dart';
import '../../domain/entities/interview_question.dart';
import '../../domain/entities/interview_result.dart';

class InterviewResultPage extends ConsumerWidget {
  const InterviewResultPage({super.key});

  Future<void> _savePrep(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(interviewControllerProvider.notifier)
          .saveCurrentInterviewPrep();
      if (!context.mounted) {
        return;
      }
      AppFeedback.showSuccess(context, 'Interview prep saved to your history.');
    } on AppException catch (error) {
      if (!context.mounted) {
        return;
      }
      AppFeedback.showError(context, error.message);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(interviewControllerProvider);
    final result = state.result;
    final request = state.request;

    if (state.isGenerating && result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Interview Prep')),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Generating interview prep...'),
                  const SizedBox(height: 16),
                  AILoadingIndicator(
                    messages: [
                      'Generating role-specific question paths...',
                      'Balancing technical and behavioral prompts...',
                      'Drafting sample answers you can rehearse...',
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (state.errorMessage != null && result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Interview Prep')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Generation failed',
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
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      AIButton(
                        label: 'Try again',
                        expanded: false,
                        onPressed: request == null
                            ? null
                            : () => ref
                                  .read(interviewControllerProvider.notifier)
                                  .startGeneration(request),
                      ),
                      AIButton(
                        label: 'Back to form',
                        expanded: false,
                        variant: AIButtonVariant.secondary,
                        onPressed: () => context.go(AppRoutes.interview),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Interview Prep')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'No interview prep yet',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose a role, seniority and interview type before opening this screen.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AIButton(
                    label: 'Open interview form',
                    expanded: false,
                    onPressed: () => context.go(AppRoutes.interview),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final readinessScore = _readinessScore(result);

    return Scaffold(
      appBar: AppBar(title: const Text('Interview Prep')),
      body: SafeArea(
        child: SelectionArea(
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
                      request == null
                          ? 'Role-specific question set'
                          : '${request.roleName} • ${request.interviewType}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Use the sample answers to structure your own responses, not to memorize them word-for-word.',
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
                        AIScoreBadge(
                          label: 'Interview Readiness',
                          score: readinessScore,
                        ),
                        const AIScoreBadge(
                          label: 'Question Mix',
                          status: 'Balanced',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        AIButton(
                          label: state.isSaving
                              ? 'Saving...'
                              : state.hasSaved
                              ? 'Saved'
                              : 'Save',
                          expanded: false,
                          variant: AIButtonVariant.tonal,
                          icon: Icon(
                            state.hasSaved
                                ? Icons.check_circle_outline
                                : Icons.bookmark_border_rounded,
                          ),
                          isLoading: state.isSaving,
                          onPressed: state.isSaving
                              ? null
                              : () => _savePrep(context, ref),
                        ),
                        AIButton(
                          label: 'Regenerate',
                          expanded: false,
                          variant: AIButtonVariant.secondary,
                          icon: const Icon(Icons.refresh_rounded),
                          isLoading: state.isGenerating,
                          onPressed: state.isGenerating || request == null
                              ? null
                              : () => ref
                                    .read(interviewControllerProvider.notifier)
                                    .startGeneration(request),
                        ),
                        AIButton(
                          label: 'Back to form',
                          expanded: false,
                          variant: AIButtonVariant.ghost,
                          onPressed: () => context.pop(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _QuestionSectionCard(
                title: 'Technical questions',
                subtitle:
                    'Practice how you would structure the answer and which proof points you would use.',
                questions: result.technicalQuestions,
                icon: Icons.memory_rounded,
              ),
              const SizedBox(height: 24),
              _QuestionSectionCard(
                title: 'Behavioral questions',
                subtitle:
                    'Use STAR-style responses and keep the outcome measurable when possible.',
                questions: result.behavioralQuestions,
                icon: Icons.psychology_alt_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _readinessScore(InterviewResult result) {
    final totalQuestions =
        result.technicalQuestions.length + result.behavioralQuestions.length;
    return math.min(70 + (totalQuestions * 3), 95);
  }
}

class _QuestionSectionCard extends StatelessWidget {
  const _QuestionSectionCard({
    required this.title,
    required this.subtitle,
    required this.questions,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final List<InterviewQuestion> questions;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title, subtitle: subtitle, action: Icon(icon)),
          const SizedBox(height: 16),
          if (questions.isEmpty)
            Text(
              'No questions generated for this section yet.',
              style: theme.textTheme.bodyLarge,
            )
          else
            Column(
              children: [
                for (var index = 0; index < questions.length; index++) ...[
                  _QuestionCard(question: questions[index]),
                  if (index != questions.length - 1) const SizedBox(height: 16),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.question});

  final InterviewQuestion question;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorScheme.surfaceContainerLowest,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.question,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            question.sampleAnswer,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
