class VideoScript {
  final String id;
  final String durationType; // '30s', '60s', '90s'
  final String scriptText;
  final String tone; // 'formal', 'casual', 'confident'
  final String? applicationId; // linked JobApplication id
  final DateTime createdAt;

  const VideoScript({
    required this.id,
    required this.durationType,
    required this.scriptText,
    required this.tone,
    this.applicationId,
    required this.createdAt,
  });

  VideoScript copyWith({String? scriptText, String? tone}) => VideoScript(
    id: id,
    durationType: durationType,
    scriptText: scriptText ?? this.scriptText,
    tone: tone ?? this.tone,
    applicationId: applicationId,
    createdAt: createdAt,
  );
}
