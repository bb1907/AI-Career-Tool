import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/widgets/app_placeholder_scaffold.dart';

class CoverLetterPage extends StatelessWidget {
  const CoverLetterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPlaceholderScaffold(
      eyebrow: 'Feature',
      title: 'Cover Letter Generator',
      description:
          'Draft tailored cover letters quickly and keep variations ready for each company you apply to.',
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
