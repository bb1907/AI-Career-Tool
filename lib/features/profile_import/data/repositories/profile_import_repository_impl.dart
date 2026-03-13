import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/candidate_profile.dart';
import '../../domain/entities/cv_upload_file.dart';
import '../../domain/repositories/profile_import_repository.dart';
import '../datasources/profile_import_remote_datasource.dart';
import '../datasources/profile_import_supabase_datasource.dart';
import '../models/candidate_profile_model.dart';
import '../services/pdf_text_extraction_service.dart';

class ProfileImportRepositoryImpl implements ProfileImportRepository {
  const ProfileImportRepositoryImpl({
    required ProfileImportSupabaseDatasource supabaseDatasource,
    required ProfileImportRemoteDatasource remoteDatasource,
    required PdfTextExtractionService pdfTextExtractionService,
  }) : _supabaseDatasource = supabaseDatasource,
       _remoteDatasource = remoteDatasource,
       _pdfTextExtractionService = pdfTextExtractionService;

  final ProfileImportSupabaseDatasource _supabaseDatasource;
  final ProfileImportRemoteDatasource _remoteDatasource;
  final PdfTextExtractionService _pdfTextExtractionService;

  @override
  Future<CandidateProfile> importCv(CvUploadFile file) async {
    final uploadedCv = await _supabaseDatasource.uploadCv(file);

    try {
      final extractedText = await _pdfTextExtractionService.extractText(
        file.bytes,
      );
      final profile = await _remoteDatasource.parseCv(
        extractedText: extractedText,
        fileName: file.fileName,
      );

      final savedProfile = await _supabaseDatasource.saveCandidateProfile(
        uploadedCvId: uploadedCv.id,
        profile: profile,
      );
      await _supabaseDatasource.markUploadParsed(uploadedCv.id);

      return savedProfile;
    } on AppException catch (error) {
      await _safelyMarkFailed(uploadedCv.id, error.message);
      rethrow;
    } catch (_) {
      await _safelyMarkFailed(uploadedCv.id, 'CV parsing failed unexpectedly.');
      throw const AppException('CV parsing failed unexpectedly.');
    }
  }

  @override
  Future<CandidateProfile?> fetchLatestProfile() {
    return _supabaseDatasource.fetchLatestCandidateProfile();
  }

  @override
  Future<CandidateProfile> updateProfile(CandidateProfile profile) {
    return _supabaseDatasource.updateCandidateProfile(
      CandidateProfileModel.fromEntity(profile),
    );
  }

  Future<void> _safelyMarkFailed(String uploadedCvId, String message) async {
    try {
      await _supabaseDatasource.markUploadFailed(uploadedCvId, message);
    } catch (_) {
      // Keep the original import error as the surfaced failure.
    }
  }
}
