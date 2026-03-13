import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../data/services/camera_video_recording_service.dart';
import '../data/services/video_recording_service.dart';
import '../domain/entities/video_introduction_result.dart';
import 'teleprompter_state.dart';

final videoRecordingServiceProvider = Provider<VideoRecordingService>(
  (ref) => CameraVideoRecordingService(),
);

final teleprompterControllerProvider =
    NotifierProvider.autoDispose<TeleprompterController, TeleprompterState>(
      TeleprompterController.new,
    );

class TeleprompterController extends Notifier<TeleprompterState> {
  VideoRecordingService get _recordingService =>
      ref.read(videoRecordingServiceProvider);

  @override
  TeleprompterState build() {
    final recordingService = ref.watch(videoRecordingServiceProvider);
    ref.onDispose(() {
      recordingService.dispose();
    });

    return const TeleprompterState();
  }

  Future<void> initialize(VideoIntroductionResult result) async {
    if (state.isReady && state.script == result.script) {
      return;
    }

    state = state.copyWith(
      script: result.script,
      durationLabel: result.duration,
      isInitializing: true,
      isReady: false,
      clearError: true,
      clearRecordingPath: true,
    );

    try {
      await _recordingService.initialize(preferFrontCamera: true);
      state = state.copyWith(
        isInitializing: false,
        isReady: true,
        hasPreview: _recordingService.hasPreview,
        canSwitchCamera: _recordingService.canSwitchCamera,
        isUsingFrontCamera: _recordingService.isUsingFrontCamera,
        cameraMessage: _recordingService.unavailableMessage,
        clearError: true,
      );
    } on AppException catch (error) {
      state = state.copyWith(
        isInitializing: false,
        isReady: true,
        hasPreview: false,
        cameraMessage:
            'Teleprompter mode is still available, but camera preview could not start.',
        errorMessage: error.message,
      );
    } catch (_) {
      state = state.copyWith(
        isInitializing: false,
        isReady: true,
        hasPreview: false,
        cameraMessage:
            'Teleprompter mode is still available, but camera preview could not start.',
        errorMessage:
            'Camera preview could not be started right now. You can still rehearse with the script.',
      );
    }
  }

  void toggleAutoScroll() {
    state = state.copyWith(isAutoScrolling: !state.isAutoScrolling);
  }

  void updateScrollSpeed(double value) {
    state = state.copyWith(scrollSpeed: value);
  }

  void updateFontSize(double value) {
    state = state.copyWith(fontSize: value);
  }

  void toggleMirrorMode() {
    state = state.copyWith(isMirrored: !state.isMirrored);
  }

  Future<void> switchCamera() async {
    if (!state.canSwitchCamera) {
      return;
    }

    try {
      await _recordingService.switchCamera();
      state = state.copyWith(
        isUsingFrontCamera: _recordingService.isUsingFrontCamera,
        hasPreview: _recordingService.hasPreview,
        clearError: true,
      );
    } on AppException catch (error) {
      state = state.copyWith(errorMessage: error.message);
    } catch (_) {
      state = state.copyWith(
        errorMessage: 'The camera could not be switched right now.',
      );
    }
  }

  Future<void> startRecording() async {
    try {
      await _recordingService.startRecording();
      state = state.copyWith(
        isRecording: true,
        clearError: true,
        clearRecordingPath: true,
      );
    } on AppException catch (error) {
      state = state.copyWith(errorMessage: error.message);
    } catch (_) {
      state = state.copyWith(
        errorMessage:
            'Recording could not be started right now. Please try again.',
      );
    }
  }

  Future<void> stopRecording() async {
    try {
      final path = await _recordingService.stopRecording();
      state = state.copyWith(
        isRecording: false,
        recordingPath: path,
        clearError: true,
      );
    } on AppException catch (error) {
      state = state.copyWith(errorMessage: error.message);
    } catch (_) {
      state = state.copyWith(
        errorMessage:
            'Recording could not be finished right now. Please try again.',
      );
    }
  }

  void clearTransientMessages() {
    state = state.copyWith(clearError: true, clearRecordingPath: true);
  }
}
