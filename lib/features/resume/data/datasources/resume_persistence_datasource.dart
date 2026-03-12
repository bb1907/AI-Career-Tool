import '../models/resume_result_model.dart';

abstract class ResumePersistenceDatasource {
  Future<void> save(ResumeResultModel result);
  Future<List<ResumeResultModel>> fetchHistory();
}
