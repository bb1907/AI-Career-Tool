import '../../domain/entities/job_listing.dart';

class JobListingModel extends JobListing {
  const JobListingModel({
    required super.id,
    required super.title,
    required super.company,
    required super.location,
    required super.source,
    required super.url,
    required super.jobDescription,
  });

  factory JobListingModel.fromMap(Map<String, dynamic> json) {
    return JobListingModel(
      id: json['id'] as String,
      title: json['title'] as String,
      company: json['company'] as String,
      location: json['location'] as String,
      source: json['source'] as String,
      url: json['url'] as String,
      jobDescription: json['job_description'] as String,
    );
  }
}
