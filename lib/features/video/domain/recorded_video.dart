class RecordedVideo {
  final String id;
  final String? scriptId;
  final String localPath;
  final String? thumbnailPath;
  final int durationSeconds;
  final DateTime createdAt;

  const RecordedVideo({
    required this.id,
    this.scriptId,
    required this.localPath,
    this.thumbnailPath,
    required this.durationSeconds,
    required this.createdAt,
  });
}
