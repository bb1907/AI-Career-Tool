import '../domain/entities/candidate_profile.dart';

class ResumePrefillData {
  const ResumePrefillData({
    required this.targetRole,
    required this.yearsOfExperience,
    required this.pastRoles,
    required this.topSkills,
    required this.education,
  });

  final String targetRole;
  final String yearsOfExperience;
  final String pastRoles;
  final String topSkills;
  final String education;
}

class CoverLetterPrefillData {
  const CoverLetterPrefillData({
    required this.roleTitle,
    required this.userBackground,
  });

  final String roleTitle;
  final String userBackground;
}

class InterviewPrefillData {
  const InterviewPrefillData({
    required this.roleName,
    required this.seniority,
    required this.focusAreas,
  });

  final String roleName;
  final String seniority;
  final String focusAreas;
}

abstract final class CandidateProfilePrefill {
  static ResumePrefillData forResume(CandidateProfile profile) {
    return ResumePrefillData(
      targetRole: _firstOrEmpty(profile.roles),
      yearsOfExperience: profile.yearsExperience > 0
          ? profile.yearsExperience.toString()
          : '',
      pastRoles: profile.roles.join('\n'),
      topSkills: profile.skills.join(', '),
      education: profile.education,
    );
  }

  static CoverLetterPrefillData forCoverLetter(CandidateProfile profile) {
    final backgroundSegments = <String>[
      if (profile.seniority.isNotEmpty || profile.yearsExperience > 0)
        [
          if (profile.seniority.isNotEmpty) profile.seniority,
          if (profile.yearsExperience > 0)
            '${profile.yearsExperience} years of experience',
        ].join(' professional with '),
      if (profile.roles.isNotEmpty)
        'Experience across ${profile.roles.join(', ')}.',
      if (profile.skills.isNotEmpty)
        'Core strengths include ${profile.skills.join(', ')}.',
      if (profile.industries.isNotEmpty)
        'Industry exposure includes ${profile.industries.join(', ')}.',
      if (profile.location.isNotEmpty) 'Based in ${profile.location}.',
      if (profile.education.isNotEmpty) 'Education: ${profile.education}.',
    ];

    return CoverLetterPrefillData(
      roleTitle: _firstOrEmpty(profile.roles),
      userBackground: backgroundSegments.join(' ').trim(),
    );
  }

  static InterviewPrefillData forInterview(CandidateProfile profile) {
    final focusAreas = <String>{
      ...profile.skills,
      ...profile.industries,
    }.where((item) => item.trim().isNotEmpty).toList(growable: false);

    return InterviewPrefillData(
      roleName: _firstOrEmpty(profile.roles),
      seniority: _normalizeSeniority(profile.seniority),
      focusAreas: focusAreas.join(', '),
    );
  }

  static String _firstOrEmpty(List<String> values) {
    if (values.isEmpty) {
      return '';
    }

    return values.first.trim();
  }

  static String _normalizeSeniority(String seniority) {
    final normalized = seniority.trim().toLowerCase();

    return switch (normalized) {
      'junior' => 'Junior',
      'mid' || 'mid-level' || 'mid level' => 'Mid-level',
      'senior' => 'Senior',
      'lead' || 'principal' || 'staff' => 'Lead',
      _ => seniority.trim(),
    };
  }
}
