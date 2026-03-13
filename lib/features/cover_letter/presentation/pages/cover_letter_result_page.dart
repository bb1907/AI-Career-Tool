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
import '../../application/cover_letter_controller.dart';
import '../../domain/entities/cover_letter_request.dart';
import '../widgets/cover_letter_editor_card.dart';

class CoverLetterResultPage extends ConsumerStatefulWidget {
  const CoverLetterResultPage({super.key});

  @override
  ConsumerState<CoverLetterResultPage> createState() =>
      _CoverLetterResultPageState();
}

class _CoverLetterResultPageState extends ConsumerState<CoverLetterResultPage> {
  final _editorController = TextEditingController();

  @override
  void dispose() {
    _editorController.dispose();
    super.dispose();
  }

  Future<void> _copyDraft(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _editorController.text));
    if (!context.mounted) {
      return;
    }
    AppFeedback.showSuccess(context, 'Cover letter copied to your clipboard.');
  }

  Future<void> _saveDraft(BuildContext context) async {
    try {
      await ref
          .read(coverLetterControllerProvider.notifier)
          .saveCurrentCoverLetter(_editorController.text);
      if (!context.mounted) {
        return;
      }
      AppFeedback.showSuccess(context, 'Cover letter saved to your history.');
    } on AppException catch (error) {
      if (!context.mounted) {
        return;
      }
      AppFeedback.showError(context, error.message);
    }
  }

  void _explainSuggestion(BuildContext context, String label) {
    AppFeedback.showInfo(
      context,
      'Use the editable draft below to apply: $label',
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(coverLetterControllerProvider, (previous, next) {
      final nextText = next.result?.coverLetter;
      final previousText = previous?.result?.coverLetter;
      if (nextText != null &&
          nextText != previousText &&
          nextText != _editorController.text) {
        _editorController
          ..text = nextText
          ..selection = TextSelection.collapsed(offset: nextText.length);
      }
    });

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(coverLetterControllerProvider);
    final request = state.request;
    final result = state.result;

    if (state.isGenerating && result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cover Letter Generator')),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Generating cover letter...'),
                  const SizedBox(height: 16),
                  AILoadingIndicator(
                    messages: [
                      'Analyzing company context...',
                      'Positioning your strongest experience...',
                      'Drafting a more targeted cover letter...',
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
        appBar: AppBar(title: const Text('Cover Letter Generator')),
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
                                  .read(coverLetterControllerProvider.notifier)
                                  .startGeneration(request),
                      ),
                      AIButton(
                        label: 'Back to form',
                        expanded: false,
                        variant: AIButtonVariant.secondary,
                        onPressed: () => context.go(AppRoutes.coverLetter),
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
        appBar: AppBar(title: const Text('Cover Letter Generator')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'No draft yet',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a company, role and job context before opening the result screen.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AIButton(
                    label: 'Open cover letter form',
                    expanded: false,
                    onPressed: () => context.go(AppRoutes.coverLetter),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final score = _coverLetterScore(result.coverLetter, request);
    final suggestions = _buildSuggestions(request);

    return Scaffold(
      appBar: AppBar(title: const Text('Cover Letter Generator')),
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
                          ? 'Tailored company draft'
                          : 'Tailored company draft',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      request == null
                          ? 'Edit the draft, regenerate it with the same context, or save it for a later application pass.'
                          : '${request.companyName} • ${request.roleTitle}',
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
                          label: 'AI Cover Letter Score',
                          score: score,
                        ),
                        const AIScoreBadge(
                          label: 'Role Fit',
                          status: 'Tailored',
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
                          onPressed: () => _copyDraft(context),
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
                              : () => _saveDraft(context),
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
                                    .read(
                                      coverLetterControllerProvider.notifier,
                                    )
                                    .startGeneration(request),
                        ),
                        AIButton(
                          label: '✨ Improve with AI',
                          expanded: false,
                          variant: AIButtonVariant.ghost,
                          onPressed: state.isGenerating || request == null
                              ? null
                              : () => ref
                                    .read(
                                      coverLetterControllerProvider.notifier,
                                    )
                                    .startGeneration(request),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(
                      title: 'AI suggestions',
                      subtitle:
                          'Use these cues to make the letter sound more specific and convincing before you send it.',
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final suggestion in suggestions)
                          SuggestionChip(
                            label: suggestion,
                            onPressed: () =>
                                _explainSuggestion(context, suggestion),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(
                      title: 'Editable draft',
                      subtitle:
                          'Refine the wording, tighten weak phrases and make sure the voice still sounds like you.',
                    ),
                    const SizedBox(height: 16),
                    CoverLetterEditorCard(
                      controller: _editorController,
                      enabled: !state.isSaving,
                      onChanged: (value) => ref
                          .read(coverLetterControllerProvider.notifier)
                          .updateDraft(value),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: AIButton(
                        label: 'Back to form',
                        expanded: false,
                        variant: AIButtonVariant.ghost,
                        onPressed: () => context.pop(),
                      ),
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

  int _coverLetterScore(String draft, CoverLetterRequest? request) {
    var score = 70;
    if (request?.jobContext != null) {
      score += 8;
    }
    if (request?.candidateContext != null) {
      score += 8;
    }
    if (request?.clarifyingContext?.hasContent ?? false) {
      score += 6;
    }
    if (draft.length >= 700) {
      score += 6;
    }
    return math.min(score, 96);
  }

  List<String> _buildSuggestions(CoverLetterRequest? request) {
    final suggestions = <String>[
      'Add measurable impact',
      'Tighten the opening hook',
    ];

    if (request?.candidateContext?.seniority.trim().isNotEmpty ?? false) {
      suggestions.add('Mention leadership scope');
    }
    if (request?.jobContext?.jobDescription.toLowerCase().contains('sql') ??
        false) {
      suggestions.add('Reference SQL experience');
    }
    if (request?.clarifyingContext?.whyThisCompany.trim().isNotEmpty ?? false) {
      suggestions.add('Make the company motivation more explicit');
    }

    return suggestions;
  }
}
