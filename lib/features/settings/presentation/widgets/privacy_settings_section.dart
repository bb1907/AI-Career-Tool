import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../services/ai/ai_providers_disclosure.dart';
import '../../../../services/privacy/consent_controller.dart';

class PrivacySettingsSection extends ConsumerWidget {
  const PrivacySettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consentAsync = ref.watch(consentControllerProvider);
    final aiDataGranted = consentAsync.value?.aiDataGranted ?? false;
    final biometricGranted = consentAsync.value?.biometricGranted ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel('PRIVACY & AI'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: context.appSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.appBorder),
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            children: [
              _ConsentRow(
                icon: Icons.psychology_rounded,
                label: 'AI Data Processing',
                subtitle: 'Allow your inputs to be sent to AI providers',
                granted: aiDataGranted,
                onToggle: (v) => v
                    ? ref.read(consentControllerProvider.notifier).grantAiData()
                    : ref
                          .read(consentControllerProvider.notifier)
                          .revokeAiData(),
              ),
              Divider(color: context.appBorder, height: 1, indent: 56),
              _ConsentRow(
                icon: Icons.face_retouching_natural_rounded,
                label: 'Photo AI Processing',
                subtitle:
                    'Allow your photos to be processed by AI Photo Studio',
                granted: biometricGranted,
                onToggle: (v) => v
                    ? ref
                          .read(consentControllerProvider.notifier)
                          .grantBiometric()
                    : ref
                          .read(consentControllerProvider.notifier)
                          .revokeBiometric(),
                isLast: false,
              ),
              Divider(color: context.appBorder, height: 1, indent: 56),
              _buildDisclosureRow(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDisclosureRow(BuildContext context) {
    return InkWell(
      onTap: () => _showDisclosure(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                size: 17,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Provider Disclosure',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: context.appText1,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'View which AI services process your data',
                    style: TextStyle(fontSize: 11, color: context.appText2),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: context.appText2,
            ),
          ],
        ),
      ),
    );
  }

  void _showDisclosure(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (ctx, scrollCtrl) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 12),
                child: Row(
                  children: [
                    Text(
                      'AI Providers',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Text(
                  'Your data may be processed by the following AI providers '
                  'when you use AI features. Each provider has its own privacy policy.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: providersForDisclosure.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, indent: 16),
                  itemBuilder: (ctx, i) {
                    final p = providersForDisclosure[i];
                    return ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.hub_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      title: Text(
                        p.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        p.purpose,
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.open_in_new_rounded, size: 16),
                        color: AppColors.primary,
                        tooltip: 'Privacy policy',
                        onPressed: () => launchUrl(Uri.parse(p.privacyUrl)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: context.appText2,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _ConsentRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool granted;
  final ValueChanged<bool> onToggle;
  final bool isLast;

  const _ConsentRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.granted,
    required this.onToggle,
    this.isLast = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 17, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: context.appText1,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: context.appText2),
                ),
              ],
            ),
          ),
          Switch(
            value: granted,
            onChanged: onToggle,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}
