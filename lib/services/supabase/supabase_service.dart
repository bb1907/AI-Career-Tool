import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../app/core/app_config.dart';

/// Manages Supabase initialization and provides access to the client.
///
/// When [AppConfig.hasSupabaseConfig] is false the service stays dormant and
/// the app falls back to in-memory implementations.
class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  bool _initialized = false;

  /// Whether Supabase has been successfully initialized.
  bool get isInitialized => _initialized;

  /// The underlying Supabase client. Throws if not yet initialized.
  SupabaseClient get client {
    assert(_initialized, 'SupabaseService.initialize() must be called first');
    return Supabase.instance.client;
  }

  /// Initialize Supabase. Safe to call multiple times -- subsequent calls
  /// are no-ops. Returns false if config is missing.
  Future<bool> initialize() async {
    if (_initialized) return true;

    if (!AppConfig.hasSupabaseConfig) {
      debugPrint(
        '[SupabaseService] No Supabase config found -- running in offline mode',
      );
      return false;
    }

    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey,
      );
      _initialized = true;
      debugPrint('[SupabaseService] Initialized successfully');
      return true;
    } catch (e) {
      debugPrint('[SupabaseService] Initialization failed: $e');
      return false;
    }
  }
}

/// Riverpod provider that exposes the singleton [SupabaseService].
final supabaseProvider = Provider<SupabaseService>((ref) {
  return SupabaseService.instance;
});
