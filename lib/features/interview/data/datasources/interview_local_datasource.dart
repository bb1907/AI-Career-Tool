import 'interview_persistence_datasource.dart';
import '../models/interview_result_model.dart';

class InterviewLocalDatasource implements InterviewPersistenceDatasource {
  final List<InterviewResultModel> _history = [];

  @override
  Future<void> save(InterviewResultModel result) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _history.insert(0, result);
  }

  @override
  Future<List<InterviewResultModel>> fetchHistory() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return List<InterviewResultModel>.unmodifiable(_history);
  }
}
