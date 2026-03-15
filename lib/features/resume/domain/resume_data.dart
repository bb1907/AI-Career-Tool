class PersonalInfo {
  final String name;
  final String email;
  final String phone;
  final String location;
  final String linkedin;

  const PersonalInfo({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.location = '',
    this.linkedin = '',
  });

  PersonalInfo copyWith({
    String? name,
    String? email,
    String? phone,
    String? location,
    String? linkedin,
  }) => PersonalInfo(
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        location: location ?? this.location,
        linkedin: linkedin ?? this.linkedin,
      );
}

class WorkEntry {
  final String company;
  final String title;
  final String startDate;
  final String endDate;
  final String bullets;

  const WorkEntry({
    this.company = '',
    this.title = '',
    this.startDate = '',
    this.endDate = '',
    this.bullets = '',
  });

  WorkEntry copyWith({
    String? company,
    String? title,
    String? startDate,
    String? endDate,
    String? bullets,
  }) => WorkEntry(
        company: company ?? this.company,
        title: title ?? this.title,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        bullets: bullets ?? this.bullets,
      );
}

class EducationEntry {
  final String school;
  final String degree;
  final String year;

  const EducationEntry({this.school = '', this.degree = '', this.year = ''});

  EducationEntry copyWith({String? school, String? degree, String? year}) =>
      EducationEntry(
        school: school ?? this.school,
        degree: degree ?? this.degree,
        year: year ?? this.year,
      );
}

class ProjectEntry {
  final String name;
  final String description;
  final String url;

  const ProjectEntry({this.name = '', this.description = '', this.url = ''});

  ProjectEntry copyWith({String? name, String? description, String? url}) =>
      ProjectEntry(
        name: name ?? this.name,
        description: description ?? this.description,
        url: url ?? this.url,
      );
}

class ResumeData {
  final PersonalInfo personalInfo;
  final String summary;
  final List<WorkEntry> workExperience;
  final List<EducationEntry> education;
  final List<String> skills;
  final List<ProjectEntry> projects;

  const ResumeData({
    this.personalInfo = const PersonalInfo(),
    this.summary = '',
    this.workExperience = const [],
    this.education = const [],
    this.skills = const [],
    this.projects = const [],
  });

  ResumeData copyWith({
    PersonalInfo? personalInfo,
    String? summary,
    List<WorkEntry>? workExperience,
    List<EducationEntry>? education,
    List<String>? skills,
    List<ProjectEntry>? projects,
  }) => ResumeData(
        personalInfo: personalInfo ?? this.personalInfo,
        summary: summary ?? this.summary,
        workExperience: workExperience ?? this.workExperience,
        education: education ?? this.education,
        skills: skills ?? this.skills,
        projects: projects ?? this.projects,
      );
}
