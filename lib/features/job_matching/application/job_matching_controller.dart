import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../data/datasources/job_matching_seeded_datasource.dart';
import '../data/repositories/job_matching_repository_impl.dart';
import '../domain/entities/job_listing.dart';
import '../domain/entities/job_search_request.dart';
import '../domain/repositories/job_matching_repository.dart';
import 'job_matching_state.dart';

final jobMatchingDatasourceProvider = Provider<JobMatchingSeededDatasource>(
  (ref) => const JobMatchingSeededDatasource(),
);

final jobMatchingRepositoryProvider = Provider<JobMatchingRepository>(
  (ref) => JobMatchingRepositoryImpl(
    datasource: ref.watch(jobMatchingDatasourceProvider),
  ),
);

final jobMatchingControllerProvider =
    NotifierProvider<JobMatchingController, JobMatchingState>(
      JobMatchingController.new,
    );

class JobMatchingController extends Notifier<JobMatchingState> {
  @override
  JobMatchingState build() => const JobMatchingState();

  Future<void> searchJobs(JobSearchRequest request) async {
    if (state.isLoading) {
      return;
    }

    state = state.copyWith(
      isLoading: true,
      hasSearched: true,
      request: request,
      clearError: true,
    );

    try {
      final jobs = await ref
          .read(jobMatchingRepositoryProvider)
          .searchJobs(request);
      state = state.copyWith(
        isLoading: false,
        jobs: jobs,
        request: request,
        clearError: true,
      );
    } on AppException catch (error) {
      state = state.copyWith(
        isLoading: false,
        jobs: const <JobListing>[],
        errorMessage: error.message,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        jobs: const <JobListing>[],
        errorMessage:
            'Job matches could not be loaded right now. Please try again.',
      );
    }
  }
}
