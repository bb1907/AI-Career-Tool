class ResumeResult {
  const ResumeResult({
    required this.summary,
    required this.experienceBullets,
    required this.skills,
    required this.education,
  });

  final String summary;
  final List<String> experienceBullets;
  final List<String> skills;
  final String education;

  factory ResumeResult.fromJson(Map<String, dynamic> json) {
    return ResumeResult(
      summary: json['summary'] as String? ?? '',
      experienceBullets: (json['experience_bullets'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(growable: false),
      skills: (json['skills'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(growable: false),
      education: json['education'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'experience_bullets': experienceBullets,
      'skills': skills,
      'education': education,
    };
  }
}
