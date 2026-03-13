import '../errors/app_exception.dart';
import 'constants.dart';

enum AppEnvironment { development, production }

abstract final class Env {
  static const appEnv = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const aiBackendUrl = String.fromEnvironment('AI_BACKEND_URL');
  static const revenueCatAppleApiKey = String.fromEnvironment(
    'REVENUECAT_APPLE_API_KEY',
  );
  static const revenueCatEntitlementId = String.fromEnvironment(
    'REVENUECAT_ENTITLEMENT_ID',
    defaultValue: '',
  );

  static const localSupabaseUrl = 'http://127.0.0.1:54321';
  static const localSupabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';

  static AppEnvironment get environment {
    switch (appEnv.trim().toLowerCase()) {
      case 'prod':
      case 'production':
        return AppEnvironment.production;
      default:
        return AppEnvironment.development;
    }
  }

  static bool get isProduction => environment == AppEnvironment.production;
  static bool get isDevelopment => !isProduction;

  static bool get hasHostedSupabaseConfig =>
      supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;

  static bool get hasAiBackendConfig => aiBackendUrl.trim().isNotEmpty;
  static bool get hasRevenueCatConfig =>
      revenueCatAppleApiKey.trim().isNotEmpty;

  static String get resolvedSupabaseUrl => hasHostedSupabaseConfig
      ? supabaseUrl.trim()
      : isDevelopment
      ? localSupabaseUrl
      : '';

  static String get resolvedSupabaseAnonKey => hasHostedSupabaseConfig
      ? supabaseAnonKey.trim()
      : isDevelopment
      ? localSupabaseAnonKey
      : '';

  static String get resolvedAiBackendUrl => aiBackendUrl.trim();
  static String get resolvedRevenueCatAppleApiKey =>
      revenueCatAppleApiKey.trim();
  static String get resolvedRevenueCatEntitlementId {
    final entitlementId = revenueCatEntitlementId.trim();
    return entitlementId.isNotEmpty
        ? entitlementId
        : AppConstants.revenueCatEntitlementId;
  }

  static void validateSupabase() {
    if (resolvedSupabaseUrl.isEmpty || resolvedSupabaseAnonKey.isEmpty) {
      throw AppException(
        isProduction
            ? 'Supabase config is missing for production. Pass SUPABASE_URL and SUPABASE_ANON_KEY with --dart-define.'
            : 'Supabase config is missing. Start the local Supabase stack or pass SUPABASE_URL and SUPABASE_ANON_KEY with --dart-define.',
      );
    }
  }

  static String requireAiBackendUrl() {
    if (resolvedAiBackendUrl.isEmpty) {
      throw const AppException(
        'AI backend is not configured. Pass AI_BACKEND_URL with --dart-define.',
      );
    }

    return resolvedAiBackendUrl;
  }

  static String requireRevenueCatAppleApiKey() {
    if (resolvedRevenueCatAppleApiKey.isEmpty) {
      throw const AppException(
        'RevenueCat is not configured. Pass REVENUECAT_APPLE_API_KEY with --dart-define.',
      );
    }

    return resolvedRevenueCatAppleApiKey;
  }

  static List<String> get missingProductionVariables {
    final missing = <String>[];

    if (!hasHostedSupabaseConfig) {
      missing.addAll(const ['SUPABASE_URL', 'SUPABASE_ANON_KEY']);
    }

    if (!hasAiBackendConfig) {
      missing.add('AI_BACKEND_URL');
    }

    if (!hasRevenueCatConfig) {
      missing.add('REVENUECAT_APPLE_API_KEY');
    }

    return missing;
  }
}
