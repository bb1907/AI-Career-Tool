import 'package:flutter/material.dart';

enum AIButtonVariant { primary, secondary, tonal, ghost }

class AIButton extends StatelessWidget {
  const AIButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = AIButtonVariant.primary,
    this.isLoading = false,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final AIButtonVariant variant;
  final bool isLoading;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == AIButtonVariant.primary
                    ? Colors.white
                    : colorScheme.primary,
              ),
            ),
          )
        else if (icon != null) ...[
          icon!,
        ],
        if (isLoading || icon != null) const SizedBox(width: 10),
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );

    Widget button;
    switch (variant) {
      case AIButtonVariant.primary:
        button = FilledButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        );
      case AIButtonVariant.secondary:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        );
      case AIButtonVariant.tonal:
        button = FilledButton.tonal(
          onPressed: isLoading ? null : onPressed,
          child: child,
        );
      case AIButtonVariant.ghost:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        );
    }

    if (!expanded) {
      return button;
    }

    return SizedBox(width: double.infinity, child: button);
  }
}
