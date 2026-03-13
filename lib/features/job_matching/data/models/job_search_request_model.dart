import '../../domain/entities/job_search_request.dart';

class JobSearchRequestModel extends JobSearchRequest {
  const JobSearchRequestModel({
    required super.role,
    required super.location,
    required super.yearsExperience,
    super.skills,
  });

  factory JobSearchRequestModel.fromEntity(JobSearchRequest request) {
    return JobSearchRequestModel(
      role: request.role,
      location: request.location,
      yearsExperience: request.yearsExperience,
      skills: request.skills,
    );
  }
}
