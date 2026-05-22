class ParsedProfile {
  final List<String> skills;
  final List<String> experiences; // summary strings
  final List<String> education;
  final String? summary;

  const ParsedProfile({
    required this.skills,
    required this.experiences,
    required this.education,
    this.summary,
  });
}

class UploadedCV {
  final String id;
  final String fileName;
  final String parsedText;
  final ParsedProfile parsedProfile;
  final DateTime createdAt;

  const UploadedCV({
    required this.id,
    required this.fileName,
    required this.parsedText,
    required this.parsedProfile,
    required this.createdAt,
  });
}
