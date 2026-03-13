import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../services/ai/ai_service_impl.dart';
import '../../../services/analytics/analytics_events.dart';
import '../../../services/analytics/analytics_service.dart';
import '../../../services/subscription/premium_access_feature.dart';
import '../../../services/supabase/database_service.dart';
import '../../paywall/application/premium_access_controller.dart';
import '../data/datasources/cover_letter_remote_datasource.dart';
import '../data/datasources/cover_letter_supabase_datasource.dart';
import '../data/repositories/cover_letter_repository_impl.dart';
import '../domain/entities/cover_letter_request.dart';
import '../domain/repositories/cover_letter_repository.dart';
import 'cover_letter_state.dart';

final coverLetterPersistenceDatasourceProvider =
    Provider<CoverLetterSupabaseDatasource>(
      (ref) =>
          CoverLetterSupabaseDatasource(ref.watch(databaseServiceProvider)),
    );

final coverLetterRemoteDatasourceProvider =
    Provider<CoverLetterRemoteDatasource>(
      (ref) => CoverLetterRemoteDatasource(ref.watch(aiServiceProvider)),
    );

final coverLetterRepositoryProvider = Provider<CoverLetterRepository>(
  (ref) => CoverLetterRepositoryImpl(
    remoteDatasource: ref.watch(coverLetterRemoteDatasourceProvider),
    persistenceDatasource: ref.watch(coverLetterPersistenceDatasourceProvider),
  ),
);

final coverLetterControllerProvider =
    NotifierProvider<CoverLetterController, CoverLetterState>(
      CoverLetterController.new,
    );

class CoverLetterController extends Notifier<CoverLetterState> {
  @override
  CoverLetterState build() => const CoverLetterState();

  Future<void> startGeneration(CoverLetterRequest request) async {
    if (state.isGenerating) {
      return;
    }

    state = state.copyWith(
      request: request,
      isGenerating: true,
      isSaving: false,
      hasSaved: false,
      clearResult: true,
      clearError: true,
    );
    unawaited(
      ref
          .read(analyticsServiceProvider)
          .logEvent(
            AnalyticsEvents.coverLetterGenerationStarted,
            parameters: {
              'tone': request.tone,
              'job_description_length': request.jobDescription.length,
              'background_length': request.userBackground.length,
              'role_present': request.roleTitle.trim().isNotEmpty,
            },
          ),
    );

    try {
      final result = await ref
          .read(coverLetterRepositoryProvider)
          .generateCoverLetter(request);
      await ref
          .read(premiumAccessControllerProvider.notifier)
          .recordSuccessfulUse(PremiumAccessFeature.coverLetterGenerate);
      unawaited(
        ref
            .read(analyticsServiceProvider)
            .logEvent(
              AnalyticsEvents.coverLetterGenerationCompleted,
              parameters: {
                'cover_letter_length': result.coverLetter.length,
                'has_content': result.coverLetter.trim().isNotEmpty,
              },
            ),
      );

      state = state.copyWith(
        request: request,
        result: result,
        isGenerating: false,
        hasSaved: false,
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
            'We couldn\'t generate your cover letter right now. Please try again.',
        clearResult: true,
      );
    }
  }

  Future<void> saveCurrentCoverLetter(String coverLetter) async {
    final result = state.result;

    if (result == null) {
      throw const AppException('Generate a cover letter before saving it.');
    }

    if (state.isSaving) {
      return;
    }

    final normalizedResult = result.copyWith(coverLetter: coverLetter.trim());
    state = state.copyWith(
      isSaving: true,
      result: normalizedResult,
      hasSaved: false,
    );

    try {
      await ref
          .read(coverLetterRepositoryProvider)
          .saveCoverLetter(normalizedResult);
      state = state.copyWith(isSaving: false, hasSaved: true);
    } catch (_) {
      state = state.copyWith(isSaving: false);
      rethrow;
    }
  }

  void updateDraft(String coverLetter) {
    final result = state.result;
    if (result == null) {
      return;
    }

    state = state.copyWith(
      result: result.copyWith(coverLetter: coverLetter),
      hasSaved: false,
    );
  }

  Future<void> _releasePendingUsage() {
    return ref
        .read(premiumAccessControllerProvider.notifier)
        .releasePendingUse(PremiumAccessFeature.coverLetterGenerate);
  }
}
