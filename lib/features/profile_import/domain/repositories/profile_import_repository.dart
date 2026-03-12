import '../entities/candidate_profile.dart';
import '../entities/cv_upload_file.dart';

abstract class ProfileImportRepository {
  Future<CandidateProfile> importCv(CvUploadFile file);
}
