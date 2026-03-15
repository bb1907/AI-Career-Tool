import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/resume_data.dart';
import '../providers/resume_provider.dart';

class Step3WorkExperience extends ConsumerStatefulWidget {
  const Step3WorkExperience({super.key});

  @override
  ConsumerState<Step3WorkExperience> createState() => _Step3State();
}

class _Step3State extends ConsumerState<Step3WorkExperience> {
  late List<WorkEntry> _entries;
  late List<int> _ids;
  int _nextId = 0;

  @override
  void initState() {
    super.initState();
    _entries = List.from(ref.read(resumeProvider).workExperience);
    if (_entries.isEmpty) _entries.add(const WorkEntry());
    _ids = List.generate(_entries.length, (_) => _nextId++);
  }

  void _update() {
    ref.read(resumeProvider.notifier).updateWorkExperience(List.from(_entries));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...List.generate(_entries.length, (i) {
          return _EntryCard(
            key: ValueKey(_ids[i]),
            entry: _entries[i],
            onChanged: (updated) {
              setState(() => _entries[i] = updated);
              _update();
            },
            onRemove: _entries.length > 1
                ? () {
                    setState(() {
                      _entries.removeAt(i);
                      _ids.removeAt(i);
                    });
                    _update();
                  }
                : null,
          );
        }),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _entries.add(const WorkEntry());
              _ids.add(_nextId++);
            });
            _update();
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Position'),
        ),
      ],
    );
  }
}

class _EntryCard extends StatefulWidget {
  final WorkEntry entry;
  final ValueChanged<WorkEntry> onChanged;
  final VoidCallback? onRemove;

  const _EntryCard({
    super.key,
    required this.entry,
    required this.onChanged,
    this.onRemove,
  });

  @override
  State<_EntryCard> createState() => _EntryCardState();
}

class _EntryCardState extends State<_EntryCard> {
  late final TextEditingController _company;
  late final TextEditingController _title;
  late final TextEditingController _start;
  late final TextEditingController _end;
  late final TextEditingController _bullets;

  @override
  void initState() {
    super.initState();
    _company = TextEditingController(text: widget.entry.company);
    _title = TextEditingController(text: widget.entry.title);
    _start = TextEditingController(text: widget.entry.startDate);
    _end = TextEditingController(text: widget.entry.endDate);
    _bullets = TextEditingController(text: widget.entry.bullets);
  }

  @override
  void dispose() {
    _company.dispose();
    _title.dispose();
    _start.dispose();
    _end.dispose();
    _bullets.dispose();
    super.dispose();
  }

  void _save() {
    widget.onChanged(WorkEntry(
      company: _company.text,
      title: _title.text,
      startDate: _start.text,
      endDate: _end.text,
      bullets: _bullets.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: Text('Position',
                        style: Theme.of(context).textTheme.titleSmall)),
                if (widget.onRemove != null)
                  IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: widget.onRemove),
              ],
            ),
            _f(_company, 'Company'),
            _f(_title, 'Job Title'),
            Row(children: [
              Expanded(child: _f(_start, 'Start')),
              const SizedBox(width: 8),
              Expanded(child: _f(_end, 'End / Present')),
            ]),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextFormField(
                controller: _bullets,
                decoration: const InputDecoration(
                  labelText: 'Responsibilities',
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                onChanged: (_) => _save(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _f(TextEditingController c, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TextFormField(
          controller: c,
          decoration: InputDecoration(labelText: label),
          onChanged: (_) => _save(),
        ),
      );
}
