import '../../domain/entities/resume_result.dart';

class ResumeResultModel extends ResumeResult {
  const ResumeResultModel({
    required super.summary,
    required super.experienceBullets,
    required super.skills,
    required super.education,
  });

  factory ResumeResultModel.fromJson(Map<String, dynamic> json) {
    return ResumeResultModel(
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

  @override
  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'experience_bullets': experienceBullets,
      'skills': skills,
      'education': education,
    };
  }
}
