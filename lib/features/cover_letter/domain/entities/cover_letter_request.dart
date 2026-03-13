import 'cover_letter_candidate_context.dart';
import 'cover_letter_clarifying_context.dart';
import 'cover_letter_fit_analysis.dart';
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
    this.fitAnalysis,
  });

  final String companyName;
  final String roleTitle;
  final String jobDescription;
  final String userBackground;
  final String tone;
  final CoverLetterCandidateContext? candidateContext;
  final CoverLetterJobContext? jobContext;
  final CoverLetterClarifyingContext? clarifyingContext;
  final CoverLetterFitAnalysis? fitAnalysis;

  CoverLetterRequest copyWith({
    String? companyName,
    String? roleTitle,
    String? jobDescription,
    String? userBackground,
    String? tone,
    CoverLetterCandidateContext? candidateContext,
    CoverLetterJobContext? jobContext,
    CoverLetterClarifyingContext? clarifyingContext,
    CoverLetterFitAnalysis? fitAnalysis,
  }) {
    return CoverLetterRequest(
      companyName: companyName ?? this.companyName,
      roleTitle: roleTitle ?? this.roleTitle,
      jobDescription: jobDescription ?? this.jobDescription,
      userBackground: userBackground ?? this.userBackground,
      tone: tone ?? this.tone,
      candidateContext: candidateContext ?? this.candidateContext,
      jobContext: jobContext ?? this.jobContext,
      clarifyingContext: clarifyingContext ?? this.clarifyingContext,
      fitAnalysis: fitAnalysis ?? this.fitAnalysis,
    );
  }
}
