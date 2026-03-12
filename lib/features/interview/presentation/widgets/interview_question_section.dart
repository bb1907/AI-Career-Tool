import 'package:flutter/material.dart';

import '../../../../core/utils/app_spacing.dart';
import '../../domain/entities/interview_question.dart';
import 'interview_question_card.dart';

class InterviewQuestionSection extends StatelessWidget {
  const InterviewQuestionSection({
    super.key,
    required this.title,
    required this.questions,
  });

  final String title;
  final List<InterviewQuestion> questions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.compact),
        for (var index = 0; index < questions.length; index++) ...[
          InterviewQuestionCard(question: questions[index]),
          if (index != questions.length - 1)
            const SizedBox(height: AppSpacing.section),
        ],
      ],
    );
  }
}
