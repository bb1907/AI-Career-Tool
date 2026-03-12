class CoverLetterResult {
  const CoverLetterResult({required this.coverLetter});

  final String coverLetter;

  factory CoverLetterResult.fromJson(Map<String, dynamic> json) {
    return CoverLetterResult(
      coverLetter: json['cover_letter'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'cover_letter': coverLetter};
  }

  CoverLetterResult copyWith({String? coverLetter}) {
    return CoverLetterResult(coverLetter: coverLetter ?? this.coverLetter);
  }
}
