import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../services/ai/ai_service_impl.dart';
import '../../../services/supabase/database_service.dart';
import '../../../services/supabase/storage_service.dart';
import '../data/datasources/profile_import_remote_datasource.dart';
import '../data/datasources/profile_import_supabase_datasource.dart';
import '../data/repositories/profile_import_repository_impl.dart';
import '../data/services/syncfusion_pdf_text_extraction_service.dart';
import '../domain/entities/cv_upload_file.dart';
import '../domain/repositories/profile_import_repository.dart';
import 'profile_import_state.dart';

final pdfTextExtractionServiceProvider =
    Provider<SyncfusionPdfTextExtractionService>(
      (ref) => const SyncfusionPdfTextExtractionService(),
    );

final profileImportRemoteDatasourceProvider =
    Provider<ProfileImportRemoteDatasource>(
      (ref) => ProfileImportRemoteDatasource(ref.watch(aiServiceProvider)),
    );

final profileImportSupabaseDatasourceProvider =
    Provider<ProfileImportSupabaseDatasource>(
      (ref) => ProfileImportSupabaseDatasource(
        databaseService: ref.watch(databaseServiceProvider),
        storageService: ref.watch(supabaseStorageServiceProvider),
      ),
    );

final profileImportRepositoryProvider = Provider<ProfileImportRepository>(
  (ref) => ProfileImportRepositoryImpl(
    supabaseDatasource: ref.watch(profileImportSupabaseDatasourceProvider),
    remoteDatasource: ref.watch(profileImportRemoteDatasourceProvider),
    pdfTextExtractionService: ref.watch(pdfTextExtractionServiceProvider),
  ),
);

final profileImportControllerProvider =
    NotifierProvider<ProfileImportController, ProfileImportState>(
      ProfileImportController.new,
    );

class ProfileImportController extends Notifier<ProfileImportState> {
  @override
  ProfileImportState build() => const ProfileImportState();

  void selectFile(CvUploadFile file) {
    state = state.copyWith(
      selectedFile: file,
      clearError: true,
      clearProfile: true,
    );
  }

  void clearSelection() {
    state = state.copyWith(
      clearFile: true,
      clearProfile: true,
      clearError: true,
      processingLabel: null,
    );
  }

  Future<void> importSelectedCv() async {
    final file = state.selectedFile;

    if (file == null) {
      throw const AppException('Choose a PDF CV before continuing.');
    }

    if (state.isImporting) {
      return;
    }

    state = state.copyWith(
      isImporting: true,
      processingLabel: 'Uploading and parsing CV...',
      clearError: true,
      clearProfile: true,
    );

    try {
      final profileFuture = ref
          .read(profileImportRepositoryProvider)
          .importCv(file);
      final profile = await profileFuture;

      state = state.copyWith(
        isImporting: false,
        processingLabel: null,
        profile: profile,
      );
    } on AppException catch (error) {
      state = state.copyWith(
        isImporting: false,
        processingLabel: null,
        errorMessage: error.message,
      );
    } catch (_) {
      state = state.copyWith(
        isImporting: false,
        processingLabel: null,
        errorMessage: 'CV import failed. Try again.',
      );
    }
  }
}
