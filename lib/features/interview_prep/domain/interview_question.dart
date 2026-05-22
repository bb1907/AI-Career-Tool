enum QuestionCategory { technical, behavioral }

class InterviewQuestion {
  final QuestionCategory category;
  final String question;
  final String sampleAnswer;

  const InterviewQuestion({
    required this.category,
    required this.question,
    required this.sampleAnswer,
  });

  Map<String, dynamic> toMap() => {
    'category': category.name,
    'question': question,
    'sampleAnswer': sampleAnswer,
  };

  factory InterviewQuestion.fromMap(Map<String, dynamic> map) {
    final rawCategory = (map['category'] as String? ?? 'technical')
        .toLowerCase();
    final category = rawCategory.contains('behav')
        ? QuestionCategory.behavioral
        : QuestionCategory.technical;
    return InterviewQuestion(
      category: category,
      question: map['question'] as String? ?? '',
      sampleAnswer:
          map['sampleAnswer'] as String? ??
          map['sample_answer'] as String? ??
          '',
    );
  }
}
