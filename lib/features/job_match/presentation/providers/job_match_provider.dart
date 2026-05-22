import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/job_application.dart';
import '../../data/in_memory_job_application_repository.dart';

final _repo = InMemoryJobApplicationRepository();

class JobApplicationNotifier extends Notifier<List<JobApplication>> {
  @override
  List<JobApplication> build() => _repo.getAll();

  void save(JobApplication app) {
    _repo.save(app);
    state = _repo.getAll();
  }

  void delete(String id) {
    _repo.delete(id);
    state = _repo.getAll();
  }
}

final jobApplicationListProvider =
    NotifierProvider<JobApplicationNotifier, List<JobApplication>>(
      JobApplicationNotifier.new,
    );
