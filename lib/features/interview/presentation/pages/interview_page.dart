import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/widgets/app_placeholder_scaffold.dart';

class InterviewPage extends StatelessWidget {
  const InterviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPlaceholderScaffold(
      eyebrow: 'Feature',
      title: 'Interview Prep',
      description:
          'Practice interview questions, structure answers and keep prep notes close to the job you target.',
      actions: [
        SizedBox(
          width: 220,
          child: ElevatedButton(
            onPressed: () => context.go(AppRoutes.home),
            child: const Text('Back to Home'),
          ),
        ),
      ],
    );
  }
}
