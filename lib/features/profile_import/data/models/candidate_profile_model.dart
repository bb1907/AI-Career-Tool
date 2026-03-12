import '../../domain/entities/candidate_profile.dart';

class CandidateProfileModel extends CandidateProfile {
  const CandidateProfileModel({
    required super.name,
    required super.email,
    required super.location,
    required super.yearsExperience,
    required super.roles,
    required super.skills,
    required super.industries,
    required super.seniority,
    required super.education,
  });

  factory CandidateProfileModel.fromJson(Map<String, dynamic> json) {
    return CandidateProfileModel(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      location: json['location'] as String? ?? '',
      yearsExperience:
          json['years_experience'] as int? ??
          int.tryParse(json['years_experience']?.toString() ?? '') ??
          0,
      roles: (json['roles'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(growable: false),
      skills: (json['skills'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(growable: false),
      industries: (json['industries'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(growable: false),
      seniority: json['seniority'] as String? ?? '',
      education: json['education'] as String? ?? '',
    );
  }

  factory CandidateProfileModel.fromEntity(CandidateProfile profile) {
    return CandidateProfileModel(
      name: profile.name,
      email: profile.email,
      location: profile.location,
      yearsExperience: profile.yearsExperience,
      roles: profile.roles,
      skills: profile.skills,
      industries: profile.industries,
      seniority: profile.seniority,
      education: profile.education,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'location': location,
      'years_experience': yearsExperience,
      'roles': roles,
      'skills': skills,
      'industries': industries,
      'seniority': seniority,
      'education': education,
    };
  }

  Map<String, dynamic> toDatabaseJson({
    required String uploadedCvId,
    required String userId,
  }) {
    return {
      'uploaded_cv_id': uploadedCvId,
      'user_id': userId,
      'name': name,
      'email': email,
      'location': location,
      'years_experience': yearsExperience,
      'roles': roles,
      'skills': skills,
      'industries': industries,
      'seniority': seniority,
      'education': education,
    };
  }
}
