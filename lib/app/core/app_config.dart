import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application configuration.
///
/// API key priority:
///   1. .env file (development — never commit this file)
///   2. --dart-define at build time (CI / production)
class AppConfig {
  static const String appName = 'AI Career Tools';
  static const String version = '1.0.0';

  // ── API Keys ───────────────────────────────────────────────────────────────

  /// Groq — fast inference for chat (llama-3.3-70b-versatile)
  static String get groqApiKey => _key('GROQ_API_KEY');

  /// Gemini — primary content generation + CV parsing (Flash / Flash-Lite / Pro)
  static String get geminiApiKey => _key('GEMINI_API_KEY');

  /// OpenAI — fallback (gpt-4o-mini)
  static String get openAiApiKey => _key('OPENAI_API_KEY');

  /// FASHN — AI virtual try-on / outfit generation
  static String get fashnApiKey => _key('FASHN_API_KEY');

  // ── Supabase ────────────────────────────────────────────────────────────────

  static String get supabaseUrl => _key('SUPABASE_URL');
  static String get supabaseAnonKey => _key('SUPABASE_ANON_KEY');

  // ── RevenueCat ──────────────────────────────────────────────────────────────

  static String get revenueCatApiKey => _key('REVENUECAT_API_KEY');

  // ── Status helpers ─────────────────────────────────────────────────────────

  static bool get hasGroqKey => _valid(groqApiKey);
  static bool get hasGeminiKey => _valid(geminiApiKey);
  static bool get hasOpenAiKey => _valid(openAiApiKey);
  static bool get hasFashnKey => _valid(fashnApiKey);
  static bool get hasSupabaseConfig =>
      _valid(supabaseUrl) && _valid(supabaseAnonKey);
  static bool get hasRevenueCatKey => _valid(revenueCatApiKey);
  static bool get hasAnyAiKey =>
      hasGroqKey || hasGeminiKey || hasOpenAiKey;

  // ── Internals ──────────────────────────────────────────────────────────────

  /// Read from .env first; fall back to --dart-define.
  static String _key(String name) {
    final fromEnv = dotenv.get(name, fallback: '');
    if (_valid(fromEnv)) return fromEnv;
    return _dartDefines[name] ?? '';
  }

  // compile-time constants — each name must be listed individually
  static const _dartDefines = <String, String>{
    'GROQ_API_KEY': String.fromEnvironment('GROQ_API_KEY', defaultValue: ''),
    'GEMINI_API_KEY': String.fromEnvironment(
      'GEMINI_API_KEY',
      defaultValue: '',
    ),
    'OPENAI_API_KEY': String.fromEnvironment(
      'OPENAI_API_KEY',
      defaultValue: '',
    ),
    'FASHN_API_KEY': String.fromEnvironment('FASHN_API_KEY', defaultValue: ''),
    'SUPABASE_URL': String.fromEnvironment('SUPABASE_URL', defaultValue: ''),
    'SUPABASE_ANON_KEY': String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: '',
    ),
    'REVENUECAT_API_KEY': String.fromEnvironment(
      'REVENUECAT_API_KEY',
      defaultValue: '',
    ),
  };

  /// A key is "valid" only if it is non-empty AND doesn't look like one of
  /// the obvious placeholder strings shipped in the example .env. Without
  /// this guard, init code (Supabase, RevenueCat) would actually try to
  /// connect to fake URLs at app launch and trigger an iOS watchdog SIGKILL.
  static bool _valid(String key) {
    if (key.isEmpty) return false;
    final lower = key.toLowerCase();
    if (lower == 'placeholder') return false;
    if (lower.startsWith('your-') || lower.startsWith('your_')) return false;
    if (lower.contains('your-project') || lower.contains('your-anon')) {
      return false;
    }
    if (lower.contains('xxx') || lower.contains('changeme')) return false;
    return true;
  }
}
