import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/resume_provider.dart';
import '../../domain/resume.dart';
import '../../../../app/theme/app_theme.dart';

class StepProjects extends ConsumerWidget {
  final String? resumeId;
  const StepProjects({super.key, this.resumeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(resumeEditorProvider(resumeId)).resume.projects;
    final notifier = ref.read(resumeEditorProvider(resumeId).notifier);

    return ListView(
      padding: const EdgeInsets.all(AppTheme.md),
      children: [
        ...projects.asMap().entries.map((entry) {
          final i = entry.key;
          final project = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: AppTheme.sm),
            child: ListTile(
              title: Text(project.name),
              subtitle: Text(project.description),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  final updated = [...projects]..removeAt(i);
                  notifier.updateProjects(updated);
                },
              ),
            ),
          );
        }),
        OutlinedButton.icon(
          onPressed: () => _showAddDialog(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Add Project'),
        ),
      ],
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    final techCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Project'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Project Name'),
              ),
              const SizedBox(height: AppTheme.sm),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: AppTheme.sm),
              TextField(
                controller: urlCtrl,
                decoration: const InputDecoration(labelText: 'URL (optional)'),
              ),
              const SizedBox(height: AppTheme.sm),
              TextField(
                controller: techCtrl,
                decoration: const InputDecoration(
                  labelText: 'Technologies (comma separated)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final notifier = ref.read(
                resumeEditorProvider(resumeId).notifier,
              );
              final current = ref
                  .read(resumeEditorProvider(resumeId))
                  .resume
                  .projects;
              final techs = techCtrl.text
                  .split(',')
                  .map((t) => t.trim())
                  .where((t) => t.isNotEmpty)
                  .toList();
              notifier.updateProjects([
                ...current,
                Project(
                  id: 'proj-${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text,
                  description: descCtrl.text,
                  url: urlCtrl.text.isNotEmpty ? urlCtrl.text : null,
                  technologies: techs,
                ),
              ]);
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
