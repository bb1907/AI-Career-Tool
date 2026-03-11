import '../errors/app_exception.dart';

abstract final class SupabaseConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static void validate() {
    if (url.isEmpty || anonKey.isEmpty) {
      throw const AppException(
        'Supabase config is missing. Pass SUPABASE_URL and SUPABASE_ANON_KEY with --dart-define.',
      );
    }
  }
}
