import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';

/// AI suggestion pill — teal accent, dismissible on tap.
class AiSuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const AiSuggestionChip({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(
            alpha: context.isDark ? 0.15 : 0.08,
          ),
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tips_and_updates_outlined,
              size: 13,
              color: AppColors.accent,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: context.isDark
                    ? AppColors.accent.withValues(alpha: 0.9)
                    : const Color(0xFF007A6B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
