import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_placeholder_scaffold.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../application/interview_controller.dart';
import '../widgets/interview_question_section.dart';

class InterviewResultPage extends ConsumerWidget {
  const InterviewResultPage({super.key});

  Future<void> _savePrep(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      await ref
          .read(interviewControllerProvider.notifier)
          .saveCurrentInterviewPrep();

      if (!context.mounted) {
        return;
      }

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Interview prep saved to history.')),
        );
    } on AppException catch (error) {
      if (!context.mounted) {
        return;
      }

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(interviewControllerProvider);
    final result = state.result;
    final theme = Theme.of(context);

    if (state.isGenerating && result == null) {
      return AppPlaceholderScaffold(
        eyebrow: 'Interview',
        title: 'Generating interview prep...',
        description:
            'We are preparing technical and behavioral questions with sample answers tailored to your role and context.',
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.page),
          child: LoadingView(),
        ),
      );
    }

    if (state.errorMessage != null && result == null) {
      return AppPlaceholderScaffold(
        eyebrow: 'Interview',
        title: 'Generation failed',
        description: 'The interview prep could not be generated.',
        actions: [
          FilledButton.tonal(
            onPressed: state.request == null
                ? null
                : () => ref
                      .read(interviewControllerProvider.notifier)
                      .startGeneration(state.request!),
            child: const Text('Try again'),
          ),
          OutlinedButton(
            onPressed: () => context.go(AppRoutes.interview),
            child: const Text('Back to form'),
          ),
        ],
        child: ErrorView(message: state.errorMessage!),
      );
    }

    if (result == null) {
      return AppPlaceholderScaffold(
        eyebrow: 'Interview',
        title: 'No interview prep yet',
        description:
            'Fill in the role and interview context before opening the result screen.',
        actions: [
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.interview),
            child: const Text('Open interview form'),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Interview Prep Result')),
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
                            'Role-specific question set',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.compact),
                          Text(
                            'Review the sample answers, refine your own talking points and save the prep for later.',
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
                                label: state.isSaving
                                    ? 'Saving...'
                                    : state.hasSaved
                                    ? 'Saved'
                                    : 'Save prep',
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
                                    : () => _savePrep(context, ref),
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
                  InterviewQuestionSection(
                    title: 'Technical questions',
                    questions: result.technicalQuestions,
                  ),
                  const SizedBox(height: AppSpacing.page),
                  InterviewQuestionSection(
                    title: 'Behavioral questions',
                    questions: result.behavioralQuestions,
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
