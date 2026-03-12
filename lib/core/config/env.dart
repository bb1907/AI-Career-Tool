import '../errors/app_exception.dart';

abstract final class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const aiBackendUrl = String.fromEnvironment('AI_BACKEND_URL');

  static const localSupabaseUrl = 'http://127.0.0.1:54321';
  static const localSupabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';

  static String get resolvedSupabaseUrl =>
      supabaseUrl.isNotEmpty ? supabaseUrl : localSupabaseUrl;

  static String get resolvedSupabaseAnonKey =>
      supabaseAnonKey.isNotEmpty ? supabaseAnonKey : localSupabaseAnonKey;

  static String get resolvedAiBackendUrl => aiBackendUrl.trim();

  static void validateSupabase() {
    if (resolvedSupabaseUrl.isEmpty || resolvedSupabaseAnonKey.isEmpty) {
      throw const AppException(
        'Supabase config is missing. Start the local Supabase stack or pass SUPABASE_URL and SUPABASE_ANON_KEY with --dart-define.',
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
}
