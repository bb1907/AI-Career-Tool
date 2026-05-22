import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/resume_provider.dart';
import '../../domain/resume.dart';
import '../../../../app/theme/app_theme.dart';

class StepEducation extends ConsumerWidget {
  final String? resumeId;
  const StepEducation({super.key, this.resumeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final educations = ref
        .watch(resumeEditorProvider(resumeId))
        .resume
        .educations;
    final notifier = ref.read(resumeEditorProvider(resumeId).notifier);

    return ListView(
      padding: const EdgeInsets.all(AppTheme.md),
      children: [
        ...educations.asMap().entries.map((entry) {
          final i = entry.key;
          final edu = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: AppTheme.sm),
            child: ListTile(
              title: Text('${edu.degree} in ${edu.field}'),
              subtitle: Text(
                '${edu.institution} • ${edu.startDate} - ${edu.endDate ?? "Present"}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  final updated = [...educations]..removeAt(i);
                  notifier.updateEducations(updated);
                },
              ),
            ),
          );
        }),
        OutlinedButton.icon(
          onPressed: () => _showAddDialog(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Add Education'),
        ),
      ],
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final instCtrl = TextEditingController();
    final degreeCtrl = TextEditingController();
    final fieldCtrl = TextEditingController();
    final startCtrl = TextEditingController();
    final endCtrl = TextEditingController();
    final gpaCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Education'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: instCtrl,
                decoration: const InputDecoration(labelText: 'Institution'),
              ),
              const SizedBox(height: AppTheme.sm),
              TextField(
                controller: degreeCtrl,
                decoration: const InputDecoration(labelText: 'Degree'),
              ),
              const SizedBox(height: AppTheme.sm),
              TextField(
                controller: fieldCtrl,
                decoration: const InputDecoration(labelText: 'Field of Study'),
              ),
              const SizedBox(height: AppTheme.sm),
              TextField(
                controller: startCtrl,
                decoration: const InputDecoration(labelText: 'Start Year'),
              ),
              const SizedBox(height: AppTheme.sm),
              TextField(
                controller: endCtrl,
                decoration: const InputDecoration(labelText: 'End Year'),
              ),
              const SizedBox(height: AppTheme.sm),
              TextField(
                controller: gpaCtrl,
                decoration: const InputDecoration(labelText: 'GPA (optional)'),
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
                  .educations;
              notifier.updateEducations([
                ...current,
                Education(
                  id: 'edu-${DateTime.now().millisecondsSinceEpoch}',
                  institution: instCtrl.text,
                  degree: degreeCtrl.text,
                  field: fieldCtrl.text,
                  startDate: startCtrl.text,
                  endDate: endCtrl.text.isNotEmpty ? endCtrl.text : null,
                  gpa: gpaCtrl.text.isNotEmpty ? gpaCtrl.text : null,
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
