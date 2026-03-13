import '../../domain/entities/cover_letter_request.dart';
import '../../domain/entities/cover_letter_result.dart';
import '../../domain/repositories/cover_letter_repository.dart';
import '../datasources/cover_letter_analysis_remote_datasource.dart';
import '../datasources/cover_letter_persistence_datasource.dart';
import '../datasources/cover_letter_remote_datasource.dart';
import '../models/cover_letter_request_model.dart';
import '../models/cover_letter_result_model.dart';

class CoverLetterRepositoryImpl implements CoverLetterRepository {
  CoverLetterRepositoryImpl({
    required CoverLetterRemoteDatasource remoteDatasource,
    required CoverLetterAnalysisRemoteDatasource analysisRemoteDatasource,
    required CoverLetterPersistenceDatasource persistenceDatasource,
  }) : _remoteDatasource = remoteDatasource,
       _analysisRemoteDatasource = analysisRemoteDatasource,
       _persistenceDatasource = persistenceDatasource;

  final CoverLetterRemoteDatasource _remoteDatasource;
  final CoverLetterAnalysisRemoteDatasource _analysisRemoteDatasource;
  final CoverLetterPersistenceDatasource _persistenceDatasource;

  @override
  Future<CoverLetterResult> generateCoverLetter(
    CoverLetterRequest request,
  ) async {
    final requestModel = CoverLetterRequestModel.fromEntity(request);
    final enrichedRequest = await _buildEnrichedRequest(request, requestModel);

    return _remoteDatasource.generateCoverLetter(
      CoverLetterRequestModel.fromEntity(enrichedRequest),
    );
  }

  Future<CoverLetterRequest> _buildEnrichedRequest(
    CoverLetterRequest request,
    CoverLetterRequestModel requestModel,
  ) async {
    final hasJobContext = request.jobContext != null;
    final hasCandidateContext = request.candidateContext != null;

    if (!hasJobContext || !hasCandidateContext) {
      return request;
    }

    final fitAnalysis = await _analysisRemoteDatasource.analyzeFit(
      requestModel,
    );
    return request.copyWith(fitAnalysis: fitAnalysis);
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
