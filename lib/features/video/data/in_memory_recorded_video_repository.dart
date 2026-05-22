import '../domain/recorded_video.dart';

class InMemoryRecordedVideoRepository {
  final List<RecordedVideo> _items = [];

  List<RecordedVideo> getAll() => List.unmodifiable(_items);

  void save(RecordedVideo video) {
    final idx = _items.indexWhere((e) => e.id == video.id);
    if (idx >= 0) {
      _items[idx] = video;
    } else {
      _items.insert(0, video);
    }
  }

  void delete(String id) => _items.removeWhere((e) => e.id == id);
}
