import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'features/settings/providers/language_provider.dart';
import 'features/settings/providers/ai_language_provider.dart';
import 'services/revenuecat/revenuecat_service.dart';
import 'services/supabase/supabase_service.dart';
import 'services/subscription/subscription_provider.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // Preserve native splash until Flutter UI is ready (skip on web)
  if (!kIsWeb) {
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  }

  // Load .env for development. Silently ignored in production
  // (production builds use --dart-define=KEY=value instead).
  try {
    await dotenv.load(fileName: '.env').timeout(const Duration(seconds: 2));
    debugPrint('[DEBUG] .env loaded successfully');
  } catch (e) {
    debugPrint('[DEBUG] .env load FAILED: $e');
    // .env not bundled — API keys come from --dart-define
  }

  // ── Debug: print API key status ──────────────────────────────────────────────
  debugPrint(
    '[DEBUG] GROQ key present: ${dotenv.get('GROQ_API_KEY', fallback: '').isNotEmpty}',
  );
  debugPrint(
    '[DEBUG] DEEPSEEK key present: ${dotenv.get('DEEPSEEK_API_KEY', fallback: '').isNotEmpty}',
  );
  debugPrint(
    '[DEBUG] GEMINI key present: ${dotenv.get('GEMINI_API_KEY', fallback: '').isNotEmpty}',
  );
  debugPrint(
    '[DEBUG] OPENAI key present: ${dotenv.get('OPENAI_API_KEY', fallback: '').isNotEmpty}',
  );

  // ── Initialize Supabase (graceful — skips if not configured) ──────────────
  // Hard timeout: even if the network call hangs, the iOS watchdog must not
  // kill the app. 4 s is well under the ~10 s springboard launch budget.
  try {
    await SupabaseService.instance.initialize().timeout(
      const Duration(seconds: 4),
    );
  } catch (e) {
    debugPrint('[main] Supabase init skipped: $e');
  }

  // ── Initialize RevenueCat (graceful — skips if not configured) ─────────────
  try {
    await RevenueCatService.instance.initialize().timeout(
      const Duration(seconds: 4),
    );
  } catch (e) {
    debugPrint('[main] RevenueCat init skipped: $e');
  }

  // Determine initial locale: saved preference -> device locale -> English
  final prefs = await SharedPreferences.getInstance();
  final savedLang = prefs.getString('app_locale');
  Locale initialLocale;
  if (savedLang != null) {
    initialLocale = Locale(savedLang);
  } else {
    final deviceLang =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    const supported = [
      'en',
      'es',
      'fr',
      'de',
      'it',
      'pt',
      'nl',
      'sv',
      'nb',
      'da',
      'fi',
      'pl',
      'cs',
      'sk',
      'sl',
      'hr',
      'sr',
      'bg',
      'ro',
      'hu',
      'el',
      'ru',
      'uk',
      'lt',
      'lv',
      'et',
      'ka',
      'he',
      'ar',
      'tr',
      'fa',
      'hi',
      'bn',
      'ur',
      'ne',
      'si',
      'zh',
      'ja',
      'ko',
      'th',
      'vi',
      'id',
      'ms',
      'tl',
      'my',
      'km',
      'lo',
      'sw',
      'am',
      'ca',
    ];
    initialLocale = supported.contains(deviceLang)
        ? Locale(deviceLang)
        : const Locale('en');
  }

  LanguageNotifier.initialLocale = initialLocale;
  AiLanguageNotifier.initial = await AiLanguageNotifier.load();
  SubscriptionNotifier.initialSoftPaywallShown =
      await SubscriptionNotifier.loadSoftPaywallShown();
  runApp(const ProviderScope(child: MyApp()));
}
