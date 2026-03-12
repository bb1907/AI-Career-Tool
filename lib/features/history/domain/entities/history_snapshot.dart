import '../../../cover_letter/domain/entities/cover_letter_result.dart';
import '../../../interview/domain/entities/interview_result.dart';
import '../../../resume/domain/entities/resume_result.dart';

class HistorySnapshot {
  const HistorySnapshot({
    this.resumes = const [],
    this.coverLetters = const [],
    this.interviewSets = const [],
  });

  final List<ResumeResult> resumes;
  final List<CoverLetterResult> coverLetters;
  final List<InterviewResult> interviewSets;

  bool get isEmpty =>
      resumes.isEmpty && coverLetters.isEmpty && interviewSets.isEmpty;
}
