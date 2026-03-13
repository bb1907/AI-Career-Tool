import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_placeholder_scaffold.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../application/cover_letter_controller.dart';
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

    final state = ref.watch(coverLetterControllerProvider);
    final result = state.result;
    final theme = Theme.of(context);

    if (state.isGenerating && result == null) {
      return AppPlaceholderScaffold(
        eyebrow: 'Cover letter',
        title: 'Generating cover letter...',
        description:
            'We are tailoring the draft to the company, role and job description you provided.',
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.page),
          child: LoadingView(),
        ),
      );
    }

    if (state.errorMessage != null && result == null) {
      return AppPlaceholderScaffold(
        eyebrow: 'Cover letter',
        title: 'Generation failed',
        description: 'The cover letter could not be generated.',
        actions: [
          FilledButton.tonal(
            onPressed: state.request == null
                ? null
                : () => ref
                      .read(coverLetterControllerProvider.notifier)
                      .startGeneration(state.request!),
            child: const Text('Try again'),
          ),
          OutlinedButton(
            onPressed: () => context.go(AppRoutes.coverLetter),
            child: const Text('Back to form'),
          ),
        ],
        child: ErrorView(message: state.errorMessage!),
      );
    }

    if (result == null) {
      return AppPlaceholderScaffold(
        eyebrow: 'Cover letter',
        title: 'No draft yet',
        description:
            'Fill in the company and role details before opening the result screen.',
        actions: [
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.coverLetter),
            child: const Text('Open cover letter form'),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Cover Letter Result')),
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
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tailored company draft',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.compact),
                          Text(
                            'Edit the draft, regenerate it with the same inputs or save it into your history.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.page),
                          Wrap(
                            spacing: AppSpacing.compact,
                            runSpacing: AppSpacing.compact,
                            children: [
                              AppButton(
                                label: 'Copy',
                                expanded: false,
                                variant: AppButtonVariant.secondary,
                                icon: const Icon(Icons.copy_all_outlined),
                                onPressed: () => _copyDraft(context),
                              ),
                              AppButton(
                                label: state.isSaving
                                    ? 'Saving...'
                                    : state.hasSaved
                                    ? 'Saved'
                                    : 'Save',
                                expanded: false,
                                variant: AppButtonVariant.tonal,
                                icon: Icon(
                                  state.hasSaved
                                      ? Icons.check_circle_outline
                                      : Icons.bookmark_border,
                                ),
                                isLoading: state.isSaving,
                                onPressed: state.isSaving
                                    ? null
                                    : () => _saveDraft(context),
                              ),
                              AppButton(
                                label: state.isGenerating
                                    ? 'Regenerating...'
                                    : 'Regenerate',
                                expanded: false,
                                icon: const Icon(Icons.refresh),
                                isLoading: state.isGenerating,
                                onPressed:
                                    state.isGenerating || state.request == null
                                    ? null
                                    : () => ref
                                          .read(
                                            coverLetterControllerProvider
                                                .notifier,
                                          )
                                          .startGeneration(state.request!),
                              ),
                              AppButton(
                                label: 'Back to form',
                                expanded: false,
                                variant: AppButtonVariant.secondary,
                                onPressed: () => context.pop(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.page),
                  CoverLetterEditorCard(
                    controller: _editorController,
                    enabled: !state.isSaving,
                    onChanged: (value) => ref
                        .read(coverLetterControllerProvider.notifier)
                        .updateDraft(value),
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
