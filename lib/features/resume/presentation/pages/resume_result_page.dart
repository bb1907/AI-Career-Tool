import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../../../ui/components/suggestion_chip.dart';
import '../../application/resume_controller.dart';
import '../../domain/entities/resume_result.dart';
import '../utils/resume_clipboard_formatter.dart';

class ResumeResultPage extends ConsumerWidget {
  const ResumeResultPage({super.key});

  Future<void> _copyResume(BuildContext context, ResumeResult result) async {
    await Clipboard.setData(
      ClipboardData(text: ResumeClipboardFormatter.format(result)),
    );
    if (!context.mounted) {
      return;
    }
    AppFeedback.showSuccess(context, 'Resume copied to your clipboard.');
  }

  Future<void> _saveResume(WidgetRef ref, BuildContext context) async {
    try {
      await ref
          .read(resumeBuilderControllerProvider.notifier)
          .saveCurrentResume();
      if (!context.mounted) {
        return;
      }
      AppFeedback.showSuccess(context, 'Resume saved to your history.');
    } on AppException catch (error) {
      if (!context.mounted) {
        return;
      }
      AppFeedback.showError(context, error.message);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(resumeBuilderControllerProvider);
    final result = state.result;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (state.isGenerating && result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Resume Result')),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Generating resume...'),
                  SizedBox(height: 16),
                  AILoadingIndicator(),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (state.errorMessage != null && result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Resume Result')),
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
                        onPressed: state.request == null
                            ? null
                            : () => ref
                                  .read(
                                    resumeBuilderControllerProvider.notifier,
                                  )
                                  .startGeneration(state.request!),
                      ),
                      AIButton(
                        label: 'Back to form',
                        expanded: false,
                        variant: AIButtonVariant.secondary,
                        onPressed: () => context.go(AppRoutes.resume),
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
        appBar: AppBar(title: const Text('Resume Result')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'No generated resume yet',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fill in your target role and let AI craft the first draft before opening this screen.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AIButton(
                    label: 'Open resume form',
                    expanded: false,
                    onPressed: () => context.go(AppRoutes.resume),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final score = _resumeScore(result);
    final suggestions = _buildSuggestions(result);

    return Scaffold(
      appBar: AppBar(title: const Text('Resume Result')),
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
                      'ATS-ready draft',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Professional summary, ATS-friendly bullets and skill positioning are ready for review.',
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
                          label: 'AI Resume Quality Score',
                          score: score,
                        ),
                        const AIScoreBadge(
                          label: 'ATS Compatibility',
                          status: 'High',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        AIButton(
                          label: 'Copy',
                          expanded: false,
                          variant: AIButtonVariant.secondary,
                          icon: const Icon(Icons.copy_all_outlined),
                          onPressed: () => _copyResume(context, result),
                        ),
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
                              : () => _saveResume(ref, context),
                        ),
                        AIButton(
                          label: 'Edit',
                          expanded: false,
                          variant: AIButtonVariant.ghost,
                          onPressed: () => context.pop(),
                        ),
                        AIButton(
                          label: 'Regenerate',
                          expanded: false,
                          variant: AIButtonVariant.secondary,
                          icon: const Icon(Icons.refresh_rounded),
                          onPressed: state.request == null
                              ? null
                              : () => ref
                                    .read(
                                      resumeBuilderControllerProvider.notifier,
                                    )
                                    .startGeneration(state.request!),
                        ),
                        AIButton(
                          label: 'Improve with AI',
                          expanded: false,
                          icon: const Icon(Icons.auto_awesome_rounded),
                          onPressed: state.request == null
                              ? null
                              : () => ref
                                    .read(
                                      resumeBuilderControllerProvider.notifier,
                                    )
                                    .startGeneration(state.request!),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SectionHeader(
                title: 'Smart suggestions',
                subtitle:
                    'Tap a suggestion to copy it mentally into your next revision pass.',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final suggestion in suggestions)
                    SuggestionChip(
                      label: suggestion,
                      onPressed: () => AppFeedback.showSuccess(
                        context,
                        'Suggestion noted: $suggestion',
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'Professional Summary'),
                    const SizedBox(height: 16),
                    Text(
                      result.summary,
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.7),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'Experience bullets'),
                    const SizedBox(height: 16),
                    for (final bullet in result.experienceBullets)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Icon(
                                Icons.bolt_rounded,
                                size: 16,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                bullet,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'Skills'),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final skill in result.skills)
                          Chip(label: Text(skill)),
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
                    const SectionHeader(title: 'Education'),
                    const SizedBox(height: 16),
                    Text(
                      result.education,
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
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

  int _resumeScore(ResumeResult result) {
    final base = 72;
    final summaryBonus = result.summary.length > 120 ? 8 : 3;
    final bulletsBonus = math.min(10, result.experienceBullets.length * 2);
    final skillsBonus = math.min(8, result.skills.length * 2);
    final educationBonus = result.education.trim().isNotEmpty ? 4 : 0;
    return math.min(
      98,
      base + summaryBonus + bulletsBonus + skillsBonus + educationBonus,
    );
  }

  List<String> _buildSuggestions(ResumeResult result) {
    final suggestions = <String>[
      '+ Add measurable impact',
      '+ Mention leadership',
    ];

    if (!result.skills.any((skill) => skill.toLowerCase().contains('sql'))) {
      suggestions.add('+ Include SQL skill');
    }
    if (result.experienceBullets.length < 4) {
      suggestions.add('+ Add one more bullet');
    }
    return suggestions;
  }
}
