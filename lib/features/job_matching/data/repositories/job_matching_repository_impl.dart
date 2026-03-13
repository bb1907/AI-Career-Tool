import '../../domain/entities/job_listing.dart';
import '../../domain/entities/job_search_request.dart';
import '../../domain/repositories/job_matching_repository.dart';
import '../datasources/job_matching_seeded_datasource.dart';
import '../models/job_search_request_model.dart';

class JobMatchingRepositoryImpl implements JobMatchingRepository {
  const JobMatchingRepositoryImpl({required this.datasource});

  final JobMatchingSeededDatasource datasource;

  @override
  Future<List<JobListing>> searchJobs(JobSearchRequest request) {
    return datasource.searchJobs(JobSearchRequestModel.fromEntity(request));
  }
}
