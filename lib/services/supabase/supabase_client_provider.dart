import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/env.dart';

final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

abstract final class SupabaseBootstrap {
  static Future<void> initialize() async {
    Env.validateSupabase();

    await Supabase.initialize(
      url: Env.resolvedSupabaseUrl,
      anonKey: Env.resolvedSupabaseAnonKey,
    );
  }
}
