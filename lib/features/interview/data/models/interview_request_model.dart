import '../../domain/entities/interview_request.dart';

class InterviewRequestModel {
  const InterviewRequestModel({
    required this.roleName,
    required this.seniority,
    required this.companyType,
    required this.interviewType,
    required this.focusAreas,
  });

  final String roleName;
  final String seniority;
  final String companyType;
  final String interviewType;
  final List<String> focusAreas;

  factory InterviewRequestModel.fromEntity(InterviewRequest request) {
    return InterviewRequestModel(
      roleName: request.roleName,
      seniority: request.seniority,
      companyType: request.companyType,
      interviewType: request.interviewType,
      focusAreas: request.focusAreas,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role_name': roleName,
      'seniority': seniority,
      'company_type': companyType,
      'interview_type': interviewType,
      'focus_areas': focusAreas,
    };
  }
}
