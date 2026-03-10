import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_placeholder_scaffold.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key, this.redirectTo});

  final String? redirectTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return AppPlaceholderScaffold(
      eyebrow: 'Public route',
      title: 'Login',
      description:
          'Authentication is intentionally simple here. The wiring is ready for a real backend or OAuth provider.',
      actions: [
        SizedBox(
          width: 220,
          child: ElevatedButton(
            onPressed: authState.isSubmitting
                ? null
                : () => ref.read(authControllerProvider.notifier).signIn(),
            child: authState.isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Continue to Home'),
          ),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Text(
              redirectTo == null || redirectTo == '/'
                  ? 'Use this placeholder login to continue into the protected area.'
                  : 'After login you will continue to $redirectTo.',
            ),
          ),
        ],
      ),
    );
  }
}
