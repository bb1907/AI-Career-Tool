import 'interview_question.dart';

class InterviewResult {
  const InterviewResult({
    required this.technicalQuestions,
    required this.behavioralQuestions,
  });

  final List<InterviewQuestion> technicalQuestions;
  final List<InterviewQuestion> behavioralQuestions;

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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'technical_questions': technicalQuestions
          .map((question) => question.toJson())
          .toList(growable: false),
      'behavioral_questions': behavioralQuestions
          .map((question) => question.toJson())
          .toList(growable: false),
    };
  }
}
