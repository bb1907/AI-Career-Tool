import '../../domain/entities/resume_request.dart';
import '../../domain/entities/resume_result.dart';
import '../../domain/repositories/resume_repository.dart';

class MockResumeRepository implements ResumeRepository {
  final List<ResumeResult> _history = [];

  @override
  Future<ResumeResult> generateResume(ResumeRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 1400));

    final leadRoles = request.pastRoles.take(2).join(' and ');
    final highlightedSkills = request.topSkills.take(4).join(', ');
    final primaryAchievement = request.achievements.first;
    final normalizedTone = request.preferredTone.toLowerCase();

    return ResumeResult.fromJson({
      'summary':
          '${request.targetRole} with ${request.yearsOfExperience} years of experience across $leadRoles. Delivers ATS-friendly, $normalizedTone resume content by connecting $highlightedSkills to measurable outcomes such as $primaryAchievement.',
      'experience_bullets': [
        'Built role-specific impact stories for ${request.targetRole.toLowerCase()} applications by translating ${request.achievements.first} into concise, metric-aware bullets.',
        'Positioned ${request.topSkills.first} and ${request.topSkills[1 % request.topSkills.length]} as repeat strengths across ${request.pastRoles.first.toLowerCase()} and adjacent ownership areas.',
        'Reframed ${request.achievements.length > 1 ? request.achievements[1] : request.achievements.first} to emphasize scope, collaboration, and execution quality for ATS screening.',
        'Aligned professional narrative with ${request.targetRole.toLowerCase()} expectations using ${request.preferredTone.toLowerCase()} language, modern keywords, and clean resume structure.',
      ],
      'skills': request.topSkills.take(8).toList(growable: false),
      'education': request.education,
    });
  }

  @override
  Future<void> saveResume(ResumeResult result) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _history.insert(0, result);
  }

  @override
  Future<List<ResumeResult>> fetchHistory() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return List<ResumeResult>.unmodifiable(_history);
  }
}
