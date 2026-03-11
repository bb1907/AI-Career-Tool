import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/widgets/app_placeholder_scaffold.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final session = authState.session;

    return AppPlaceholderScaffold(
      eyebrow: 'Account',
      title: 'Profile & Settings',
      description:
          'Quick access to your account details and essential app actions.',
      actions: [
        SizedBox(
          width: 180,
          child: OutlinedButton(
            onPressed: () => context.go(AppRoutes.home),
            child: const Text('Back to Home'),
          ),
        ),
        SizedBox(
          width: 180,
          child: ElevatedButton(
            onPressed: authState.isSubmitting
                ? null
                : () async {
                    final messenger = ScaffoldMessenger.of(context);

                    try {
                      await ref.read(authControllerProvider.notifier).signOut();
                    } on AppException catch (error) {
                      if (!context.mounted) {
                        return;
                      }

                      messenger
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(error.message),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.error,
                          ),
                        );
                    }
                  },
            child: authState.isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Sign out'),
          ),
        ),
      ],
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.section),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              session?.fullName ?? session?.email ?? 'Signed in user',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.compact),
            Text(session?.email ?? ''),
            const SizedBox(height: AppSpacing.compact),
            Text(session?.targetRole ?? 'Target role not set'),
          ],
        ),
      ),
    );
  }
}
