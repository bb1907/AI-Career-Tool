import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/recorded_video.dart';
import '../../data/in_memory_recorded_video_repository.dart';

final _repo = InMemoryRecordedVideoRepository();

class RecordedVideoNotifier extends Notifier<List<RecordedVideo>> {
  @override
  List<RecordedVideo> build() => _repo.getAll();

  void save(RecordedVideo video) {
    _repo.save(video);
    state = _repo.getAll();
  }

  void delete(String id) {
    _repo.delete(id);
    state = _repo.getAll();
  }
}

final recordedVideoListProvider =
    NotifierProvider<RecordedVideoNotifier, List<RecordedVideo>>(
      RecordedVideoNotifier.new,
    );
