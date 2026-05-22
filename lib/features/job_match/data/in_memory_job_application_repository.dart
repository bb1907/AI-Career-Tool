import '../domain/job_application.dart';

class InMemoryJobApplicationRepository {
  final List<JobApplication> _items = [];

  List<JobApplication> getAll() => List.unmodifiable(_items);

  void save(JobApplication app) {
    final idx = _items.indexWhere((e) => e.id == app.id);
    if (idx >= 0) {
      _items[idx] = app;
    } else {
      _items.insert(0, app);
    }
  }

  void delete(String id) => _items.removeWhere((e) => e.id == id);
}
