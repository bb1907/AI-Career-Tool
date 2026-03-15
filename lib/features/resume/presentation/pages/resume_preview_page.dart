import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/resume_data.dart';
import '../providers/resume_provider.dart';

class ResumePreviewPage extends ConsumerWidget {
  const ResumePreviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resume = ref.watch(resumeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CV Preview'),
        leading: BackButton(onPressed: () => context.go('/resume/wizard')),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () => context.go('/resume/wizard'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(resume.personalInfo),
                if (resume.summary.isNotEmpty) ...[
                  _sectionTitle(context, 'Summary'),
                  Text(resume.summary),
                  const Divider(height: 32),
                ],
                if (resume.workExperience.isNotEmpty) ...[
                  _sectionTitle(context, 'Work Experience'),
                  ...resume.workExperience.map((w) => _WorkCard(w)),
                  const Divider(height: 32),
                ],
                if (resume.education.isNotEmpty) ...[
                  _sectionTitle(context, 'Education'),
                  ...resume.education.map((e) => _EduCard(e)),
                  const Divider(height: 32),
                ],
                if (resume.skills.isNotEmpty) ...[
                  _sectionTitle(context, 'Skills'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: resume.skills
                        .map((s) => Chip(label: Text(s)))
                        .toList(),
                  ),
                  const Divider(height: 32),
                ],
                if (resume.projects.isNotEmpty) ...[
                  _sectionTitle(context, 'Projects'),
                  ...resume.projects.map((p) => _ProjectCard(p)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: Theme.of(context).colorScheme.primary),
        ),
      );
}

class _Header extends StatelessWidget {
  final PersonalInfo info;
  const _Header(this.info);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          info.name.isEmpty ? 'Your Name' : info.name,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 16,
          children: [
            if (info.email.isNotEmpty) _icon(Icons.email, info.email),
            if (info.phone.isNotEmpty) _icon(Icons.phone, info.phone),
            if (info.location.isNotEmpty)
              _icon(Icons.location_on, info.location),
            if (info.linkedin.isNotEmpty) _icon(Icons.link, info.linkedin),
          ],
        ),
        const Divider(height: 32),
      ],
    );
  }

  Widget _icon(IconData icon, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 13)),
        ],
      );
}

class _WorkCard extends StatelessWidget {
  final WorkEntry work;
  const _WorkCard(this.work);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(work.title,
                  style: Theme.of(context).textTheme.titleSmall),
              if (work.startDate.isNotEmpty || work.endDate.isNotEmpty)
                Text(
                  [work.startDate, work.endDate]
                      .where((s) => s.isNotEmpty)
                      .join(' – '),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
          Text(work.company,
              style: const TextStyle(fontStyle: FontStyle.italic)),
          if (work.bullets.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(work.bullets),
          ],
        ],
      ),
    );
  }
}

class _EduCard extends StatelessWidget {
  final EducationEntry edu;
  const _EduCard(this.edu);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(edu.degree, style: Theme.of(context).textTheme.titleSmall),
              Text(edu.school),
            ],
          ),
          Text(edu.year),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectEntry project;
  const _ProjectCard(this.project);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(project.name, style: Theme.of(context).textTheme.titleSmall),
          if (project.description.isNotEmpty) Text(project.description),
          if (project.url.isNotEmpty)
            Text(project.url,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12)),
        ],
      ),
    );
  }
}
