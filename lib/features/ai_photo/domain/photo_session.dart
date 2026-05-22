import 'dart:typed_data';

class PhotoSession {
  final String id;
  final String originalImagePath;
  final Uint8List resultImageBytes;
  final String jobType;
  final String outfitDescription;
  final int qualityScore;
  final DateTime createdAt;
  final bool isPremium; // false = watermarked

  const PhotoSession({
    required this.id,
    required this.originalImagePath,
    required this.resultImageBytes,
    required this.jobType,
    required this.outfitDescription,
    required this.qualityScore,
    required this.createdAt,
    this.isPremium = false,
  });
}
