import '../../../cover_letter/domain/entities/cover_letter_result.dart';
import '../../../interview/domain/entities/interview_result.dart';
import '../../../resume/domain/entities/resume_result.dart';
import 'history_section.dart';

class HistorySnapshot {
  const HistorySnapshot({
    this.resumes = const HistorySection<ResumeResult>(),
    this.coverLetters = const HistorySection<CoverLetterResult>(),
    this.interviewSets = const HistorySection<InterviewResult>(),
  });

  final HistorySection<ResumeResult> resumes;
  final HistorySection<CoverLetterResult> coverLetters;
  final HistorySection<InterviewResult> interviewSets;

  bool get isEmpty =>
      resumes.isEmpty && coverLetters.isEmpty && interviewSets.isEmpty;

  bool get hasAnyError =>
      resumes.hasError || coverLetters.hasError || interviewSets.hasError;

  int get totalCount => resumes.count + coverLetters.count + interviewSets.count;
}
