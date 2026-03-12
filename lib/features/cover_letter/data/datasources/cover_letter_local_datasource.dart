import '../models/cover_letter_result_model.dart';

class CoverLetterLocalDatasource {
  final List<CoverLetterResultModel> _history = [];

  Future<void> save(CoverLetterResultModel result) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _history.insert(0, result);
  }

  Future<List<CoverLetterResultModel>> fetchHistory() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return List<CoverLetterResultModel>.unmodifiable(_history);
  }
}
