import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import 'supabase_client_provider.dart';

final supabaseStorageServiceProvider = Provider<SupabaseStorageService>(
  (ref) => SupabaseStorageService(ref.watch(supabaseClientProvider)),
);

class SupabaseStorageService {
  const SupabaseStorageService(this._client);

  final SupabaseClient _client;

  Future<String> uploadPdf({
    required String bucket,
    required String path,
    required Uint8List bytes,
  }) async {
    try {
      return await _client.storage
          .from(bucket)
          .uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'application/pdf',
              upsert: false,
            ),
          );
    } on StorageException catch (error) {
      final message = error.message.toLowerCase();

      if (message.contains('bucket')) {
        throw const AppException(
          'Supabase storage bucket is not ready yet. Create the cv-uploads bucket first.',
        );
      }

      throw const AppException('CV upload failed. Try again.');
    } catch (_) {
      throw const AppException('CV upload failed. Try again.');
    }
  }
}
