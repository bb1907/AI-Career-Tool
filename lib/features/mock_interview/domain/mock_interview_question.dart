class MockInterviewQuestion {
  final String question;
  final String? userAnswer;
  final int? score;
  final List<String>? strengths;
  final List<String>? improvements;
  final String? improvedAnswer;

  const MockInterviewQuestion({
    required this.question,
    this.userAnswer,
    this.score,
    this.strengths,
    this.improvements,
    this.improvedAnswer,
  });

  MockInterviewQuestion copyWith({
    String? question,
    String? userAnswer,
    int? score,
    List<String>? strengths,
    List<String>? improvements,
    String? improvedAnswer,
  }) => MockInterviewQuestion(
    question: question ?? this.question,
    userAnswer: userAnswer ?? this.userAnswer,
    score: score ?? this.score,
    strengths: strengths ?? this.strengths,
    improvements: improvements ?? this.improvements,
    improvedAnswer: improvedAnswer ?? this.improvedAnswer,
  );

  Map<String, dynamic> toJson() => {
    'question': question,
    'userAnswer': userAnswer,
    'score': score,
    'strengths': strengths,
    'improvements': improvements,
    'improvedAnswer': improvedAnswer,
  };

  factory MockInterviewQuestion.fromJson(Map<String, dynamic> json) =>
      MockInterviewQuestion(
        question: json['question'] as String,
        userAnswer: json['userAnswer'] as String?,
        score: (json['score'] as num?)?.toInt(),
        strengths: (json['strengths'] as List<dynamic>?)?.cast<String>(),
        improvements: (json['improvements'] as List<dynamic>?)?.cast<String>(),
        improvedAnswer: json['improvedAnswer'] as String?,
      );
}
