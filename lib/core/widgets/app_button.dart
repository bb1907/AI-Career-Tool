import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expanded = true,
    this.variant = AppButtonVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final bool expanded;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final buttonChild = isLoading
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              Text(label),
            ],
          )
        : icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [icon!, const SizedBox(width: 8), Text(label)],
          );

    final Widget button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: isLoading ? null : onPressed,
        child: buttonChild,
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        child: buttonChild,
      ),
      AppButtonVariant.tonal => FilledButton.tonal(
        onPressed: isLoading ? null : onPressed,
        child: buttonChild,
      ),
    };

    if (!expanded) {
      return button;
    }

    return SizedBox(width: double.infinity, child: button);
  }
}

enum AppButtonVariant { primary, secondary, tonal }
