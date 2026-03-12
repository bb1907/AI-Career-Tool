import '../models/interview_result_model.dart';

abstract class InterviewPersistenceDatasource {
  Future<void> save(InterviewResultModel result);
  Future<List<InterviewResultModel>> fetchHistory();
}
