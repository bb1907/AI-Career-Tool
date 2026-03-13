import '../entities/job_listing.dart';
import '../entities/job_search_request.dart';

abstract class JobMatchingRepository {
  Future<List<JobListing>> searchJobs(JobSearchRequest request);
}
