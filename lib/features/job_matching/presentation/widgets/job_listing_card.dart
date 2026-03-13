import 'package:flutter/material.dart';

import '../../../../core/utils/app_spacing.dart';
import '../../domain/entities/job_listing.dart';

class JobListingCard extends StatelessWidget {
  const JobListingCard({
    super.key,
    required this.job,
    required this.isSelected,
    required this.onSelect,
    required this.onUseInCoverLetter,
    required this.onUseInVideoIntro,
  });

  final JobListing job;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onUseInCoverLetter;
  final VoidCallback onUseInVideoIntro;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        job.company,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Selected',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.section),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MetaChip(
                  icon: Icons.location_on_outlined,
                  label: job.location,
                ),
                _MetaChip(icon: Icons.public_outlined, label: job.source),
              ],
            ),
            const SizedBox(height: AppSpacing.section),
            Text(
              job.url,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.section),
            Text(
              job.jobDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.page),
            Wrap(
              spacing: AppSpacing.compact,
              runSpacing: AppSpacing.compact,
              children: [
                FilledButton.tonalIcon(
                  onPressed: onSelect,
                  icon: Icon(
                    isSelected
                        ? Icons.check_circle_outline
                        : Icons.bookmark_border,
                  ),
                  label: Text(isSelected ? 'Selected' : 'Select job'),
                ),
                OutlinedButton.icon(
                  onPressed: onUseInCoverLetter,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Use in cover letter'),
                ),
                OutlinedButton.icon(
                  onPressed: onUseInVideoIntro,
                  icon: const Icon(Icons.videocam_outlined),
                  label: const Text('Use in video intro'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
