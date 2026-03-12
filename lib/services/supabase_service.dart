import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase/supabase_client_provider.dart';

final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

abstract final class SupabaseService {
  static Future<void> initialize() async {
    await SupabaseBootstrap.initialize();
  }
}
