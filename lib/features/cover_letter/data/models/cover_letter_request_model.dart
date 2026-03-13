import '../../domain/entities/cover_letter_request.dart';
import '../../domain/entities/cover_letter_candidate_context.dart';
import '../../domain/entities/cover_letter_clarifying_context.dart';
import '../../domain/entities/cover_letter_job_context.dart';

class CoverLetterRequestModel {
  const CoverLetterRequestModel({
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

  factory CoverLetterRequestModel.fromEntity(CoverLetterRequest request) {
    return CoverLetterRequestModel(
      companyName: request.companyName,
      roleTitle: request.roleTitle,
      jobDescription: request.jobDescription,
      userBackground: request.userBackground,
      tone: request.tone,
      candidateContext: request.candidateContext,
      jobContext: request.jobContext,
      clarifyingContext: request.clarifyingContext,
    );
  }

  CoverLetterRequest toEntity() {
    return CoverLetterRequest(
      companyName: companyName,
      roleTitle: roleTitle,
      jobDescription: jobDescription,
      userBackground: userBackground,
      tone: tone,
      candidateContext: candidateContext,
      jobContext: jobContext,
      clarifyingContext: clarifyingContext,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company_name': companyName,
      'role_title': roleTitle,
      'job_description': jobDescription,
      'user_background': userBackground,
      'tone': tone,
      if (candidateContext != null)
        'candidate_profile': {
          'name': candidateContext!.name,
          'email': candidateContext!.email,
          'location': candidateContext!.location,
          'years_experience': candidateContext!.yearsExperience,
          'roles': candidateContext!.roles,
          'skills': candidateContext!.skills,
          'industries': candidateContext!.industries,
          'seniority': candidateContext!.seniority,
          'education': candidateContext!.education,
        },
      if (jobContext != null)
        'selected_job': {
          'job_id': jobContext!.jobId,
          'title': jobContext!.title,
          'company': jobContext!.company,
          'location': jobContext!.location,
          'source': jobContext!.source,
          'url': jobContext!.url,
          'job_description': jobContext!.jobDescription,
        },
      if (clarifyingContext != null && clarifyingContext!.hasContent)
        'clarifying_context': {
          'why_this_company': clarifyingContext!.whyThisCompany,
          'key_achievement': clarifyingContext!.keyAchievement,
          'emphasis_notes': clarifyingContext!.emphasisNotes,
        },
    };
  }
}
