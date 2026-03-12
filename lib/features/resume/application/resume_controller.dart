import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../services/ai/ai_service_impl.dart';
import '../../../services/supabase/database_service.dart';
import '../data/datasources/resume_remote_datasource.dart';
import '../data/datasources/resume_supabase_datasource.dart';
import '../data/repositories/resume_repository_impl.dart';
import '../domain/entities/resume_request.dart';
import '../domain/repositories/resume_repository.dart';
import 'resume_state.dart';

final resumePersistenceDatasourceProvider = Provider<ResumeSupabaseDatasource>(
  (ref) => ResumeSupabaseDatasource(ref.watch(databaseServiceProvider)),
);

final resumeRemoteDatasourceProvider = Provider<ResumeRemoteDatasource>(
  (ref) => ResumeRemoteDatasource(ref.watch(aiServiceProvider)),
);

final resumeRepositoryProvider = Provider<ResumeRepository>(
  (ref) => ResumeRepositoryImpl(
    remoteDatasource: ref.watch(resumeRemoteDatasourceProvider),
    persistenceDatasource: ref.watch(resumePersistenceDatasourceProvider),
  ),
);

final resumeBuilderControllerProvider =
    NotifierProvider<ResumeController, ResumeState>(ResumeController.new);

class ResumeController extends Notifier<ResumeState> {
  @override
  ResumeState build() => const ResumeState();

  Future<void> startGeneration(ResumeRequest request) async {
    state = state.copyWith(
      request: request,
      isGenerating: true,
      isSaving: false,
      hasSaved: false,
      clearResponse: true,
      clearError: true,
    );

    try {
      final result = await ref
          .read(resumeRepositoryProvider)
          .generateResume(request);

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
        clearResponse: true,
      );
    } catch (_) {
      state = state.copyWith(
        isGenerating: false,
        errorMessage: 'We could not generate the resume right now. Try again.',
        clearResponse: true,
      );
    }
  }

  Future<void> saveCurrentResume() async {
    final result = state.result;

    if (result == null) {
      throw const AppException('Generate a resume before saving it.');
    }

    if (state.isSaving) {
      return;
    }

    state = state.copyWith(isSaving: true);

    try {
      await ref.read(resumeRepositoryProvider).saveResume(result);
      state = state.copyWith(isSaving: false, hasSaved: true);
    } catch (_) {
      state = state.copyWith(isSaving: false);
      rethrow;
    }
  }
}
