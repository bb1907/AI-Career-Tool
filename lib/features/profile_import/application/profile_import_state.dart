import '../domain/entities/cv_upload_file.dart';

class ProfileImportState {
  static const _sentinel = Object();

  const ProfileImportState({
    this.selectedFile,
    this.isImporting = false,
    this.processingLabel,
    this.errorMessage,
  });

  final CvUploadFile? selectedFile;
  final bool isImporting;
  final String? processingLabel;
  final String? errorMessage;

  ProfileImportState copyWith({
    CvUploadFile? selectedFile,
    bool? isImporting,
    Object? processingLabel = _sentinel,
    Object? errorMessage = _sentinel,
    bool clearError = false,
    bool clearFile = false,
  }) {
    return ProfileImportState(
      selectedFile: clearFile ? null : selectedFile ?? this.selectedFile,
      isImporting: isImporting ?? this.isImporting,
      processingLabel: identical(processingLabel, _sentinel)
          ? this.processingLabel
          : processingLabel as String?,
      errorMessage: clearError
          ? null
          : identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
