class CoverLetterResult {
  const CoverLetterResult({required this.coverLetter, this.createdAt});

  final String coverLetter;
  final DateTime? createdAt;

  factory CoverLetterResult.fromJson(Map<String, dynamic> json) {
    return CoverLetterResult(
      coverLetter: json['cover_letter'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {'cover_letter': coverLetter};

    if (createdAt != null) {
      json['created_at'] = createdAt!.toIso8601String();
    }

    return json;
  }

  CoverLetterResult copyWith({String? coverLetter, DateTime? createdAt}) {
    return CoverLetterResult(
      coverLetter: coverLetter ?? this.coverLetter,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
