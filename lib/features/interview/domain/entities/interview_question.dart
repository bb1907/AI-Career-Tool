class InterviewQuestion {
  const InterviewQuestion({required this.question, required this.sampleAnswer});

  final String question;
  final String sampleAnswer;

  factory InterviewQuestion.fromJson(Map<String, dynamic> json) {
    return InterviewQuestion(
      question: json['question'] as String? ?? '',
      sampleAnswer: json['sample_answer'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'question': question, 'sample_answer': sampleAnswer};
  }
}
