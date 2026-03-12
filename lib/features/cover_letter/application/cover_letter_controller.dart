import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../services/ai/ai_service_impl.dart';
import '../data/datasources/cover_letter_local_datasource.dart';
import '../data/datasources/cover_letter_remote_datasource.dart';
import '../data/repositories/cover_letter_repository_impl.dart';
import '../domain/entities/cover_letter_request.dart';
import '../domain/repositories/cover_letter_repository.dart';
import 'cover_letter_state.dart';

final coverLetterLocalDatasourceProvider = Provider<CoverLetterLocalDatasource>(
  (ref) => CoverLetterLocalDatasource(),
);

final coverLetterRemoteDatasourceProvider =
    Provider<CoverLetterRemoteDatasource>(
      (ref) => CoverLetterRemoteDatasource(ref.watch(aiServiceProvider)),
    );

final coverLetterRepositoryProvider = Provider<CoverLetterRepository>(
  (ref) => CoverLetterRepositoryImpl(
    remoteDatasource: ref.watch(coverLetterRemoteDatasourceProvider),
    localDatasource: ref.watch(coverLetterLocalDatasourceProvider),
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
          .read(coverLetterRepositoryProvider)
          .generateCoverLetter(request);

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
            'We could not generate the cover letter right now. Try again.',
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
}
