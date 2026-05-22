class UsageEvent {
  final String id;
  final String
  toolType; // 'cover_letter', 'interview', 'resume_summary', 'video_script'
  final int creditsUsed;
  final DateTime createdAt;

  const UsageEvent({
    required this.id,
    required this.toolType,
    required this.creditsUsed,
    required this.createdAt,
  });
}
