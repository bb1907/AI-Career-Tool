import 'interview_question.dart';

class InterviewResult {
  const InterviewResult({
    required this.technicalQuestions,
    required this.behavioralQuestions,
    this.createdAt,
  });

  final List<InterviewQuestion> technicalQuestions;
  final List<InterviewQuestion> behavioralQuestions;
  final DateTime? createdAt;

  factory InterviewResult.fromJson(Map<String, dynamic> json) {
    return InterviewResult(
      technicalQuestions: (json['technical_questions'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(InterviewQuestion.fromJson)
          .toList(growable: false),
      behavioralQuestions:
          (json['behavioral_questions'] as List<dynamic>? ?? [])
              .whereType<Map<String, dynamic>>()
              .map(InterviewQuestion.fromJson)
              .toList(growable: false),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'technical_questions': technicalQuestions
          .map((question) => question.toJson())
          .toList(growable: false),
      'behavioral_questions': behavioralQuestions
          .map((question) => question.toJson())
          .toList(growable: false),
    };

    if (createdAt != null) {
      json['created_at'] = createdAt!.toIso8601String();
    }

    return json;
  }
}
