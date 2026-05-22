import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/video_script.dart';
import '../../data/in_memory_video_script_repository.dart';

final _repo = InMemoryVideoScriptRepository();

class VideoScriptNotifier extends Notifier<List<VideoScript>> {
  @override
  List<VideoScript> build() => _repo.getAll();

  void save(VideoScript script) {
    _repo.save(script);
    state = _repo.getAll();
  }

  void delete(String id) {
    _repo.delete(id);
    state = _repo.getAll();
  }
}

final videoScriptListProvider =
    NotifierProvider<VideoScriptNotifier, List<VideoScript>>(
      VideoScriptNotifier.new,
    );
