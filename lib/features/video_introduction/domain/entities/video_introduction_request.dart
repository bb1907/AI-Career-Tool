import 'video_introduction_candidate_context.dart';
import 'video_introduction_duration.dart';

class VideoIntroductionRequest {
  const VideoIntroductionRequest({
    required this.duration,
    required this.targetRole,
    required this.targetCompany,
    required this.audience,
    required this.tone,
    required this.keyPoints,
    this.candidateContext,
  });

  final VideoIntroductionDuration duration;
  final String targetRole;
  final String targetCompany;
  final String audience;
  final String tone;
  final List<String> keyPoints;
  final VideoIntroductionCandidateContext? candidateContext;
}
