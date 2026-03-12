import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import 'supabase_client_provider.dart';

final databaseServiceProvider = Provider<DatabaseService>(
  (ref) => DatabaseService(ref.watch(supabaseClientProvider)),
);

class DatabaseService {
  const DatabaseService(this._client);

  final SupabaseClient _client;

  SupabaseQueryBuilder from(String table) => _client.from(table);

  String requireCurrentUserId() {
    final userId = _client.auth.currentUser?.id;

    if (userId == null || userId.isEmpty) {
      throw const AppException('Sign in again to continue.');
    }

    return userId;
  }
}
