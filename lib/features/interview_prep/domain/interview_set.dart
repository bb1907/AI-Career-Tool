import 'interview_question.dart';

class InterviewSet {
  final String id;
  final String roleName;
  final String seniority;
  final List<InterviewQuestion> questions;
  final DateTime createdAt;

  const InterviewSet({
    required this.id,
    required this.roleName,
    required this.seniority,
    required this.questions,
    required this.createdAt,
  });
}
