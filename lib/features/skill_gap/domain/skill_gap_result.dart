class SkillGapResult {
  final String id;
  final String jobDescription;
  final int matchScore;
  final List<String> matchingSkills;
  final List<String> missingSkills;
  final List<String> recommendations;
  final String summary;
  final DateTime createdAt;

  const SkillGapResult({
    required this.id,
    required this.jobDescription,
    required this.matchScore,
    required this.matchingSkills,
    required this.missingSkills,
    required this.recommendations,
    required this.summary,
    required this.createdAt,
  });

  SkillGapResult copyWith({
    String? id,
    String? jobDescription,
    int? matchScore,
    List<String>? matchingSkills,
    List<String>? missingSkills,
    List<String>? recommendations,
    String? summary,
    DateTime? createdAt,
  }) => SkillGapResult(
    id: id ?? this.id,
    jobDescription: jobDescription ?? this.jobDescription,
    matchScore: matchScore ?? this.matchScore,
    matchingSkills: matchingSkills ?? this.matchingSkills,
    missingSkills: missingSkills ?? this.missingSkills,
    recommendations: recommendations ?? this.recommendations,
    summary: summary ?? this.summary,
    createdAt: createdAt ?? this.createdAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'jobDescription': jobDescription,
    'matchScore': matchScore,
    'matchingSkills': matchingSkills,
    'missingSkills': missingSkills,
    'recommendations': recommendations,
    'summary': summary,
    'createdAt': createdAt.toIso8601String(),
  };

  factory SkillGapResult.fromJson(Map<String, dynamic> json) => SkillGapResult(
    id: json['id'] as String,
    jobDescription: json['jobDescription'] as String,
    matchScore: (json['matchScore'] as num).toInt(),
    matchingSkills: (json['matchingSkills'] as List<dynamic>).cast<String>(),
    missingSkills: (json['missingSkills'] as List<dynamic>).cast<String>(),
    recommendations: (json['recommendations'] as List<dynamic>).cast<String>(),
    summary: json['summary'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
