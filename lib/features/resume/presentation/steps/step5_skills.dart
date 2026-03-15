import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/resume_provider.dart';

class Step5Skills extends ConsumerStatefulWidget {
  const Step5Skills({super.key});

  @override
  ConsumerState<Step5Skills> createState() => _Step5State();
}

class _Step5State extends ConsumerState<Step5Skills> {
  late List<String> _skills;
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _skills = List.from(ref.read(resumeProvider).skills);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _add() {
    final v = _ctrl.text.trim();
    if (v.isEmpty) return;
    setState(() => _skills.add(v));
    _ctrl.clear();
    ref.read(resumeProvider.notifier).updateSkills(List.from(_skills));
  }

  void _remove(String skill) {
    setState(() => _skills.remove(skill));
    ref.read(resumeProvider.notifier).updateSkills(List.from(_skills));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  decoration:
                      const InputDecoration(labelText: 'Add skill (press Enter)'),
                  onSubmitted: (_) => _add(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(onPressed: _add, child: const Text('Add')),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _skills
                .map((skill) => Chip(
                      label: Text(skill),
                      onDeleted: () => _remove(skill),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
