import '../models/job_listing_model.dart';
import '../models/job_search_request_model.dart';

class JobMatchingSeededDatasource {
  const JobMatchingSeededDatasource();

  Future<List<JobListingModel>> searchJobs(
    JobSearchRequestModel request,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    final normalizedRole = request.role.trim();
    final normalizedLocation = request.location.trim();
    final skills = request.skills
        .where((skill) => skill.trim().isNotEmpty)
        .toList(growable: false);
    final leadingSkill = skills.isEmpty
        ? 'cross-functional collaboration'
        : skills.first;
    final secondarySkill = skills.length > 1 ? skills[1] : 'product thinking';

    final seededJobs = <Map<String, dynamic>>[
      {
        'id': 'job-1',
        'title': normalizedRole.isEmpty
            ? 'Senior Product Designer'
            : normalizedRole,
        'company': 'Northstar Labs',
        'location': normalizedLocation.isEmpty ? 'Remote' : normalizedLocation,
        'source': 'LinkedIn',
        'url':
            'https://jobs.example.com/northstar-labs/${_slugify(normalizedRole.isEmpty ? 'senior-product-designer' : normalizedRole)}',
        'job_description':
            'Northstar Labs is hiring a ${normalizedRole.isEmpty ? 'Senior Product Designer' : normalizedRole} to lead high-impact product work. The role values ${leadingSkill.toLowerCase()}, strong stakeholder communication, and measurable delivery across teams. Candidates with roughly ${request.yearsExperience <= 0 ? 3 : request.yearsExperience} or more years of experience are preferred.',
      },
      {
        'id': 'job-2',
        'title': normalizedRole.isEmpty
            ? 'Product Designer, Growth'
            : '$normalizedRole, Growth',
        'company': 'Orbit Commerce',
        'location': normalizedLocation.isEmpty ? 'Hybrid' : normalizedLocation,
        'source': 'Indeed',
        'url':
            'https://jobs.example.com/orbit-commerce/${_slugify(normalizedRole.isEmpty ? 'product-designer-growth' : '$normalizedRole growth')}',
        'job_description':
            'Orbit Commerce is looking for a ${normalizedRole.isEmpty ? 'Product Designer' : normalizedRole} to improve acquisition and activation funnels. You will work across experimentation, research, and design systems, with emphasis on ${secondarySkill.toLowerCase()} and shipping polished product experiences.',
      },
      {
        'id': 'job-3',
        'title': normalizedRole.isEmpty
            ? 'Lead Product Designer'
            : 'Lead $normalizedRole',
        'company': 'Atlas B2B',
        'location': normalizedLocation.isEmpty
            ? 'London or Remote'
            : normalizedLocation,
        'source': 'Wellfound',
        'url':
            'https://jobs.example.com/atlas-b2b/${_slugify(normalizedRole.isEmpty ? 'lead-product-designer' : 'lead $normalizedRole')}',
        'job_description':
            'Atlas B2B needs a senior individual contributor who can guide end-to-end product decisions, mentor peers, and partner closely with engineering. Experience with ${skills.isEmpty ? 'complex B2B workflows' : skills.take(2).join(' and ').toLowerCase()} is a strong plus.',
      },
      {
        'id': 'job-4',
        'title': normalizedRole.isEmpty
            ? 'Staff Product Designer'
            : 'Staff $normalizedRole',
        'company': 'Cedar Health',
        'location': normalizedLocation.isEmpty
            ? 'New York, NY'
            : normalizedLocation,
        'source': 'Company Site',
        'url':
            'https://jobs.example.com/cedar-health/${_slugify(normalizedRole.isEmpty ? 'staff-product-designer' : 'staff $normalizedRole')}',
        'job_description':
            'Cedar Health is growing its product design team and needs a ${normalizedRole.isEmpty ? 'Staff Product Designer' : 'Staff $normalizedRole'} to simplify high-stakes user journeys. The role favors strong systems thinking, communication, and evidence-based decision making.',
      },
      {
        'id': 'job-5',
        'title': normalizedRole.isEmpty
            ? 'Principal Product Designer'
            : 'Principal $normalizedRole',
        'company': 'Helix AI',
        'location': normalizedLocation.isEmpty
            ? 'San Francisco, CA'
            : normalizedLocation,
        'source': 'Greenhouse',
        'url':
            'https://jobs.example.com/helix-ai/${_slugify(normalizedRole.isEmpty ? 'principal-product-designer' : 'principal $normalizedRole')}',
        'job_description':
            'Helix AI is hiring a high-leverage ${normalizedRole.isEmpty ? 'Principal Product Designer' : 'Principal $normalizedRole'} to shape AI-assisted workflows. We value ownership, strategic product thinking, and comfort translating ambiguous technical problems into user-facing solutions.',
      },
    ];

    return seededJobs.map(JobListingModel.fromMap).toList(growable: false);
  }

  String _slugify(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }
}
