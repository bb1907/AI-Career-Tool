import '../domain/video_script.dart';

class InMemoryVideoScriptRepository {
  final List<VideoScript> _items = [];

  List<VideoScript> getAll() => List.unmodifiable(_items);

  void save(VideoScript script) {
    final idx = _items.indexWhere((e) => e.id == script.id);
    if (idx >= 0) {
      _items[idx] = script;
    } else {
      _items.insert(0, script);
    }
  }

  void delete(String id) => _items.removeWhere((e) => e.id == id);
}
