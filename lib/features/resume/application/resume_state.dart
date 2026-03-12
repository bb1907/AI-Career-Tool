import '../domain/entities/resume_request.dart';
import '../domain/entities/resume_result.dart';

class ResumeState {
  const ResumeState({
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

  ResumeState copyWith({
    ResumeRequest? request,
    ResumeResult? result,
    bool? isGenerating,
    bool? isSaving,
    bool? hasSaved,
    String? errorMessage,
    bool clearResponse = false,
    bool clearError = false,
  }) {
    return ResumeState(
      request: request ?? this.request,
      result: clearResponse ? null : result ?? this.result,
      isGenerating: isGenerating ?? this.isGenerating,
      isSaving: isSaving ?? this.isSaving,
      hasSaved: hasSaved ?? this.hasSaved,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
