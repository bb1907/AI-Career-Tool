import '../entities/history_snapshot.dart';

abstract class HistoryRepository {
  Future<HistorySnapshot> fetchHistory();
}
