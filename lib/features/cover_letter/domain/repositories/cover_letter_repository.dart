import '../entities/cover_letter_request.dart';
import '../entities/cover_letter_result.dart';

abstract class CoverLetterRepository {
  Future<CoverLetterResult> generateCoverLetter(CoverLetterRequest request);
  Future<void> saveCoverLetter(CoverLetterResult result);
  Future<List<CoverLetterResult>> fetchHistory();
}
