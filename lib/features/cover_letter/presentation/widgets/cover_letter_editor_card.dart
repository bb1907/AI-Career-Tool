import 'package:flutter/material.dart';

import '../../../../core/utils/app_spacing.dart';

class CoverLetterEditorCard extends StatelessWidget {
  const CoverLetterEditorCard({
    super.key,
    required this.controller,
    required this.enabled,
    this.onChanged,
  });

  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Editable draft',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.compact),
            Text(
              'Refine the generated letter before copying or saving it.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.section),
            TextField(
              controller: controller,
              enabled: enabled,
              minLines: 14,
              maxLines: 20,
              onChanged: onChanged,
              decoration: const InputDecoration(
                hintText: 'Your cover letter will appear here.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
