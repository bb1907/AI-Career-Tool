import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/interview_set.dart';
import '../../data/in_memory_interview_set_repository.dart';

final _repo = InMemoryInterviewSetRepository();

class InterviewSetNotifier extends Notifier<List<InterviewSet>> {
  @override
  List<InterviewSet> build() => _repo.getAll();

  void save(InterviewSet set) {
    _repo.save(set);
    state = _repo.getAll();
  }

  void delete(String id) {
    _repo.delete(id);
    state = _repo.getAll();
  }
}

final interviewSetListProvider =
    NotifierProvider<InterviewSetNotifier, List<InterviewSet>>(
      InterviewSetNotifier.new,
    );
