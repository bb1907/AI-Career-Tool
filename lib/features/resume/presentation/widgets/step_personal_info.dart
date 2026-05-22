import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/resume_provider.dart';
import '../../domain/resume.dart';
import '../../../../app/theme/app_theme.dart';

class StepPersonalInfo extends ConsumerStatefulWidget {
  final String? resumeId;
  const StepPersonalInfo({super.key, this.resumeId});

  @override
  ConsumerState<StepPersonalInfo> createState() => _StepPersonalInfoState();
}

class _StepPersonalInfoState extends ConsumerState<StepPersonalInfo> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _linkedInController;
  late TextEditingController _websiteController;

  @override
  void initState() {
    super.initState();
    final info = ref
        .read(resumeEditorProvider(widget.resumeId))
        .resume
        .personalInfo;
    _nameController = TextEditingController(text: info.fullName);
    _emailController = TextEditingController(text: info.email);
    _phoneController = TextEditingController(text: info.phone);
    _locationController = TextEditingController(text: info.location);
    _linkedInController = TextEditingController(text: info.linkedIn ?? '');
    _websiteController = TextEditingController(text: info.website ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _linkedInController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _save() {
    ref
        .read(resumeEditorProvider(widget.resumeId).notifier)
        .updatePersonalInfo(
          PersonalInfo(
            fullName: _nameController.text,
            email: _emailController.text,
            phone: _phoneController.text,
            location: _locationController.text,
            linkedIn: _linkedInController.text.isNotEmpty
                ? _linkedInController.text
                : null,
            website: _websiteController.text.isNotEmpty
                ? _websiteController.text
                : null,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.md),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Full Name *'),
            onChanged: (_) => _save(),
          ),
          const SizedBox(height: AppTheme.md),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email *'),
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => _save(),
          ),
          const SizedBox(height: AppTheme.md),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Phone *'),
            keyboardType: TextInputType.phone,
            onChanged: (_) => _save(),
          ),
          const SizedBox(height: AppTheme.md),
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(labelText: 'Location *'),
            onChanged: (_) => _save(),
          ),
          const SizedBox(height: AppTheme.md),
          TextField(
            controller: _linkedInController,
            decoration: const InputDecoration(labelText: 'LinkedIn (optional)'),
            onChanged: (_) => _save(),
          ),
          const SizedBox(height: AppTheme.md),
          TextField(
            controller: _websiteController,
            decoration: const InputDecoration(labelText: 'Website (optional)'),
            onChanged: (_) => _save(),
          ),
        ],
      ),
    );
  }
}
