import 'package:flutter/material.dart';

class AIScoreBadge extends StatelessWidget {
  const AIScoreBadge({super.key, required this.label, this.score, this.status})
    : assert(score != null || status != null);

  final String label;
  final int? score;
  final String? status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final scoreValue = score;
    final toneColor = scoreValue == null
        ? colorScheme.secondary
        : scoreValue >= 85
        ? colorScheme.secondary
        : scoreValue >= 70
        ? colorScheme.tertiary
        : colorScheme.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: toneColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: toneColor.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 18, color: toneColor),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                scoreValue != null ? '$scoreValue / 100' : status!,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
