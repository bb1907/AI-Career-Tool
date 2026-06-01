import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Central registry for every outbound URL used across the app.
///
/// Keeping these in one place means a stubbed/empty `onTap` can never ship
/// again, and brand handles can be corrected in a single file.
///
/// NOTE: social handles and [appStoreId] are brand-default placeholders based
/// on the "aicareercopilot" brand. Replace with the real accounts/ID once they
/// exist. The links are still functional (they open a browser) in the meantime.
class AppLinks {
  AppLinks._();

  static const String domain = 'https://aicareercopilot.com';

  // ── Legal / support ─────────────────────────────────────────────────────────
  static const String terms = '$domain/terms';
  static const String privacy = '$domain/privacy';
  static const String eula = '$domain/eula';
  static const String support = '$domain/support';
  static const String help = '$domain/help';

  // ── Social (brand-default — confirm real handles) ────────────────────────────
  static const String instagram = 'https://instagram.com/aicareercopilot';
  static const String tiktok = 'https://tiktok.com/@aicareercopilot';
  static const String linkedin =
      'https://linkedin.com/company/aicareercopilot';
  static const String x = 'https://x.com/aicareercopilot';
  static const String discord = 'https://discord.gg/aicareercopilot';

  // ── App Store ────────────────────────────────────────────────────────────────
  /// Numeric App Store ID. Empty until the app is published; the rate action
  /// falls back to [support] while empty.
  static const String appStoreId = '';

  /// Deep link that opens the App Store review sheet, or [support] as fallback.
  static String get appStoreReview => appStoreId.isEmpty
      ? support
      : 'https://apps.apple.com/app/id$appStoreId?action=write-review';
}

/// Opens [url] in the external browser/app.
///
/// Returns `true` on success. On failure shows a localized error SnackBar when
/// a [context] is supplied and still mounted.
Future<bool> launchExternalUrl(
  String url, {
  BuildContext? context,
}) async {
  final uri = Uri.tryParse(url);
  var opened = false;
  if (uri != null) {
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
  }
  if (!opened && context != null && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open the link')),
    );
  }
  return opened;
}
