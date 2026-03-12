class ResumeResult {
  const ResumeResult({
    required this.summary,
    required this.experienceBullets,
    required this.skills,
    required this.education,
    this.createdAt,
  });

  final String summary;
  final List<String> experienceBullets;
  final List<String> skills;
  final String education;
  final DateTime? createdAt;

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
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'summary': summary,
      'experience_bullets': experienceBullets,
      'skills': skills,
      'education': education,
    };

    if (createdAt != null) {
      json['created_at'] = createdAt!.toIso8601String();
    }

    return json;
  }
}
