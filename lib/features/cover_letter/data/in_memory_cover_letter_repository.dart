import '../domain/cover_letter.dart';

class InMemoryCoverLetterRepository {
  final List<CoverLetter> _items = [];

  List<CoverLetter> getAll() => List.unmodifiable(_items);

  void save(CoverLetter cl) {
    final idx = _items.indexWhere((e) => e.id == cl.id);
    if (idx >= 0) {
      _items[idx] = cl;
    } else {
      _items.insert(0, cl);
    }
  }

  void delete(String id) => _items.removeWhere((e) => e.id == id);
}
