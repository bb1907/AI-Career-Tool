import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/repositories/mock_resume_repository.dart';
import '../../domain/entities/resume_request.dart';
import '../../domain/entities/resume_result.dart';
import '../../domain/repositories/resume_repository.dart';

final resumeRepositoryProvider = Provider<ResumeRepository>(
  (ref) => MockResumeRepository(),
);

final resumeBuilderControllerProvider =
    NotifierProvider<ResumeBuilderController, ResumeBuilderState>(
      ResumeBuilderController.new,
    );

class ResumeBuilderState {
  const ResumeBuilderState({
    this.request,
    this.result,
    this.isGenerating = false,
    this.isSaving = false,
    this.hasSaved = false,
    this.errorMessage,
  });

  final ResumeRequest? request;
  final ResumeResult? result;
  final bool isGenerating;
  final bool isSaving;
  final bool hasSaved;
  final String? errorMessage;

  ResumeBuilderState copyWith({
    ResumeRequest? request,
    ResumeResult? result,
    bool? isGenerating,
    bool? isSaving,
    bool? hasSaved,
    String? errorMessage,
    bool clearResponse = false,
    bool clearError = false,
  }) {
    return ResumeBuilderState(
      request: request ?? this.request,
      result: clearResponse ? null : result ?? this.result,
      isGenerating: isGenerating ?? this.isGenerating,
      isSaving: isSaving ?? this.isSaving,
      hasSaved: hasSaved ?? this.hasSaved,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class ResumeBuilderController extends Notifier<ResumeBuilderState> {
  @override
  ResumeBuilderState build() => const ResumeBuilderState();

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
      final response = await ref
          .read(resumeRepositoryProvider)
          .generateResume(request);

      state = state.copyWith(
        request: request,
        result: response,
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
