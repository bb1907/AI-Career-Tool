import '../../domain/entities/cover_letter_request.dart';
import '../../domain/entities/cover_letter_result.dart';
import '../../domain/repositories/cover_letter_repository.dart';
import '../datasources/cover_letter_local_datasource.dart';
import '../datasources/cover_letter_remote_datasource.dart';
import '../models/cover_letter_request_model.dart';
import '../models/cover_letter_result_model.dart';

class CoverLetterRepositoryImpl implements CoverLetterRepository {
  CoverLetterRepositoryImpl({
    required CoverLetterRemoteDatasource remoteDatasource,
    required CoverLetterLocalDatasource localDatasource,
  }) : _remoteDatasource = remoteDatasource,
       _localDatasource = localDatasource;

  final CoverLetterRemoteDatasource _remoteDatasource;
  final CoverLetterLocalDatasource _localDatasource;

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
    await _localDatasource.save(
      CoverLetterResultModel(coverLetter: result.coverLetter),
    );
  }

  @override
  Future<List<CoverLetterResult>> fetchHistory() async {
    return _localDatasource.fetchHistory();
  }
}
