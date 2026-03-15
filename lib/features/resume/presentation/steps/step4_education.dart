import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/resume_data.dart';
import '../providers/resume_provider.dart';

class Step4Education extends ConsumerStatefulWidget {
  const Step4Education({super.key});

  @override
  ConsumerState<Step4Education> createState() => _Step4State();
}

class _Step4State extends ConsumerState<Step4Education> {
  late List<EducationEntry> _entries;
  late List<int> _ids;
  int _nextId = 0;

  @override
  void initState() {
    super.initState();
    _entries = List.from(ref.read(resumeProvider).education);
    if (_entries.isEmpty) _entries.add(const EducationEntry());
    _ids = List.generate(_entries.length, (_) => _nextId++);
  }

  void _update() {
    ref.read(resumeProvider.notifier).updateEducation(List.from(_entries));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...List.generate(_entries.length, (i) => Card(
              key: ValueKey(_ids[i]),
              margin: const EdgeInsets.only(bottom: 12),
              child: _EduCard(
                entry: _entries[i],
                onChanged: (u) {
                  setState(() => _entries[i] = u);
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
              ),
            )),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _entries.add(const EducationEntry());
              _ids.add(_nextId++);
            });
            _update();
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Education'),
        ),
      ],
    );
  }
}

class _EduCard extends StatefulWidget {
  final EducationEntry entry;
  final ValueChanged<EducationEntry> onChanged;
  final VoidCallback? onRemove;

  const _EduCard(
      {required this.entry, required this.onChanged, this.onRemove});

  @override
  State<_EduCard> createState() => _EduCardState();
}

class _EduCardState extends State<_EduCard> {
  late final TextEditingController _school;
  late final TextEditingController _degree;
  late final TextEditingController _year;

  @override
  void initState() {
    super.initState();
    _school = TextEditingController(text: widget.entry.school);
    _degree = TextEditingController(text: widget.entry.degree);
    _year = TextEditingController(text: widget.entry.year);
  }

  @override
  void dispose() {
    _school.dispose();
    _degree.dispose();
    _year.dispose();
    super.dispose();
  }

  void _save() => widget.onChanged(EducationEntry(
        school: _school.text,
        degree: _degree.text,
        year: _year.text,
      ));

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(children: [
            Expanded(
                child: Text('Education',
                    style: Theme.of(context).textTheme.titleSmall)),
            if (widget.onRemove != null)
              IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: widget.onRemove),
          ]),
          _f(_school, 'School / University'),
          _f(_degree, 'Degree / Field'),
          _f(_year, 'Graduation Year'),
        ],
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
