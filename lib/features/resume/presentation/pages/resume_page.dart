import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/widgets/app_placeholder_scaffold.dart';

class ResumePage extends StatelessWidget {
  const ResumePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPlaceholderScaffold(
      eyebrow: 'Feature',
      title: 'Resume Builder',
      description:
          'Create role-focused resumes, refine bullet points and organize multiple versions from one place.',
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
