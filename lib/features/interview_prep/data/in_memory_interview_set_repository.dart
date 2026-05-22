import '../domain/interview_set.dart';

class InMemoryInterviewSetRepository {
  final List<InterviewSet> _items = [];

  List<InterviewSet> getAll() => List.unmodifiable(_items);

  void save(InterviewSet set) {
    final idx = _items.indexWhere((e) => e.id == set.id);
    if (idx >= 0) {
      _items[idx] = set;
    } else {
      _items.insert(0, set);
    }
  }

  void delete(String id) => _items.removeWhere((e) => e.id == id);
}
