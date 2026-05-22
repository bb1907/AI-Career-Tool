import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/cover_letter.dart';
import '../../data/in_memory_cover_letter_repository.dart';

final _repo = InMemoryCoverLetterRepository();

class CoverLetterNotifier extends Notifier<List<CoverLetter>> {
  @override
  List<CoverLetter> build() => _repo.getAll();

  void save(CoverLetter cl) {
    _repo.save(cl);
    state = _repo.getAll();
  }

  void delete(String id) {
    _repo.delete(id);
    state = _repo.getAll();
  }
}

final coverLetterListProvider =
    NotifierProvider<CoverLetterNotifier, List<CoverLetter>>(
      CoverLetterNotifier.new,
    );
