import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/resume_provider.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../services/openai/openai_service.dart';
import '../../../../shared/widgets/ai_loading_dialog.dart';

class StepSummary extends ConsumerStatefulWidget {
  final String? resumeId;
  const StepSummary({super.key, this.resumeId});

  @override
  ConsumerState<StepSummary> createState() => _StepSummaryState();
}

class _StepSummaryState extends ConsumerState<StepSummary> {
  late TextEditingController _controller;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(resumeEditorProvider(widget.resumeId)).resume.summary,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onAiGenerate() async {
    final service = ref.read(openAiServiceProvider);
    debugPrint('[DEBUG ResumeSummary] hasKey: ${service.hasKey}');
    if (!service.hasKey) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No API key configured. Run with --dart-define=OPENAI_API_KEY=sk-…',
          ),
        ),
      );
      return;
    }

    setState(() => _isGenerating = true);
    showAiLoading(
      context,
      messages: const [
        'Reviewing your experience...',
        'Identifying key skills...',
        'Writing your summary...',
      ],
    );

    try {
      final resume = ref.read(resumeEditorProvider(widget.resumeId)).resume;
      final summary = await service.generateResumeSummary(resume);

      if (!mounted) return;
      Navigator.of(context).pop(); // dismiss dialog
      _controller.text = summary;
      ref
          .read(resumeEditorProvider(widget.resumeId).notifier)
          .updateSummary(summary);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // dismiss dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Generation failed: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Write a brief professional summary (2-4 sentences)',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: AppTheme.md),
          TextField(
            controller: _controller,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'Experienced professional with...',
              alignLabelWithHint: true,
            ),
            onChanged: (v) => ref
                .read(resumeEditorProvider(widget.resumeId).notifier)
                .updateSummary(v),
          ),
          const SizedBox(height: AppTheme.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isGenerating ? null : _onAiGenerate,
              icon: _isGenerating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome, size: 18),
              label: Text(_isGenerating ? 'Generating...' : 'Generate with AI'),
            ),
          ),
        ],
      ),
    );
  }
}
