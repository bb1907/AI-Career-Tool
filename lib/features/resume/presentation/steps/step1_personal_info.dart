import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/resume_data.dart';
import '../providers/resume_provider.dart';

class Step1PersonalInfo extends ConsumerStatefulWidget {
  const Step1PersonalInfo({super.key});

  @override
  ConsumerState<Step1PersonalInfo> createState() => _Step1State();
}

class _Step1State extends ConsumerState<Step1PersonalInfo> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _location;
  late final TextEditingController _linkedin;

  @override
  void initState() {
    super.initState();
    final info = ref.read(resumeProvider).personalInfo;
    _name = TextEditingController(text: info.name);
    _email = TextEditingController(text: info.email);
    _phone = TextEditingController(text: info.phone);
    _location = TextEditingController(text: info.location);
    _linkedin = TextEditingController(text: info.linkedin);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _location.dispose();
    _linkedin.dispose();
    super.dispose();
  }

  void _save() {
    ref.read(resumeProvider.notifier).updatePersonalInfo(PersonalInfo(
          name: _name.text,
          email: _email.text,
          phone: _phone.text,
          location: _location.text,
          linkedin: _linkedin.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _field(_name, 'Full Name', TextInputType.name, required: true),
          _field(_email, 'Email', TextInputType.emailAddress, required: true),
          _field(_phone, 'Phone', TextInputType.phone),
          _field(_location, 'Location', TextInputType.text),
          _field(_linkedin, 'LinkedIn URL', TextInputType.url),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    TextInputType type, {
    bool required = false,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: ctrl,
          decoration: InputDecoration(
            labelText: required ? '$label *' : label,
          ),
          keyboardType: type,
          onChanged: (_) => _save(),
          validator: required
              ? (v) => v == null || v.trim().isEmpty ? 'Required' : null
              : null,
        ),
      );
}
