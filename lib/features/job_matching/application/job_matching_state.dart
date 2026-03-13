import '../domain/entities/job_listing.dart';
import '../domain/entities/job_search_request.dart';

class JobMatchingState {
  const JobMatchingState({
    this.isLoading = false,
    this.hasSearched = false,
    this.jobs = const <JobListing>[],
    this.request,
    this.errorMessage,
  });

  final bool isLoading;
  final bool hasSearched;
  final List<JobListing> jobs;
  final JobSearchRequest? request;
  final String? errorMessage;

  bool get isEmpty => hasSearched && jobs.isEmpty;

  JobMatchingState copyWith({
    bool? isLoading,
    bool? hasSearched,
    List<JobListing>? jobs,
    JobSearchRequest? request,
    String? errorMessage,
    bool clearError = false,
  }) {
    return JobMatchingState(
      isLoading: isLoading ?? this.isLoading,
      hasSearched: hasSearched ?? this.hasSearched,
      jobs: jobs ?? this.jobs,
      request: request ?? this.request,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
