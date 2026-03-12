import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  const DatabaseService(this._client);

  final SupabaseClient _client;

  SupabaseQueryBuilder from(String table) => _client.from(table);
}
