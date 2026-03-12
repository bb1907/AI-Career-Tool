import '../../domain/entities/cover_letter_request.dart';
import '../../domain/entities/cover_letter_result.dart';
import '../../domain/repositories/cover_letter_repository.dart';
import '../datasources/cover_letter_persistence_datasource.dart';
import '../datasources/cover_letter_remote_datasource.dart';
import '../models/cover_letter_request_model.dart';
import '../models/cover_letter_result_model.dart';

class CoverLetterRepositoryImpl implements CoverLetterRepository {
  CoverLetterRepositoryImpl({
    required CoverLetterRemoteDatasource remoteDatasource,
    required CoverLetterPersistenceDatasource persistenceDatasource,
  }) : _remoteDatasource = remoteDatasource,
       _persistenceDatasource = persistenceDatasource;

  final CoverLetterRemoteDatasource _remoteDatasource;
  final CoverLetterPersistenceDatasource _persistenceDatasource;

  @override
  Future<CoverLetterResult> generateCoverLetter(
    CoverLetterRequest request,
  ) async {
    return _remoteDatasource.generateCoverLetter(
      CoverLetterRequestModel.fromEntity(request),
    );
  }

  @override
  Future<void> saveCoverLetter(CoverLetterResult result) async {
    await _persistenceDatasource.save(
      CoverLetterResultModel(
        coverLetter: result.coverLetter,
        createdAt: result.createdAt,
      ),
    );
  }

  @override
  Future<List<CoverLetterResult>> fetchHistory() async {
    return _persistenceDatasource.fetchHistory();
  }
}
