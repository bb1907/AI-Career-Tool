import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/core/l10n_extension.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../ui/components/app_input_field.dart';
import '../../domain/application.dart';
import '../providers/application_controller.dart';

class ApplicationFormScreen extends ConsumerStatefulWidget {
  /// If provided, the form is pre-populated for editing.
  final Application? existing;

  const ApplicationFormScreen({super.key, this.existing});

  @override
  ConsumerState<ApplicationFormScreen> createState() =>
      _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends ConsumerState<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _company;
  late final TextEditingController _role;
  late final TextEditingController _jobDescription;
  late final TextEditingController _notes;
  late final TextEditingController _source;

  late ApplicationStatus _status;
  DateTime? _followUpAt;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final a = widget.existing;
    _company = TextEditingController(text: a?.company ?? '');
    _role = TextEditingController(text: a?.role ?? '');
    _jobDescription = TextEditingController(text: a?.jobDescription ?? '');
    _notes = TextEditingController(text: a?.notes ?? '');
    _source = TextEditingController(text: a?.source ?? '');
    _status = a?.status ?? ApplicationStatus.wishlist;
    _followUpAt = a?.followUpAt;
  }

  @override
  void dispose() {
    _company.dispose();
    _role.dispose();
    _jobDescription.dispose();
    _notes.dispose();
    _source.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final controller = ref.read(applicationControllerProvider.notifier);

      if (widget.existing == null) {
        // Create new
        final app = Application(
          id: const Uuid().v4(),
          company: _company.text.trim(),
          role: _role.text.trim(),
          jobDescription: _jobDescription.text.trim(),
          status: _status,
          createdAt: DateTime.now(),
          appliedAt: _status == ApplicationStatus.applied
              ? DateTime.now()
              : null,
          followUpAt: _followUpAt,
          notes: _notes.text.trim(),
          source: _source.text.trim(),
        );
        final created = await controller.add(app);
        if (mounted) context.pushReplacement('/applications/${created.id}');
      } else {
        // Update existing
        final updated = widget.existing!.copyWith(
          company: _company.text.trim(),
          role: _role.text.trim(),
          jobDescription: _jobDescription.text.trim(),
          status: _status,
          appliedAt:
              _status == ApplicationStatus.applied &&
                  widget.existing!.appliedAt == null
              ? DateTime.now()
              : widget.existing!.appliedAt,
          followUpAt: _followUpAt,
          notes: _notes.text.trim(),
          source: _source.text.trim(),
        );
        await controller.save(updated);
        if (mounted) context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickFollowUp() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _followUpAt ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() => _followUpAt = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Scaffold(
      backgroundColor: context.appBG,
      appBar: AppBar(
        backgroundColor: context.appSurface,
        title: Text(
          isEdit
              ? context.l10n.applicationFormEditTitle
              : context.l10n.applicationFormTitle,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          children: [
            // Company
            AppInputField(
              controller: _company,
              label: context.l10n.applicationFormCompany,
              hint: 'e.g. Google, Stripe, Shopify',
              prefixIcon: Icons.business_rounded,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),

            // Role
            AppInputField(
              controller: _role,
              label: context.l10n.applicationFormRole,
              hint: 'e.g. Senior iOS Engineer',
              prefixIcon: Icons.work_outline_rounded,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),

            // Status
            _StatusPicker(
              selected: _status,
              onChanged: (s) => setState(() => _status = s),
            ),
            const SizedBox(height: 12),

            // Source
            AppInputField(
              controller: _source,
              label: context.l10n.applicationFormSource,
              hint: 'LinkedIn, Referral, Company site...',
              prefixIcon: Icons.source_rounded,
            ),
            const SizedBox(height: 12),

            // Follow-up reminder
            _FollowUpPicker(
              date: _followUpAt,
              onTap: _pickFollowUp,
              onClear: () => setState(() => _followUpAt = null),
            ),
            const SizedBox(height: 12),

            // Job Description
            AppInputField(
              controller: _jobDescription,
              label: context.l10n.applicationFormJobDescription,
              hint: 'Paste the job description here...',
              maxLines: 5,
            ),
            const SizedBox(height: 12),

            // Notes
            AppInputField(
              controller: _notes,
              label: context.l10n.applicationFormNotes,
              hint: 'Your personal notes about this application...',
              maxLines: 3,
            ),
            const SizedBox(height: 28),

            // Save button
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        context.l10n.applicationFormSave,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status Picker ─────────────────────────────────────────────────────────────

class _StatusPicker extends StatelessWidget {
  final ApplicationStatus selected;
  final ValueChanged<ApplicationStatus> onChanged;

  const _StatusPicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            context.l10n.applicationFormStatus,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: context.appText2,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ApplicationStatus.values.map((s) {
            final isSelected = s == selected;
            return GestureDetector(
              onTap: () => onChanged(s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? s.color.withValues(alpha: 0.15)
                      : context.appSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? s.color : context.appBorder,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      s.icon,
                      size: 14,
                      color: isSelected ? s.color : context.appText2,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      s.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? s.color : context.appText2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Follow-up Picker ──────────────────────────────────────────────────────────

class _FollowUpPicker extends StatelessWidget {
  final DateTime? date;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _FollowUpPicker({
    required this.date,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: context.appSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: date != null
                ? AppColors.primary.withValues(alpha: 0.5)
                : context.appBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.alarm_rounded,
              size: 18,
              color: date != null ? AppColors.primary : context.appText2,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                date != null
                    ? 'Follow-up: ${_format(date!)}'
                    : context.l10n.applicationFormFollowUpHint,
                style: TextStyle(
                  fontSize: 14,
                  color: date != null ? context.appText1 : context.appText2,
                ),
              ),
            ),
            if (date != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(
                  Icons.clear_rounded,
                  size: 18,
                  color: context.appText2,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _format(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
