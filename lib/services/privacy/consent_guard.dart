import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'consent_controller.dart';

/// Shows an AI data processing consent dialog if consent has not yet been
/// granted. Returns true when the user grants consent (or it was already
/// granted), false when the user declines or dismisses.
Future<bool> ensureAiDataConsent(BuildContext context, WidgetRef ref) async {
  final consentAsync = ref.read(consentControllerProvider);
  if (consentAsync.value?.aiDataGranted == true) return true;

  if (!context.mounted) return false;

  final granted = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('AI Data Processing'),
      content: const Text(
        'To generate your content, your input (role, experience, job description) '
        'will be sent to our AI providers for processing.\n\n'
        'We do not store your data beyond what is necessary to provide the service. '
        'You can withdraw consent at any time in Settings → Privacy.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Decline'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('I Agree'),
        ),
      ],
    ),
  );

  if (granted == true) {
    await ref.read(consentControllerProvider.notifier).grantAiData();
    return true;
  }
  return false;
}

/// Shows a biometric/photo consent dialog before accessing the camera or
/// photo library for AI Photo Studio. Returns true when consent is granted.
Future<bool> ensureBiometricConsent(BuildContext context, WidgetRef ref) async {
  final consentAsync = ref.read(consentControllerProvider);
  if (consentAsync.value?.biometricGranted == true) return true;

  if (!context.mounted) return false;

  final granted = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Photo & AI Processing'),
      content: const Text(
        'AI Photo Studio will process your photo to create a professional headshot.\n\n'
        '• Your photo is sent to an AI image provider.\n'
        '• The original photo is deleted from local storage after processing.\n'
        '• Generated headshots are NOT uploaded to our servers unless you '
        'explicitly save them to your profile.\n'
        '• We do not use your photo for training AI models.\n\n'
        'You can withdraw consent at any time in Settings → Privacy.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Decline'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('I Agree'),
        ),
      ],
    ),
  );

  if (granted == true) {
    await ref.read(consentControllerProvider.notifier).grantBiometric();
    return true;
  }
  return false;
}
