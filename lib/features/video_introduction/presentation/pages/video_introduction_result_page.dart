import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_placeholder_scaffold.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../application/video_introduction_controller.dart';

class VideoIntroductionResultPage extends ConsumerWidget {
  const VideoIntroductionResultPage({super.key});

  Future<void> _copyScript(BuildContext context, String script) async {
    await Clipboard.setData(ClipboardData(text: script));
    if (!context.mounted) {
      return;
    }

    AppFeedback.showSuccess(context, 'Video script copied to your clipboard.');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(videoIntroductionControllerProvider);
    final result = state.result;
    final theme = Theme.of(context);

    if (state.isGenerating && result == null) {
      return AppPlaceholderScaffold(
        eyebrow: 'Video intro',
        title: 'Generating script...',
        description:
            'We are shaping a short script that fits your selected duration and application context.',
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.page),
          child: LoadingView(),
        ),
      );
    }

    if (state.errorMessage != null && result == null) {
      return AppPlaceholderScaffold(
        eyebrow: 'Video intro',
        title: 'Generation failed',
        description: 'The video introduction script could not be generated.',
        actions: [
          FilledButton.tonal(
            onPressed: state.request == null
                ? null
                : () => ref
                      .read(videoIntroductionControllerProvider.notifier)
                      .startGeneration(state.request!),
            child: const Text('Try again'),
          ),
          OutlinedButton(
            onPressed: () => context.go(AppRoutes.videoIntroduction),
            child: const Text('Back to form'),
          ),
        ],
        child: ErrorView(message: state.errorMessage!),
      );
    }

    if (result == null) {
      return AppPlaceholderScaffold(
        eyebrow: 'Video intro',
        title: 'No script yet',
        description: 'Fill in the brief before opening the result screen.',
        actions: [
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.videoIntroduction),
            child: const Text('Open video intro form'),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Video Introduction Script')),
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
                            '${result.duration} camera-ready script',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.compact),
                          Text(
                            'Use this as a speaking draft, adjust a few phrases to sound natural for you, then rehearse it before recording.',
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
                                onPressed: () =>
                                    _copyScript(context, result.script),
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
                                            videoIntroductionControllerProvider
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
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: SelectableText(
                        result.script,
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.7),
                      ),
                    ),
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
