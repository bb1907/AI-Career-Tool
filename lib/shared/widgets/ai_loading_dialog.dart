import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import '../../ui/components/ai_loading_indicator.dart';

/// Shows a modal dialog with [AiLoadingIndicator].
/// Dismiss with Navigator.of(context).pop() when the operation completes.
void showAiLoading(BuildContext context, {required List<String> messages}) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (_) => _AiLoadingDialog(messages: messages),
  );
}

class _AiLoadingDialog extends StatelessWidget {
  final List<String> messages;
  const _AiLoadingDialog({required this.messages});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.appSurface,
          borderRadius: BorderRadius.circular(AppRadius.card + 4),
          boxShadow: AppShadows.elevated(context),
          border: Border.all(color: context.appBorder),
        ),
        child: AiLoadingIndicator(messages: messages),
      ),
    );
  }
}
