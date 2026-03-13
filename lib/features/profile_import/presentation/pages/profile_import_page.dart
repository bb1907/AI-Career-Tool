import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../services/subscription/premium_access_feature.dart';
import '../../../paywall/application/premium_access_controller.dart';
import '../../application/candidate_profile_controller.dart';
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
  bool _isPickingFile = false;
  bool _isStartingImport = false;

  Future<void> _pickPdf() async {
    if (_isPickingFile) {
      return;
    }

    setState(() {
      _isPickingFile = true;
    });

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
      if (mounted) {
        AppFeedback.showError(context, error.message);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickingFile = false;
        });
      }
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
    if (_isStartingImport ||
        ref.read(profileImportControllerProvider).isImporting) {
      return;
    }

    setState(() {
      _isStartingImport = true;
    });

    try {
      final accessDecision = await ref
          .read(premiumAccessControllerProvider.notifier)
          .requestAccess(PremiumAccessFeature.cvParse);

      if (!accessDecision.isAllowed) {
        if (!mounted) {
          return;
        }

        final unlocked = await context.push<bool>(
          Uri(
            path: AppRoutes.paywall,
            queryParameters: {
              'from': AppRoutes.profileImport,
              'reason': 'usage_limit',
              'feature': PremiumAccessFeature.cvParse.name,
            },
          ).toString(),
        );

        if (!mounted || unlocked != true) {
          return;
        }

        AppFeedback.showSuccess(
          context,
          'Pro is now active. You can continue without generation limits.',
        );

        final refreshedDecision = await ref
            .read(premiumAccessControllerProvider.notifier)
            .requestAccess(PremiumAccessFeature.cvParse);
        if (!refreshedDecision.isAllowed) {
          return;
        }
      }

      await ref
          .read(profileImportControllerProvider.notifier)
          .importSelectedCv();
    } on AppException catch (error) {
      if (mounted) {
        AppFeedback.showError(context, error.message);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isStartingImport = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileImportControllerProvider);
    final candidateProfileState = ref.watch(candidateProfileControllerProvider);
    final theme = Theme.of(context);
    final currentProfile = candidateProfileState.asData?.value;
    final isBusy = state.isImporting || _isStartingImport || _isPickingFile;

    ref.listen(profileImportControllerProvider, (previous, next) {
      if (previous?.isImporting == true &&
          !next.isImporting &&
          next.errorMessage == null) {
        AppFeedback.showSuccess(
          context,
          'CV uploaded and candidate profile saved successfully.',
        );
      }
    });

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
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                                onPressed: isBusy ? null : _pickPdf,
                              ),
                              AppButton(
                                label: isBusy
                                    ? 'Processing...'
                                    : 'Upload and parse',
                                expanded: false,
                                variant: AppButtonVariant.tonal,
                                icon: const Icon(Icons.auto_awesome_outlined),
                                isLoading: isBusy,
                                onPressed: state.selectedFile == null || isBusy
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
                      onReplace: isBusy ? null : _pickPdf,
                      onClear: isBusy
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
                  if (candidateProfileState.isLoading &&
                      currentProfile == null &&
                      !state.isImporting) ...[
                    const SizedBox(height: AppSpacing.page),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(24),
                        child: LoadingView(
                          label: 'Loading your candidate profile...',
                        ),
                      ),
                    ),
                  ],
                  if (candidateProfileState.hasError &&
                      currentProfile == null &&
                      !state.isImporting) ...[
                    const SizedBox(height: AppSpacing.page),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: ErrorView(
                          message:
                              'Your saved candidate profile could not be loaded right now.',
                          onRetry: () {
                            ref
                                .read(
                                  candidateProfileControllerProvider.notifier,
                                )
                                .refresh();
                          },
                        ),
                      ),
                    ),
                  ],
                  if (currentProfile != null) ...[
                    const SizedBox(height: AppSpacing.page),
                    _CandidateProfileView(
                      profile: currentProfile,
                      onEdit: () => _editCandidateProfile(currentProfile),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editCandidateProfile(CandidateProfile profile) async {
    final nameController = TextEditingController(text: profile.name);
    final emailController = TextEditingController(text: profile.email);
    final locationController = TextEditingController(text: profile.location);
    final yearsController = TextEditingController(
      text: profile.yearsExperience > 0
          ? profile.yearsExperience.toString()
          : '',
    );
    final rolesController = TextEditingController(
      text: profile.roles.join('\n'),
    );
    final skillsController = TextEditingController(
      text: profile.skills.join(', '),
    );
    final industriesController = TextEditingController(
      text: profile.industries.join(', '),
    );
    final seniorityController = TextEditingController(text: profile.seniority);
    final educationController = TextEditingController(text: profile.education);
    final formKey = GlobalKey<FormState>();
    var isSaving = false;

    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          final navigator = Navigator.of(context);

          return StatefulBuilder(
            builder: (context, setModalState) {
              Future<void> save() async {
                if (!formKey.currentState!.validate() || isSaving) {
                  return;
                }

                setModalState(() {
                  isSaving = true;
                });

                try {
                  final updatedProfile = profile.copyWith(
                    name: nameController.text.trim(),
                    email: emailController.text.trim(),
                    location: locationController.text.trim(),
                    yearsExperience:
                        int.tryParse(yearsController.text.trim()) ?? 0,
                    roles: rolesController.text.splitToEntries(),
                    skills: skillsController.text.splitToEntries(),
                    industries: industriesController.text.splitToEntries(),
                    seniority: seniorityController.text.trim(),
                    education: educationController.text.trim(),
                  );

                  await ref
                      .read(candidateProfileControllerProvider.notifier)
                      .updateProfile(updatedProfile);

                  if (!mounted) {
                    return;
                  }

                  navigator.pop();
                  AppFeedback.showSuccess(
                    this.context,
                    'Candidate profile updated successfully.',
                  );
                } on AppException catch (error) {
                  if (!mounted) {
                    return;
                  }

                  AppFeedback.showError(this.context, error.message);
                  setModalState(() {
                    isSaving = false;
                  });
                } catch (_) {
                  if (!mounted) {
                    return;
                  }

                  AppFeedback.showError(
                    this.context,
                    'Candidate profile could not be updated right now.',
                  );
                  setModalState(() {
                    isSaving = false;
                  });
                }
              }

              return Padding(
                padding: EdgeInsets.only(
                  left: AppSpacing.page,
                  right: AppSpacing.page,
                  top: AppSpacing.page,
                  bottom:
                      MediaQuery.of(context).viewInsets.bottom +
                      AppSpacing.page,
                ),
                child: SafeArea(
                  top: false,
                  child: Form(
                    key: formKey,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Text(
                          'Edit candidate profile',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: AppSpacing.compact),
                        Text(
                          'Update the extracted profile once and reuse it across resume, cover letter and interview flows.',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                height: 1.5,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.page),
                        AppTextField(
                          controller: nameController,
                          labelText: 'Name',
                        ),
                        const SizedBox(height: AppSpacing.section),
                        AppTextField(
                          controller: emailController,
                          labelText: 'Email',
                        ),
                        const SizedBox(height: AppSpacing.section),
                        AppTextField(
                          controller: locationController,
                          labelText: 'Location',
                        ),
                        const SizedBox(height: AppSpacing.section),
                        AppTextField(
                          controller: yearsController,
                          labelText: 'Years of experience',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: AppSpacing.section),
                        AppTextField(
                          controller: rolesController,
                          labelText: 'Roles',
                          helperText:
                              'Use commas or new lines to separate roles.',
                          minLines: 3,
                          maxLines: 5,
                        ),
                        const SizedBox(height: AppSpacing.section),
                        AppTextField(
                          controller: skillsController,
                          labelText: 'Skills',
                          helperText:
                              'Use commas or new lines to separate skills.',
                          minLines: 3,
                          maxLines: 5,
                        ),
                        const SizedBox(height: AppSpacing.section),
                        AppTextField(
                          controller: industriesController,
                          labelText: 'Industries',
                          helperText:
                              'Use commas or new lines to separate industries.',
                          minLines: 2,
                          maxLines: 4,
                        ),
                        const SizedBox(height: AppSpacing.section),
                        AppTextField(
                          controller: seniorityController,
                          labelText: 'Seniority',
                        ),
                        const SizedBox(height: AppSpacing.section),
                        AppTextField(
                          controller: educationController,
                          labelText: 'Education',
                          minLines: 2,
                          maxLines: 4,
                        ),
                        const SizedBox(height: AppSpacing.page),
                        AppButton(
                          label: isSaving ? 'Saving...' : 'Save profile',
                          isLoading: isSaving,
                          onPressed: isSaving ? null : save,
                          icon: const Icon(Icons.save_outlined),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    } finally {
      nameController.dispose();
      emailController.dispose();
      locationController.dispose();
      yearsController.dispose();
      rolesController.dispose();
      skillsController.dispose();
      industriesController.dispose();
      seniorityController.dispose();
      educationController.dispose();
    }
  }
}

class _CandidateProfileView extends StatelessWidget {
  const _CandidateProfileView({required this.profile, required this.onEdit});

  final CandidateProfile profile;
  final VoidCallback onEdit;

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
                FilledButton.tonalIcon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit profile'),
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
