import '../../domain/entities/cover_letter_result.dart';

class CoverLetterResultModel extends CoverLetterResult {
  const CoverLetterResultModel({required super.coverLetter});

  factory CoverLetterResultModel.fromJson(Map<String, dynamic> json) {
    return CoverLetterResultModel(
      coverLetter: json['cover_letter'] as String? ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'cover_letter': coverLetter};
  }
}
