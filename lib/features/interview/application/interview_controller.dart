import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../services/ai/ai_service_impl.dart';
import '../../../services/subscription/premium_access_feature.dart';
import '../../../services/supabase/database_service.dart';
import '../../paywall/application/premium_access_controller.dart';
import '../data/datasources/interview_remote_datasource.dart';
import '../data/datasources/interview_supabase_datasource.dart';
import '../data/repositories/interview_repository_impl.dart';
import '../domain/entities/interview_request.dart';
import '../domain/repositories/interview_repository.dart';
import 'interview_state.dart';

final interviewPersistenceDatasourceProvider =
    Provider<InterviewSupabaseDatasource>(
      (ref) => InterviewSupabaseDatasource(ref.watch(databaseServiceProvider)),
    );

final interviewRemoteDatasourceProvider = Provider<InterviewRemoteDatasource>(
  (ref) => InterviewRemoteDatasource(ref.watch(aiServiceProvider)),
);

final interviewRepositoryProvider = Provider<InterviewRepository>(
  (ref) => InterviewRepositoryImpl(
    remoteDatasource: ref.watch(interviewRemoteDatasourceProvider),
    persistenceDatasource: ref.watch(interviewPersistenceDatasourceProvider),
  ),
);

final interviewControllerProvider =
    NotifierProvider<InterviewController, InterviewState>(
      InterviewController.new,
    );

class InterviewController extends Notifier<InterviewState> {
  @override
  InterviewState build() => const InterviewState();

  Future<void> startGeneration(InterviewRequest request) async {
    state = state.copyWith(
      request: request,
      isGenerating: true,
      isSaving: false,
      hasSaved: false,
      clearResult: true,
      clearError: true,
    );

    try {
      final result = await ref
          .read(interviewRepositoryProvider)
          .generateInterviewPrep(request);
      await ref
          .read(premiumAccessControllerProvider.notifier)
          .recordSuccessfulUse(PremiumAccessFeature.interviewGenerate);

      state = state.copyWith(
        request: request,
        result: result,
        isGenerating: false,
        hasSaved: false,
        clearError: true,
      );
    } on AppException catch (error) {
      state = state.copyWith(
        isGenerating: false,
        errorMessage: error.message,
        clearResult: true,
      );
    } catch (_) {
      state = state.copyWith(
        isGenerating: false,
        errorMessage:
            'We could not generate interview prep right now. Try again.',
        clearResult: true,
      );
    }
  }

  Future<void> saveCurrentInterviewPrep() async {
    final result = state.result;

    if (result == null) {
      throw const AppException('Generate interview prep before saving it.');
    }

    if (state.isSaving) {
      return;
    }

    state = state.copyWith(isSaving: true, hasSaved: false);

    try {
      await ref.read(interviewRepositoryProvider).saveInterviewPrep(result);
      state = state.copyWith(isSaving: false, hasSaved: true);
    } catch (_) {
      state = state.copyWith(isSaving: false);
      rethrow;
    }
  }
}
