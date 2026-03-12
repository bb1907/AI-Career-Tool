import '../../domain/entities/cover_letter_request.dart';

class CoverLetterRequestModel {
  const CoverLetterRequestModel({
    required this.companyName,
    required this.roleTitle,
    required this.jobDescription,
    required this.userBackground,
    required this.tone,
  });

  final String companyName;
  final String roleTitle;
  final String jobDescription;
  final String userBackground;
  final String tone;

  factory CoverLetterRequestModel.fromEntity(CoverLetterRequest request) {
    return CoverLetterRequestModel(
      companyName: request.companyName,
      roleTitle: request.roleTitle,
      jobDescription: request.jobDescription,
      userBackground: request.userBackground,
      tone: request.tone,
    );
  }

  CoverLetterRequest toEntity() {
    return CoverLetterRequest(
      companyName: companyName,
      roleTitle: roleTitle,
      jobDescription: jobDescription,
      userBackground: userBackground,
      tone: tone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company_name': companyName,
      'role_title': roleTitle,
      'job_description': jobDescription,
      'user_background': userBackground,
      'tone': tone,
    };
  }
}
