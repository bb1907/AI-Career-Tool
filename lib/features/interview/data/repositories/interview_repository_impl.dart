import '../../domain/entities/interview_request.dart';
import '../../domain/entities/interview_result.dart';
import '../../domain/repositories/interview_repository.dart';
import '../datasources/interview_persistence_datasource.dart';
import '../datasources/interview_remote_datasource.dart';
import '../models/interview_request_model.dart';
import '../models/interview_result_model.dart';

class InterviewRepositoryImpl implements InterviewRepository {
  InterviewRepositoryImpl({
    required InterviewRemoteDatasource remoteDatasource,
    required InterviewPersistenceDatasource persistenceDatasource,
  }) : _remoteDatasource = remoteDatasource,
       _persistenceDatasource = persistenceDatasource;

  final InterviewRemoteDatasource _remoteDatasource;
  final InterviewPersistenceDatasource _persistenceDatasource;

  @override
  Future<InterviewResult> generateInterviewPrep(
    InterviewRequest request,
  ) async {
    return _remoteDatasource.generateInterviewPrep(
      InterviewRequestModel.fromEntity(request),
    );
  }

  @override
  Future<void> saveInterviewPrep(InterviewResult result) async {
    await _persistenceDatasource.save(
      InterviewResultModel(
        technicalQuestions: result.technicalQuestions,
        behavioralQuestions: result.behavioralQuestions,
      ),
    );
  }

  @override
  Future<List<InterviewResult>> fetchHistory() async {
    return _persistenceDatasource.fetchHistory();
  }
}
