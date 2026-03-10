import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/widgets/app_placeholder_scaffold.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final session = authState.session;
    final colorScheme = Theme.of(context).colorScheme;

    return AppPlaceholderScaffold(
      eyebrow: 'Protected route',
      title: 'Home',
      description: AppConfig.homeHeadline,
      actions: [
        SizedBox(
          width: 220,
          child: ElevatedButton(
            onPressed: authState.isSubmitting
                ? null
                : () => ref.read(authControllerProvider.notifier).signOut(),
            child: authState.isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Sign out'),
          ),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.section),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: colorScheme.surfaceContainerHighest,
            ),
            child: Text(
              'Signed in as ${session?.email ?? 'unknown user'}.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.section),
          Wrap(
            spacing: AppSpacing.compact,
            runSpacing: AppSpacing.compact,
            children: const [
              _FeatureChip(label: 'Resume Builder'),
              _FeatureChip(label: 'Cover Letters'),
              _FeatureChip(label: 'Interview Prep'),
              _FeatureChip(label: 'History'),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      avatar: const Icon(Icons.chevron_right, size: 18),
      side: BorderSide.none,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
    );
  }
}
