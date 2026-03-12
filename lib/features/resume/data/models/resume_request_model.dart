import '../../domain/entities/resume_request.dart';

class ResumeRequestModel {
  const ResumeRequestModel({
    required this.targetRole,
    required this.yearsOfExperience,
    required this.pastRoles,
    required this.topSkills,
    required this.achievements,
    required this.education,
    required this.preferredTone,
  });

  final String targetRole;
  final int yearsOfExperience;
  final List<String> pastRoles;
  final List<String> topSkills;
  final List<String> achievements;
  final String education;
  final String preferredTone;

  factory ResumeRequestModel.fromEntity(ResumeRequest request) {
    return ResumeRequestModel(
      targetRole: request.targetRole,
      yearsOfExperience: request.yearsOfExperience,
      pastRoles: request.pastRoles,
      topSkills: request.topSkills,
      achievements: request.achievements,
      education: request.education,
      preferredTone: request.preferredTone,
    );
  }

  ResumeRequest toEntity() {
    return ResumeRequest(
      targetRole: targetRole,
      yearsOfExperience: yearsOfExperience,
      pastRoles: pastRoles,
      topSkills: topSkills,
      achievements: achievements,
      education: education,
      preferredTone: preferredTone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'target_role': targetRole,
      'years_of_experience': yearsOfExperience,
      'past_roles': pastRoles,
      'top_skills': topSkills,
      'achievements': achievements,
      'education': education,
      'preferred_tone': preferredTone,
    };
  }
}
