import '../domain/entities/cover_letter_request.dart';
import '../domain/entities/cover_letter_result.dart';

class CoverLetterState {
  const CoverLetterState({
    this.request,
    this.result,
    this.isGenerating = false,
    this.isSaving = false,
    this.hasSaved = false,
    this.errorMessage,
  });

  final CoverLetterRequest? request;
  final CoverLetterResult? result;
  final bool isGenerating;
  final bool isSaving;
  final bool hasSaved;
  final String? errorMessage;

  CoverLetterState copyWith({
    CoverLetterRequest? request,
    CoverLetterResult? result,
    bool? isGenerating,
    bool? isSaving,
    bool? hasSaved,
    String? errorMessage,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return CoverLetterState(
      request: request ?? this.request,
      result: clearResult ? null : result ?? this.result,
      isGenerating: isGenerating ?? this.isGenerating,
      isSaving: isSaving ?? this.isSaving,
      hasSaved: hasSaved ?? this.hasSaved,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
