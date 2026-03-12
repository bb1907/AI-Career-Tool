import '../entities/resume_request.dart';
import '../entities/resume_result.dart';

abstract class ResumeRepository {
  Future<ResumeResult> generateResume(ResumeRequest request);
  Future<void> saveResume(ResumeResult result);
  Future<List<ResumeResult>> fetchHistory();
}
