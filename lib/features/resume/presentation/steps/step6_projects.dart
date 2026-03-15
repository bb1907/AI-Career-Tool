import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/resume_data.dart';
import '../providers/resume_provider.dart';

class Step6Projects extends ConsumerStatefulWidget {
  const Step6Projects({super.key});

  @override
  ConsumerState<Step6Projects> createState() => _Step6State();
}

class _Step6State extends ConsumerState<Step6Projects> {
  late List<ProjectEntry> _entries;
  late List<int> _ids;
  int _nextId = 0;

  @override
  void initState() {
    super.initState();
    _entries = List.from(ref.read(resumeProvider).projects);
    if (_entries.isEmpty) _entries.add(const ProjectEntry());
    _ids = List.generate(_entries.length, (_) => _nextId++);
  }

  void _update() {
    ref.read(resumeProvider.notifier).updateProjects(List.from(_entries));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...List.generate(_entries.length, (i) => _ProjCard(
              key: ValueKey(_ids[i]),
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
            )),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _entries.add(const ProjectEntry());
              _ids.add(_nextId++);
            });
            _update();
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Project'),
        ),
      ],
    );
  }
}

class _ProjCard extends StatefulWidget {
  final ProjectEntry entry;
  final ValueChanged<ProjectEntry> onChanged;
  final VoidCallback? onRemove;

  const _ProjCard(
      {super.key,
      required this.entry,
      required this.onChanged,
      this.onRemove});

  @override
  State<_ProjCard> createState() => _ProjCardState();
}

class _ProjCardState extends State<_ProjCard> {
  late final TextEditingController _name;
  late final TextEditingController _desc;
  late final TextEditingController _url;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.entry.name);
    _desc = TextEditingController(text: widget.entry.description);
    _url = TextEditingController(text: widget.entry.url);
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _url.dispose();
    super.dispose();
  }

  void _save() => widget.onChanged(ProjectEntry(
        name: _name.text,
        description: _desc.text,
        url: _url.text,
      ));

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(children: [
              Expanded(
                  child: Text('Project',
                      style: Theme.of(context).textTheme.titleSmall)),
              if (widget.onRemove != null)
                IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: widget.onRemove),
            ]),
            _f(_name, 'Project Name'),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextFormField(
                controller: _desc,
                decoration: const InputDecoration(
                    labelText: 'Description', alignLabelWithHint: true),
                maxLines: 3,
                onChanged: (_) => _save(),
              ),
            ),
            _f(_url, 'URL / GitHub'),
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
