import 'package:flutter/material.dart';

abstract final class AppFeedback {
  static void showSuccess(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    _show(
      context,
      message,
      backgroundColor: colorScheme.secondaryContainer,
      foregroundColor: colorScheme.onSecondaryContainer,
    );
  }

  static void showError(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    _show(
      context,
      message,
      backgroundColor: colorScheme.errorContainer,
      foregroundColor: colorScheme.onErrorContainer,
    );
  }

  static void showInfo(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    _show(
      context,
      message,
      backgroundColor: colorScheme.inverseSurface,
      foregroundColor: colorScheme.onInverseSurface,
    );
  }

  static void _show(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    if (!context.mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: backgroundColor,
          content: Text(message, style: TextStyle(color: foregroundColor)),
        ),
      );
  }
}
