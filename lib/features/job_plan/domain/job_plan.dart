class JobPlan {
  final String id;
  final String jobDescription;
  final String role;
  final String company;
  final int matchScore;
  final List<String> matchingSkills;
  final List<String> missingSkills;
  final String sector;
  final String photoRecommendation;
  final DateTime createdAt;

  // Checklist
  final bool resumeTailored;
  final bool coverLetterWritten;
  final bool photoUpdated;
  final bool interviewPrepped;
  final bool networkingMessageSent;

  const JobPlan({
    required this.id,
    required this.jobDescription,
    required this.role,
    required this.company,
    required this.matchScore,
    required this.matchingSkills,
    required this.missingSkills,
    required this.sector,
    required this.photoRecommendation,
    required this.createdAt,
    this.resumeTailored = false,
    this.coverLetterWritten = false,
    this.photoUpdated = false,
    this.interviewPrepped = false,
    this.networkingMessageSent = false,
  });

  int get completedCount => [
    resumeTailored,
    coverLetterWritten,
    photoUpdated,
    interviewPrepped,
    networkingMessageSent,
  ].where((b) => b).length;

  JobPlan copyWith({
    String? id,
    String? jobDescription,
    String? role,
    String? company,
    int? matchScore,
    List<String>? matchingSkills,
    List<String>? missingSkills,
    String? sector,
    String? photoRecommendation,
    DateTime? createdAt,
    bool? resumeTailored,
    bool? coverLetterWritten,
    bool? photoUpdated,
    bool? interviewPrepped,
    bool? networkingMessageSent,
  }) => JobPlan(
    id: id ?? this.id,
    jobDescription: jobDescription ?? this.jobDescription,
    role: role ?? this.role,
    company: company ?? this.company,
    matchScore: matchScore ?? this.matchScore,
    matchingSkills: matchingSkills ?? this.matchingSkills,
    missingSkills: missingSkills ?? this.missingSkills,
    sector: sector ?? this.sector,
    photoRecommendation: photoRecommendation ?? this.photoRecommendation,
    createdAt: createdAt ?? this.createdAt,
    resumeTailored: resumeTailored ?? this.resumeTailored,
    coverLetterWritten: coverLetterWritten ?? this.coverLetterWritten,
    photoUpdated: photoUpdated ?? this.photoUpdated,
    interviewPrepped: interviewPrepped ?? this.interviewPrepped,
    networkingMessageSent: networkingMessageSent ?? this.networkingMessageSent,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'jobDescription': jobDescription,
    'role': role,
    'company': company,
    'matchScore': matchScore,
    'matchingSkills': matchingSkills,
    'missingSkills': missingSkills,
    'sector': sector,
    'photoRecommendation': photoRecommendation,
    'createdAt': createdAt.toIso8601String(),
    'resumeTailored': resumeTailored,
    'coverLetterWritten': coverLetterWritten,
    'photoUpdated': photoUpdated,
    'interviewPrepped': interviewPrepped,
    'networkingMessageSent': networkingMessageSent,
  };

  factory JobPlan.fromJson(Map<String, dynamic> json) => JobPlan(
    id: json['id'] as String,
    jobDescription: json['jobDescription'] as String,
    role: json['role'] as String,
    company: json['company'] as String,
    matchScore: (json['matchScore'] as num).toInt(),
    matchingSkills: (json['matchingSkills'] as List<dynamic>).cast<String>(),
    missingSkills: (json['missingSkills'] as List<dynamic>).cast<String>(),
    sector: json['sector'] as String,
    photoRecommendation: json['photoRecommendation'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    resumeTailored: json['resumeTailored'] as bool? ?? false,
    coverLetterWritten: json['coverLetterWritten'] as bool? ?? false,
    photoUpdated: json['photoUpdated'] as bool? ?? false,
    interviewPrepped: json['interviewPrepped'] as bool? ?? false,
    networkingMessageSent: json['networkingMessageSent'] as bool? ?? false,
  );
}
