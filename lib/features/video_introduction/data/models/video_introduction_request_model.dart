import '../../domain/entities/video_introduction_candidate_context.dart';
import '../../domain/entities/video_introduction_request.dart';

class VideoIntroductionRequestModel {
  const VideoIntroductionRequestModel({
    required this.duration,
    required this.targetRole,
    required this.targetCompany,
    required this.audience,
    required this.tone,
    required this.keyPoints,
    this.candidateContext,
  });

  final String duration;
  final String targetRole;
  final String targetCompany;
  final String audience;
  final String tone;
  final List<String> keyPoints;
  final VideoIntroductionCandidateContext? candidateContext;

  factory VideoIntroductionRequestModel.fromEntity(
    VideoIntroductionRequest request,
  ) {
    return VideoIntroductionRequestModel(
      duration: request.duration.label,
      targetRole: request.targetRole,
      targetCompany: request.targetCompany,
      audience: request.audience,
      tone: request.tone,
      keyPoints: request.keyPoints,
      candidateContext: request.candidateContext,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'duration': duration,
      'target_role': targetRole,
      'target_company': targetCompany,
      'audience': audience,
      'tone': tone,
      'key_points': keyPoints,
      if (candidateContext != null)
        'candidate_profile': {
          'name': candidateContext!.name,
          'location': candidateContext!.location,
          'years_experience': candidateContext!.yearsExperience,
          'roles': candidateContext!.roles,
          'skills': candidateContext!.skills,
          'industries': candidateContext!.industries,
          'seniority': candidateContext!.seniority,
          'education': candidateContext!.education,
        },
    };
  }
}
