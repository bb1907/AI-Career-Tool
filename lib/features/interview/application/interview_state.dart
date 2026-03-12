import '../domain/entities/interview_request.dart';
import '../domain/entities/interview_result.dart';

class InterviewState {
  const InterviewState({
    this.request,
    this.result,
    this.isGenerating = false,
    this.isSaving = false,
    this.hasSaved = false,
    this.errorMessage,
  });

  final InterviewRequest? request;
  final InterviewResult? result;
  final bool isGenerating;
  final bool isSaving;
  final bool hasSaved;
  final String? errorMessage;

  InterviewState copyWith({
    InterviewRequest? request,
    InterviewResult? result,
    bool? isGenerating,
    bool? isSaving,
    bool? hasSaved,
    String? errorMessage,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return InterviewState(
      request: request ?? this.request,
      result: clearResult ? null : result ?? this.result,
      isGenerating: isGenerating ?? this.isGenerating,
      isSaving: isSaving ?? this.isSaving,
      hasSaved: hasSaved ?? this.hasSaved,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
