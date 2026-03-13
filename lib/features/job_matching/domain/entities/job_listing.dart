class JobListing {
  const JobListing({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.source,
    required this.url,
    required this.jobDescription,
  });

  final String id;
  final String title;
  final String company;
  final String location;
  final String source;
  final String url;
  final String jobDescription;
}
