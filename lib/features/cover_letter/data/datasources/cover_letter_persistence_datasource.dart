import '../models/cover_letter_result_model.dart';

abstract class CoverLetterPersistenceDatasource {
  Future<void> save(CoverLetterResultModel result);
  Future<List<CoverLetterResultModel>> fetchHistory();
}
