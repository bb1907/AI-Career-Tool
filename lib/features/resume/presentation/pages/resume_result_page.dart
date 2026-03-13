import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/widgets/app_placeholder_scaffold.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../application/resume_controller.dart';
import '../../domain/entities/resume_result.dart';
import '../utils/resume_clipboard_formatter.dart';
import '../widgets/resume_section_card.dart';

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

    if (state.isGenerating && result == null) {
      return AppPlaceholderScaffold(
        eyebrow: 'Resume',
        title: 'Generating resume...',
        description:
            'We are shaping your summary, bullet points and skills into an ATS-friendly draft.',
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.page),
          child: LoadingView(),
        ),
      );
    }

    if (state.errorMessage != null && result == null) {
      return AppPlaceholderScaffold(
        eyebrow: 'Resume',
        title: 'Generation failed',
        description: 'The generated draft could not be created.',
        actions: [
          FilledButton.tonal(
            onPressed: state.request == null
                ? null
                : () => ref
                      .read(resumeBuilderControllerProvider.notifier)
                      .startGeneration(state.request!),
            child: const Text('Try again'),
          ),
          OutlinedButton(
            onPressed: () => context.go(AppRoutes.resume),
            child: const Text('Back to form'),
          ),
        ],
        child: ErrorView(message: state.errorMessage!),
      );
    }

    if (result == null) {
      return AppPlaceholderScaffold(
        eyebrow: 'Resume',
        title: 'No generated resume yet',
        description:
            'Start with your role details and generate a resume draft before opening the result screen.',
        actions: [
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.resume),
            child: const Text('Open resume form'),
          ),
        ],
      );
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Resume Result')),
      body: SafeArea(
        child: SelectionArea(
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
                              'ATS-ready draft',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.compact),
                            Text(
                              'Review the generated content, copy it into your preferred resume template or save it into your history.',
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
                                ElevatedButton.icon(
                                  onPressed: () => _copyResume(context, result),
                                  icon: const Icon(Icons.copy_all_outlined),
                                  label: const Text('Copy'),
                                ),
                                FilledButton.tonalIcon(
                                  onPressed: state.isSaving
                                      ? null
                                      : () => _saveResume(ref, context),
                                  icon: state.isSaving
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Icon(
                                          state.hasSaved
                                              ? Icons.check_circle_outline
                                              : Icons.bookmark_border,
                                        ),
                                  label: Text(
                                    state.isSaving
                                        ? 'Saving...'
                                        : state.hasSaved
                                        ? 'Saved'
                                        : 'Save',
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: () => context.pop(),
                                  child: const Text('Back to form'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.page),
                    ResumeSectionCard(
                      title: 'Summary',
                      child: Text(
                        result.summary,
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.section),
                    ResumeSectionCard(
                      title: 'Experience bullets',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final bullet in result.experienceBullets)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.compact,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 6),
                                    child: Icon(
                                      Icons.fiber_manual_record,
                                      size: 10,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      bullet,
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(height: 1.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.section),
                    ResumeSectionCard(
                      title: 'Skills',
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final skill in result.skills)
                            Chip(label: Text(skill)),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.section),
                    ResumeSectionCard(
                      title: 'Education',
                      child: Text(
                        result.education,
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
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
}
