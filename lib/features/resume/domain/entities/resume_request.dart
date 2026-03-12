class ResumeRequest {
  const ResumeRequest({
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
