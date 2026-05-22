import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/resume_provider.dart';
import '../../domain/resume.dart';
import '../../../../app/theme/app_theme.dart';

class StepWorkExperience extends ConsumerWidget {
  final String? resumeId;
  const StepWorkExperience({super.key, this.resumeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final experiences = ref
        .watch(resumeEditorProvider(resumeId))
        .resume
        .workExperiences;
    final notifier = ref.read(resumeEditorProvider(resumeId).notifier);

    return ListView(
      padding: const EdgeInsets.all(AppTheme.md),
      children: [
        ...experiences.asMap().entries.map((entry) {
          final i = entry.key;
          final exp = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: AppTheme.sm),
            child: ListTile(
              title: Text(exp.position),
              subtitle: Text(
                '${exp.company} • ${exp.startDate} - ${exp.isCurrent ? "Present" : (exp.endDate ?? "")}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  final updated = [...experiences]..removeAt(i);
                  notifier.updateWorkExperiences(updated);
                },
              ),
            ),
          );
        }),
        OutlinedButton.icon(
          onPressed: () => _showAddDialog(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Add Experience'),
        ),
      ],
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final companyCtrl = TextEditingController();
    final positionCtrl = TextEditingController();
    final startCtrl = TextEditingController();
    final endCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    bool isCurrent = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Experience'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: companyCtrl,
                  decoration: const InputDecoration(labelText: 'Company'),
                ),
                const SizedBox(height: AppTheme.sm),
                TextField(
                  controller: positionCtrl,
                  decoration: const InputDecoration(labelText: 'Position'),
                ),
                const SizedBox(height: AppTheme.sm),
                TextField(
                  controller: startCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Start Date (e.g. Jan 2022)',
                  ),
                ),
                const SizedBox(height: AppTheme.sm),
                CheckboxListTile(
                  title: const Text('Currently working here'),
                  value: isCurrent,
                  onChanged: (v) =>
                      setDialogState(() => isCurrent = v ?? false),
                  contentPadding: EdgeInsets.zero,
                ),
                if (!isCurrent)
                  TextField(
                    controller: endCtrl,
                    decoration: const InputDecoration(labelText: 'End Date'),
                  ),
                const SizedBox(height: AppTheme.sm),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description'),
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
                    .workExperiences;
                notifier.updateWorkExperiences([
                  ...current,
                  WorkExperience(
                    id: 'we-${DateTime.now().millisecondsSinceEpoch}',
                    company: companyCtrl.text,
                    position: positionCtrl.text,
                    startDate: startCtrl.text,
                    endDate: isCurrent ? null : endCtrl.text,
                    isCurrent: isCurrent,
                    description: descCtrl.text,
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
