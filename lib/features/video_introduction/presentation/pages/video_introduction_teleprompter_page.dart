import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_feedback.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../application/teleprompter_controller.dart';
import '../../application/teleprompter_state.dart';
import '../../domain/entities/video_introduction_result.dart';

class VideoIntroductionTeleprompterPage extends ConsumerStatefulWidget {
  const VideoIntroductionTeleprompterPage({super.key, this.result});

  final VideoIntroductionResult? result;

  @override
  ConsumerState<VideoIntroductionTeleprompterPage> createState() =>
      _VideoIntroductionTeleprompterPageState();
}

class _VideoIntroductionTeleprompterPageState
    extends ConsumerState<VideoIntroductionTeleprompterPage> {
  final _scrollController = ScrollController();
  Timer? _scrollTimer;
  String? _initializedScript;

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _ensureInitialized(VideoIntroductionResult? result) {
    if (result == null || _initializedScript == result.script) {
      return;
    }

    _initializedScript = result.script;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      ref.read(teleprompterControllerProvider.notifier).initialize(result);
    });
  }

  void _syncAutoScroll(TeleprompterState state) {
    _scrollTimer?.cancel();
    if (!state.isAutoScrolling) {
      return;
    }

    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }

      final position = _scrollController.position;
      final nextOffset = _scrollController.offset + (state.scrollSpeed / 60);
      if (nextOffset >= position.maxScrollExtent) {
        _scrollController.jumpTo(position.maxScrollExtent);
        ref.read(teleprompterControllerProvider.notifier).toggleAutoScroll();
        return;
      }

      _scrollController.jumpTo(nextOffset);
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    _ensureInitialized(result);

    ref.listen<TeleprompterState>(teleprompterControllerProvider, (
      previous,
      next,
    ) {
      if (previous?.isAutoScrolling != next.isAutoScrolling ||
          previous?.scrollSpeed != next.scrollSpeed) {
        _syncAutoScroll(next);
      }

      if (next.recordingPath != null &&
          next.recordingPath != previous?.recordingPath) {
        AppFeedback.showSuccess(
          context,
          'Recording saved locally. You can review it from the Files app or your simulator container.',
        );
        ref
            .read(teleprompterControllerProvider.notifier)
            .clearTransientMessages();
      } else if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        AppFeedback.showError(context, next.errorMessage!);
        ref
            .read(teleprompterControllerProvider.notifier)
            .clearTransientMessages();
      }
    });

    final state = ref.watch(teleprompterControllerProvider);
    final recordingService = ref.watch(videoRecordingServiceProvider);
    final theme = Theme.of(context);

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Teleprompter')),
        body: const Center(
          child: ErrorView(
            message:
                'Generate a video introduction script before opening teleprompter mode.',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Teleprompter & Recording')),
      body: SafeArea(
        child: state.isInitializing
            ? const Center(
                child: LoadingView(
                  label: 'Preparing camera and teleprompter...',
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(AppSpacing.page),
                child: Column(
                  children: [
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          recordingService.buildPreview(),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withValues(alpha: 0.55),
                                  Colors.black.withValues(alpha: 0.22),
                                  Colors.black.withValues(alpha: 0.65),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.42,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        result.duration,
                                        style: theme.textTheme.labelLarge
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                    const Spacer(),
                                    if (state.isRecording)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withValues(
                                            alpha: 0.85,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: Text(
                                          'Recording',
                                          style: theme.textTheme.labelLarge
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ),
                                  ],
                                ),
                                if (state.cameraMessage != null) ...[
                                  const SizedBox(height: AppSpacing.section),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.42,
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Text(
                                      state.cameraMessage!,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: Colors.white,
                                            height: 1.4,
                                          ),
                                    ),
                                  ),
                                ],
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.42),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.14,
                                      ),
                                    ),
                                  ),
                                  child: SizedBox(
                                    height: 240,
                                    child: SingleChildScrollView(
                                      controller: _scrollController,
                                      child: Transform(
                                        alignment: Alignment.center,
                                        transform: Matrix4.diagonal3Values(
                                          state.isMirrored ? -1.0 : 1.0,
                                          1.0,
                                          1.0,
                                        ),
                                        child: Text(
                                          result.script,
                                          style: theme.textTheme.headlineSmall
                                              ?.copyWith(
                                                color: Colors.white,
                                                height: 1.45,
                                                fontSize: state.fontSize,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.page),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: AppSpacing.compact,
                              runSpacing: AppSpacing.compact,
                              children: [
                                AppButton(
                                  label: state.isAutoScrolling
                                      ? 'Pause scroll'
                                      : 'Auto scroll',
                                  expanded: false,
                                  variant: AppButtonVariant.secondary,
                                  icon: Icon(
                                    state.isAutoScrolling
                                        ? Icons.pause_circle_outline
                                        : Icons.play_circle_outline,
                                  ),
                                  onPressed: () => ref
                                      .read(
                                        teleprompterControllerProvider.notifier,
                                      )
                                      .toggleAutoScroll(),
                                ),
                                AppButton(
                                  label: state.isMirrored
                                      ? 'Mirror on'
                                      : 'Mirror off',
                                  expanded: false,
                                  variant: AppButtonVariant.secondary,
                                  icon: const Icon(Icons.flip),
                                  onPressed: () => ref
                                      .read(
                                        teleprompterControllerProvider.notifier,
                                      )
                                      .toggleMirrorMode(),
                                ),
                                AppButton(
                                  label: 'Switch camera',
                                  expanded: false,
                                  variant: AppButtonVariant.secondary,
                                  icon: const Icon(Icons.cameraswitch_outlined),
                                  onPressed: state.canSwitchCamera
                                      ? () => ref
                                            .read(
                                              teleprompterControllerProvider
                                                  .notifier,
                                            )
                                            .switchCamera()
                                      : null,
                                ),
                                AppButton(
                                  label: state.isRecording
                                      ? 'Stop recording'
                                      : 'Start recording',
                                  expanded: false,
                                  icon: Icon(
                                    state.isRecording
                                        ? Icons.stop_circle_outlined
                                        : Icons.fiber_manual_record,
                                  ),
                                  onPressed: () => state.isRecording
                                      ? ref
                                            .read(
                                              teleprompterControllerProvider
                                                  .notifier,
                                            )
                                            .stopRecording()
                                      : ref
                                            .read(
                                              teleprompterControllerProvider
                                                  .notifier,
                                            )
                                            .startRecording(),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.page),
                            Text(
                              'Scroll speed',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Slider(
                              value: state.scrollSpeed,
                              min: 12,
                              max: 80,
                              divisions: 17,
                              label: '${state.scrollSpeed.round()}',
                              onChanged: (value) => ref
                                  .read(teleprompterControllerProvider.notifier)
                                  .updateScrollSpeed(value),
                            ),
                            Text(
                              'Font size',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Slider(
                              value: state.fontSize,
                              min: 18,
                              max: 40,
                              divisions: 11,
                              label: '${state.fontSize.round()}',
                              onChanged: (value) => ref
                                  .read(teleprompterControllerProvider.notifier)
                                  .updateFontSize(value),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
