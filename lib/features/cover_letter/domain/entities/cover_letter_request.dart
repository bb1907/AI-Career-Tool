import 'cover_letter_candidate_context.dart';
import 'cover_letter_clarifying_context.dart';
import 'cover_letter_job_context.dart';

class CoverLetterRequest {
  const CoverLetterRequest({
    required this.companyName,
    required this.roleTitle,
    required this.jobDescription,
    required this.userBackground,
    required this.tone,
    this.candidateContext,
    this.jobContext,
    this.clarifyingContext,
  });

  final String companyName;
  final String roleTitle;
  final String jobDescription;
  final String userBackground;
  final String tone;
  final CoverLetterCandidateContext? candidateContext;
  final CoverLetterJobContext? jobContext;
  final CoverLetterClarifyingContext? clarifyingContext;
}
