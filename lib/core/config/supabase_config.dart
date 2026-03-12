import 'env.dart';

abstract final class SupabaseConfig {
  static String get url => Env.resolvedSupabaseUrl;

  static String get anonKey => Env.resolvedSupabaseAnonKey;

  static void validate() {
    Env.validateSupabase();
  }
}
