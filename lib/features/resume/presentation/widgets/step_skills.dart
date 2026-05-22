import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/resume_provider.dart';
import '../../domain/resume.dart';
import '../../../../app/theme/app_theme.dart';

class StepSkills extends ConsumerWidget {
  final String? resumeId;
  const StepSkills({super.key, this.resumeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skills = ref.watch(resumeEditorProvider(resumeId)).resume.skills;
    final notifier = ref.read(resumeEditorProvider(resumeId).notifier);

    return ListView(
      padding: const EdgeInsets.all(AppTheme.md),
      children: [
        Wrap(
          spacing: AppTheme.sm,
          runSpacing: AppTheme.sm,
          children: skills.asMap().entries.map((entry) {
            final i = entry.key;
            final skill = entry.value;
            return Chip(
              label: Text(skill.name),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                final updated = [...skills]..removeAt(i);
                notifier.updateSkills(updated);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: AppTheme.md),
        OutlinedButton.icon(
          onPressed: () => _showAddDialog(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Add Skill'),
        ),
      ],
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    String category = 'technical';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Skill'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Skill Name'),
              ),
              const SizedBox(height: AppTheme.sm),
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: const [
                  DropdownMenuItem(
                    value: 'technical',
                    child: Text('Technical'),
                  ),
                  DropdownMenuItem(value: 'soft', child: Text('Soft Skill')),
                  DropdownMenuItem(value: 'language', child: Text('Language')),
                ],
                onChanged: (v) =>
                    setDialogState(() => category = v ?? 'technical'),
              ),
            ],
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
                    .skills;
                notifier.updateSkills([
                  ...current,
                  Skill(
                    id: 'skill-${DateTime.now().millisecondsSinceEpoch}',
                    name: nameCtrl.text,
                    category: category,
                  ),
                ]);
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
