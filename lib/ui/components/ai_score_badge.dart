import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';

/// AI Quality Score badge — color-coded (green / amber / blue).
class AiScoreBadge extends StatelessWidget {
  final int score; // 0–100

  const AiScoreBadge({super.key, required this.score});

  Color get _color {
    if (score >= 90) return AppColors.accent; // teal — great
    if (score >= 75) return AppColors.warning; // amber — good
    return AppColors.primary; // purple — needs work
  }

  String get _label {
    if (score >= 90) return 'Excellent';
    if (score >= 75) return 'Good';
    return 'Improve';
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: context.isDark ? 0.15 : 0.07),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular score indicator
          SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 4,
                  backgroundColor: color.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  strokeCap: StrokeCap.round,
                ),
                Text(
                  '$score',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Quality Score',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: context.appText2,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$_label · $score / 100',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
