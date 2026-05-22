class PersonalInfo {
  final String fullName;
  final String email;
  final String phone;
  final String location;
  final String? linkedIn;
  final String? website;

  const PersonalInfo({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.location,
    this.linkedIn,
    this.website,
  });

  PersonalInfo copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? location,
    String? linkedIn,
    String? website,
  }) => PersonalInfo(
    fullName: fullName ?? this.fullName,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    location: location ?? this.location,
    linkedIn: linkedIn ?? this.linkedIn,
    website: website ?? this.website,
  );
}

class WorkExperience {
  final String id;
  final String company;
  final String position;
  final String startDate;
  final String? endDate;
  final bool isCurrent;
  final String description;

  const WorkExperience({
    required this.id,
    required this.company,
    required this.position,
    required this.startDate,
    this.endDate,
    this.isCurrent = false,
    required this.description,
  });

  WorkExperience copyWith({
    String? id,
    String? company,
    String? position,
    String? startDate,
    String? endDate,
    bool? isCurrent,
    String? description,
  }) => WorkExperience(
    id: id ?? this.id,
    company: company ?? this.company,
    position: position ?? this.position,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    isCurrent: isCurrent ?? this.isCurrent,
    description: description ?? this.description,
  );
}

class Education {
  final String id;
  final String institution;
  final String degree;
  final String field;
  final String startDate;
  final String? endDate;
  final String? gpa;

  const Education({
    required this.id,
    required this.institution,
    required this.degree,
    required this.field,
    required this.startDate,
    this.endDate,
    this.gpa,
  });

  Education copyWith({
    String? id,
    String? institution,
    String? degree,
    String? field,
    String? startDate,
    String? endDate,
    String? gpa,
  }) => Education(
    id: id ?? this.id,
    institution: institution ?? this.institution,
    degree: degree ?? this.degree,
    field: field ?? this.field,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    gpa: gpa ?? this.gpa,
  );
}

class Skill {
  final String id;
  final String name;
  final String category; // 'technical', 'soft', 'language'
  final int level; // 1-5

  const Skill({
    required this.id,
    required this.name,
    required this.category,
    this.level = 3,
  });
}

class Project {
  final String id;
  final String name;
  final String description;
  final String? url;
  final List<String> technologies;

  const Project({
    required this.id,
    required this.name,
    required this.description,
    this.url,
    this.technologies = const [],
  });

  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? url,
    List<String>? technologies,
  }) => Project(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    url: url ?? this.url,
    technologies: technologies ?? this.technologies,
  );
}

class Resume {
  final String id;
  final String title;
  final PersonalInfo personalInfo;
  final String summary;
  final List<WorkExperience> workExperiences;
  final List<Education> educations;
  final List<Skill> skills;
  final List<Project> projects;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Resume({
    required this.id,
    required this.title,
    required this.personalInfo,
    required this.summary,
    required this.workExperiences,
    required this.educations,
    required this.skills,
    required this.projects,
    required this.createdAt,
    required this.updatedAt,
  });

  double get completionPercentage {
    int filled = 0;
    int total = 6;
    if (personalInfo.fullName.isNotEmpty) filled++;
    if (summary.isNotEmpty) filled++;
    if (workExperiences.isNotEmpty) filled++;
    if (educations.isNotEmpty) filled++;
    if (skills.isNotEmpty) filled++;
    if (projects.isNotEmpty) filled++;
    return filled / total;
  }

  Resume copyWith({
    String? id,
    String? title,
    PersonalInfo? personalInfo,
    String? summary,
    List<WorkExperience>? workExperiences,
    List<Education>? educations,
    List<Skill>? skills,
    List<Project>? projects,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Resume(
    id: id ?? this.id,
    title: title ?? this.title,
    personalInfo: personalInfo ?? this.personalInfo,
    summary: summary ?? this.summary,
    workExperiences: workExperiences ?? this.workExperiences,
    educations: educations ?? this.educations,
    skills: skills ?? this.skills,
    projects: projects ?? this.projects,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
