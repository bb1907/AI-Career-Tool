import '../models/resume_result_model.dart';

class ResumeLocalDatasource {
  final List<ResumeResultModel> _history = [];

  Future<void> save(ResumeResultModel result) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _history.insert(0, result);
  }

  Future<List<ResumeResultModel>> fetchHistory() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return List<ResumeResultModel>.unmodifiable(_history);
  }
}
