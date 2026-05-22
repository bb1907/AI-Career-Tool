import 'mock_interview_question.dart';

class MockInterviewSession {
  final String id;
  final String role;
  final String seniority;
  final List<MockInterviewQuestion> questions;
  final DateTime createdAt;

  const MockInterviewSession({
    required this.id,
    required this.role,
    required this.seniority,
    required this.questions,
    required this.createdAt,
  });

  MockInterviewSession copyWith({
    String? id,
    String? role,
    String? seniority,
    List<MockInterviewQuestion>? questions,
    DateTime? createdAt,
  }) => MockInterviewSession(
    id: id ?? this.id,
    role: role ?? this.role,
    seniority: seniority ?? this.seniority,
    questions: questions ?? this.questions,
    createdAt: createdAt ?? this.createdAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role,
    'seniority': seniority,
    'questions': questions.map((q) => q.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory MockInterviewSession.fromJson(Map<String, dynamic> json) =>
      MockInterviewSession(
        id: json['id'] as String,
        role: json['role'] as String,
        seniority: json['seniority'] as String,
        questions: (json['questions'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(MockInterviewQuestion.fromJson)
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
