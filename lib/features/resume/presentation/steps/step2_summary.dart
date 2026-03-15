import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/resume_provider.dart';

class Step2Summary extends ConsumerStatefulWidget {
  const Step2Summary({super.key});

  @override
  ConsumerState<Step2Summary> createState() => _Step2State();
}

class _Step2State extends ConsumerState<Step2Summary> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: ref.read(resumeProvider).summary);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextFormField(
        controller: _ctrl,
        decoration: const InputDecoration(
          labelText: 'Professional Summary',
          alignLabelWithHint: true,
        ),
        maxLines: 8,
        onChanged: (v) =>
            ref.read(resumeProvider.notifier).updateSummary(v),
      ),
    );
  }
}
