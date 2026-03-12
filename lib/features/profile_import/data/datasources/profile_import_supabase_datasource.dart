import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../services/supabase/database_error_mapper.dart';
import '../../../../services/supabase/database_service.dart';
import '../../../../services/supabase/storage_service.dart';
import '../../domain/entities/cv_upload_file.dart';
import '../models/candidate_profile_model.dart';
import '../models/uploaded_cv_record_model.dart';

class ProfileImportSupabaseDatasource {
  const ProfileImportSupabaseDatasource({
    required DatabaseService databaseService,
    required SupabaseStorageService storageService,
  }) : _databaseService = databaseService,
       _storageService = storageService;

  static const cvUploadsBucket = 'cv-uploads';

  final DatabaseService _databaseService;
  final SupabaseStorageService _storageService;

  Future<UploadedCvRecordModel> uploadCv(CvUploadFile file) async {
    final userId = _databaseService.requireCurrentUserId();
    final storagePath = _buildStoragePath(userId, file.fileName);

    await _storageService.uploadPdf(
      bucket: cvUploadsBucket,
      path: storagePath,
      bytes: file.bytes,
    );

    try {
      final response = await _databaseService
          .from('uploaded_cvs')
          .insert({
            'user_id': userId,
            'file_name': file.fileName,
            'storage_bucket': cvUploadsBucket,
            'storage_path': storagePath,
            'mime_type': file.mimeType,
            'file_size_bytes': file.sizeInBytes,
            'parsing_status': 'processing',
          })
          .select('id, file_name, storage_path, parsing_status')
          .single();

      return UploadedCvRecordModel.fromJson(
        Map<String, dynamic>.from(response),
      );
    } on PostgrestException catch (error) {
      throw DatabaseErrorMapper.map(
        error,
        fallbackMessage: 'CV metadata could not be saved right now.',
      );
    } catch (error) {
      throw DatabaseErrorMapper.map(
        error,
        fallbackMessage: 'CV metadata could not be saved right now.',
      );
    }
  }

  Future<void> saveCandidateProfile({
    required String uploadedCvId,
    required CandidateProfileModel profile,
  }) async {
    final userId = _databaseService.requireCurrentUserId();

    try {
      await _databaseService
          .from('candidate_profiles')
          .insert(
            profile.toDatabaseJson(uploadedCvId: uploadedCvId, userId: userId),
          );
    } on PostgrestException catch (error) {
      throw DatabaseErrorMapper.map(
        error,
        fallbackMessage: 'Candidate profile could not be saved right now.',
      );
    } catch (error) {
      throw DatabaseErrorMapper.map(
        error,
        fallbackMessage: 'Candidate profile could not be saved right now.',
      );
    }
  }

  Future<void> markUploadParsed(String uploadedCvId) async {
    await _updateUploadStatus(uploadedCvId, status: 'parsed');
  }

  Future<void> markUploadFailed(String uploadedCvId, String message) async {
    await _updateUploadStatus(
      uploadedCvId,
      status: 'failed',
      errorMessage: message,
    );
  }

  Future<void> _updateUploadStatus(
    String uploadedCvId, {
    required String status,
    String? errorMessage,
  }) async {
    final userId = _databaseService.requireCurrentUserId();

    try {
      await _databaseService
          .from('uploaded_cvs')
          .update({'parsing_status': status, 'parsing_error': errorMessage})
          .eq('id', uploadedCvId)
          .eq('user_id', userId);
    } on PostgrestException catch (error) {
      throw DatabaseErrorMapper.map(
        error,
        fallbackMessage: 'CV processing status could not be updated.',
      );
    } catch (error) {
      throw DatabaseErrorMapper.map(
        error,
        fallbackMessage: 'CV processing status could not be updated.',
      );
    }
  }

  String _buildStoragePath(String userId, String fileName) {
    final normalizedName = fileName.trim().replaceAll(
      RegExp(r'[^a-zA-Z0-9._-]+'),
      '_',
    );
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    return '$userId/$timestamp-$normalizedName';
  }
}
