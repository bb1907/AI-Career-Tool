import 'resume_persistence_datasource.dart';
import '../models/resume_result_model.dart';

class ResumeLocalDatasource implements ResumePersistenceDatasource {
  final List<ResumeResultModel> _history = [];

  @override
  Future<void> save(ResumeResultModel result) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _history.insert(0, result);
  }

  @override
  Future<List<ResumeResultModel>> fetchHistory() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return List<ResumeResultModel>.unmodifiable(_history);
  }
}
