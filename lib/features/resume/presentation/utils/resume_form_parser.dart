import '../../domain/entities/resume_request.dart';

abstract final class ResumeFormParser {
  static ResumeRequest buildRequest({
    required String targetRole,
    required String yearsOfExperience,
    required String pastRoles,
    required String topSkills,
    required String achievements,
    required String education,
    required String preferredTone,
  }) {
    return ResumeRequest(
      targetRole: targetRole.trim(),
      yearsOfExperience: int.parse(yearsOfExperience.trim()),
      pastRoles: parseEntries(pastRoles),
      topSkills: parseEntries(topSkills),
      achievements: parseEntries(achievements),
      education: education.trim(),
      preferredTone: preferredTone.trim(),
    );
  }

  static List<String> parseEntries(String rawValue) {
    return rawValue
        .split(RegExp(r'[\n,]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }
}
