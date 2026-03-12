import '../../domain/entities/interview_question.dart';

class InterviewQuestionModel extends InterviewQuestion {
  const InterviewQuestionModel({
    required super.question,
    required super.sampleAnswer,
  });

  factory InterviewQuestionModel.fromJson(Map<String, dynamic> json) {
    return InterviewQuestionModel(
      question: json['question'] as String? ?? '',
      sampleAnswer: json['sample_answer'] as String? ?? '',
    );
  }
}
