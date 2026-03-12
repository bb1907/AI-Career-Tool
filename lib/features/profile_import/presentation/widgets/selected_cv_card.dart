import 'package:flutter/material.dart';

import '../../../../core/utils/app_spacing.dart';
import '../../domain/entities/cv_upload_file.dart';

class SelectedCvCard extends StatelessWidget {
  const SelectedCvCard({
    super.key,
    required this.file,
    required this.onReplace,
    required this.onClear,
  });

  final CvUploadFile file;
  final VoidCallback? onReplace;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected PDF',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.compact),
            Text(file.fileName, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 8),
            Text(
              '${(file.sizeInBytes / 1024).toStringAsFixed(0)} KB',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.section),
            Wrap(
              spacing: AppSpacing.compact,
              runSpacing: AppSpacing.compact,
              children: [
                FilledButton.tonal(
                  onPressed: onReplace,
                  child: const Text('Replace PDF'),
                ),
                OutlinedButton(onPressed: onClear, child: const Text('Remove')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
