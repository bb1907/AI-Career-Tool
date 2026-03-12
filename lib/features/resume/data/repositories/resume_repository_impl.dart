import '../../domain/entities/resume_request.dart';
import '../../domain/entities/resume_result.dart';
import '../../domain/repositories/resume_repository.dart';
import '../datasources/resume_local_datasource.dart';
import '../datasources/resume_remote_datasource.dart';
import '../models/resume_request_model.dart';
import '../models/resume_result_model.dart';

class ResumeRepositoryImpl implements ResumeRepository {
  ResumeRepositoryImpl({
    required ResumeRemoteDatasource remoteDatasource,
    required ResumeLocalDatasource localDatasource,
  }) : _remoteDatasource = remoteDatasource,
       _localDatasource = localDatasource;

  final ResumeRemoteDatasource _remoteDatasource;
  final ResumeLocalDatasource _localDatasource;

  @override
  Future<ResumeResult> generateResume(ResumeRequest request) async {
    return _remoteDatasource.generateResume(
      ResumeRequestModel.fromEntity(request),
    );
  }

  @override
  Future<void> saveResume(ResumeResult result) async {
    await _localDatasource.save(
      ResumeResultModel(
        summary: result.summary,
        experienceBullets: result.experienceBullets,
        skills: result.skills,
        education: result.education,
      ),
    );
  }

  @override
  Future<List<ResumeResult>> fetchHistory() async {
    return _localDatasource.fetchHistory();
  }
}
