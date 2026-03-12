import '../../domain/entities/interview_result.dart';
import 'interview_question_model.dart';

class InterviewResultModel extends InterviewResult {
  const InterviewResultModel({
    required super.technicalQuestions,
    required super.behavioralQuestions,
    super.createdAt,
  });

  factory InterviewResultModel.fromJson(Map<String, dynamic> json) {
    return InterviewResultModel(
      technicalQuestions: (json['technical_questions'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(InterviewQuestionModel.fromJson)
          .toList(growable: false),
      behavioralQuestions:
          (json['behavioral_questions'] as List<dynamic>? ?? [])
              .whereType<Map<String, dynamic>>()
              .map(InterviewQuestionModel.fromJson)
              .toList(growable: false),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }

  @override
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
