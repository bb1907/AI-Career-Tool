import '../domain/entities/candidate_profile.dart';
import '../domain/entities/cv_upload_file.dart';

class ProfileImportState {
  static const _sentinel = Object();

  const ProfileImportState({
    this.selectedFile,
    this.profile,
    this.isImporting = false,
    this.processingLabel,
    this.errorMessage,
  });

  final CvUploadFile? selectedFile;
  final CandidateProfile? profile;
  final bool isImporting;
  final String? processingLabel;
  final String? errorMessage;

  bool get hasResult => profile != null;

  ProfileImportState copyWith({
    CvUploadFile? selectedFile,
    CandidateProfile? profile,
    bool? isImporting,
    Object? processingLabel = _sentinel,
    Object? errorMessage = _sentinel,
    bool clearProfile = false,
    bool clearError = false,
    bool clearFile = false,
  }) {
    return ProfileImportState(
      selectedFile: clearFile ? null : selectedFile ?? this.selectedFile,
      profile: clearProfile ? null : profile ?? this.profile,
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
