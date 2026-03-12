import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../application/profile_import_controller.dart';
import '../../domain/entities/candidate_profile.dart';
import '../../domain/entities/cv_upload_file.dart';
import '../widgets/candidate_profile_section_card.dart';
import '../widgets/selected_cv_card.dart';

class ProfileImportPage extends ConsumerStatefulWidget {
  const ProfileImportPage({super.key});

  @override
  ConsumerState<ProfileImportPage> createState() => _ProfileImportPageState();
}

class _ProfileImportPageState extends ConsumerState<ProfileImportPage> {
  Future<void> _pickPdf() async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.single;
      final bytes = await _resolveBytes(file);

      if (bytes == null || bytes.isEmpty) {
        throw const AppException('The selected PDF could not be read.');
      }

      ref
          .read(profileImportControllerProvider.notifier)
          .selectFile(
            CvUploadFile(
              fileName: file.name,
              bytes: bytes,
              sizeInBytes: file.size,
            ),
          );
    } on AppException catch (error) {
      if (!mounted) {
        return;
      }

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
    }
  }

  Future<Uint8List?> _resolveBytes(PlatformFile file) async {
    if (file.bytes != null) {
      return file.bytes;
    }

    final path = file.path;
    if (path == null || path.isEmpty) {
      return null;
    }

    return File(path).readAsBytes();
  }

  Future<void> _startImport() async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      await ref
          .read(profileImportControllerProvider.notifier)
          .importSelectedCv();
    } on AppException catch (error) {
      if (!mounted) {
        return;
      }

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileImportControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import CV'),
        actions: [
          IconButton(
            tooltip: 'Back to Home',
            onPressed: () => context.go(AppRoutes.home),
            icon: const Icon(Icons.home_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.compact,
            AppSpacing.page,
            AppSpacing.page,
          ),
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Upload a PDF CV and structure it instantly',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.compact),
                          Text(
                            'The CV is uploaded to Supabase Storage, text is extracted from the PDF and the shared AI parser returns a structured candidate profile.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.page),
                          Wrap(
                            spacing: AppSpacing.compact,
                            runSpacing: AppSpacing.compact,
                            children: [
                              AppButton(
                                label: state.selectedFile == null
                                    ? 'Choose PDF'
                                    : 'Choose another PDF',
                                expanded: false,
                                icon: const Icon(Icons.upload_file_outlined),
                                onPressed: state.isImporting ? null : _pickPdf,
                              ),
                              AppButton(
                                label: state.isImporting
                                    ? 'Processing...'
                                    : 'Upload and parse',
                                expanded: false,
                                variant: AppButtonVariant.tonal,
                                icon: const Icon(Icons.auto_awesome_outlined),
                                isLoading: state.isImporting,
                                onPressed:
                                    state.selectedFile == null ||
                                        state.isImporting
                                    ? null
                                    : _startImport,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.page),
                  if (state.selectedFile != null)
                    SelectedCvCard(
                      file: state.selectedFile!,
                      onReplace: state.isImporting ? null : _pickPdf,
                      onClear: state.isImporting
                          ? null
                          : () => ref
                                .read(profileImportControllerProvider.notifier)
                                .clearSelection(),
                    ),
                  if (state.isImporting) ...[
                    const SizedBox(height: AppSpacing.page),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: LoadingView(label: state.processingLabel),
                      ),
                    ),
                  ],
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.page),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: ErrorView(
                          message: state.errorMessage!,
                          onRetry:
                              state.selectedFile == null || state.isImporting
                              ? null
                              : _startImport,
                        ),
                      ),
                    ),
                  ],
                  if (state.profile != null) ...[
                    const SizedBox(height: AppSpacing.page),
                    _CandidateProfileView(profile: state.profile!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CandidateProfileView extends StatelessWidget {
  const _CandidateProfileView({required this.profile});

  final CandidateProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Structured candidate profile',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.compact),
                Text(
                  'The profile has been parsed and saved. Review the extracted fields below.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.page),
        CandidateProfileSectionCard(
          title: 'Overview',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(profile.name, style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                profile.email.isEmpty ? 'No email detected' : profile.email,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 4),
              Text(
                profile.location.isEmpty
                    ? 'No location detected'
                    : profile.location,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              Text(
                '${profile.yearsExperience} years experience • ${profile.seniority}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.page),
        CandidateProfileSectionCard(
          title: 'Roles',
          child: _ChipWrap(
            items: profile.roles,
            emptyLabel: 'No roles detected',
          ),
        ),
        const SizedBox(height: AppSpacing.page),
        CandidateProfileSectionCard(
          title: 'Skills',
          child: _ChipWrap(
            items: profile.skills,
            emptyLabel: 'No skills detected',
          ),
        ),
        const SizedBox(height: AppSpacing.page),
        CandidateProfileSectionCard(
          title: 'Industries',
          child: _ChipWrap(
            items: profile.industries,
            emptyLabel: 'No industries detected',
          ),
        ),
        const SizedBox(height: AppSpacing.page),
        CandidateProfileSectionCard(
          title: 'Education',
          child: Text(
            profile.education.isEmpty
                ? 'No education details detected'
                : profile.education,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
        ),
      ],
    );
  }
}

class _ChipWrap extends StatelessWidget {
  const _ChipWrap({required this.items, required this.emptyLabel});

  final List<String> items;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text(emptyLabel);
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in items)
          Chip(label: Text(item), visualDensity: VisualDensity.compact),
      ],
    );
  }
}
