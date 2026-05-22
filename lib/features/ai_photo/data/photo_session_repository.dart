import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/photo_session.dart';

class PhotoSessionRepository extends Notifier<List<PhotoSession>> {
  @override
  List<PhotoSession> build() => [];

  void save(PhotoSession session) {
    state = [session, ...state];
  }

  void delete(String id) {
    state = state.where((s) => s.id != id).toList();
  }

  void clear() => state = [];
}

final photoSessionRepositoryProvider =
    NotifierProvider<PhotoSessionRepository, List<PhotoSession>>(
      PhotoSessionRepository.new,
    );
