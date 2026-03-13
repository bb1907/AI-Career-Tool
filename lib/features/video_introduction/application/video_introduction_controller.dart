import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../services/ai/ai_service_impl.dart';
import '../../../services/analytics/analytics_events.dart';
import '../../../services/analytics/analytics_service.dart';
import '../../../services/subscription/premium_access_feature.dart';
import '../../paywall/application/premium_access_controller.dart';
import '../data/datasources/video_introduction_remote_datasource.dart';
import '../data/repositories/video_introduction_repository_impl.dart';
import '../domain/entities/video_introduction_request.dart';
import '../domain/repositories/video_introduction_repository.dart';
import 'video_introduction_state.dart';

final videoIntroductionRemoteDatasourceProvider =
    Provider<VideoIntroductionRemoteDatasource>(
      (ref) => VideoIntroductionRemoteDatasource(ref.watch(aiServiceProvider)),
    );

final videoIntroductionRepositoryProvider =
    Provider<VideoIntroductionRepository>(
      (ref) => VideoIntroductionRepositoryImpl(
        remoteDatasource: ref.watch(videoIntroductionRemoteDatasourceProvider),
      ),
    );

final videoIntroductionControllerProvider =
    NotifierProvider<VideoIntroductionController, VideoIntroductionState>(
      VideoIntroductionController.new,
    );

class VideoIntroductionController extends Notifier<VideoIntroductionState> {
  @override
  VideoIntroductionState build() => const VideoIntroductionState();

  Future<void> startGeneration(VideoIntroductionRequest request) async {
    if (state.isGenerating) {
      return;
    }

    state = state.copyWith(
      request: request,
      isGenerating: true,
      clearResult: true,
      clearError: true,
    );

    unawaited(
      ref
          .read(analyticsServiceProvider)
          .logEvent(
            AnalyticsEvents.videoIntroductionGenerationStarted,
            parameters: {
              'duration': request.duration.label,
              'has_company': request.targetCompany.trim().isNotEmpty,
              'key_points_count': request.keyPoints.length,
              'uses_candidate_profile': request.candidateContext != null,
            },
          ),
    );

    try {
      final result = await ref
          .read(videoIntroductionRepositoryProvider)
          .generateScript(request);
      await ref
          .read(premiumAccessControllerProvider.notifier)
          .recordSuccessfulUse(PremiumAccessFeature.videoIntroductionGenerate);
      unawaited(
        ref
            .read(analyticsServiceProvider)
            .logEvent(
              AnalyticsEvents.videoIntroductionGenerationCompleted,
              parameters: {
                'duration': result.duration,
                'script_length': result.script.length,
              },
            ),
      );

      state = state.copyWith(
        request: request,
        result: result,
        isGenerating: false,
        clearError: true,
      );
    } on AppException catch (error) {
      await _releasePendingUsage();
      state = state.copyWith(
        isGenerating: false,
        errorMessage: error.message,
        clearResult: true,
      );
    } catch (_) {
      await _releasePendingUsage();
      state = state.copyWith(
        isGenerating: false,
        errorMessage:
            'We couldn\'t generate your video introduction right now. Please try again.',
        clearResult: true,
      );
    }
  }

  Future<void> _releasePendingUsage() {
    return ref
        .read(premiumAccessControllerProvider.notifier)
        .releasePendingUse(PremiumAccessFeature.videoIntroductionGenerate);
  }
}
