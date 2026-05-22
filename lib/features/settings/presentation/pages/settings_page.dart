import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app.dart';
import '../../../../app/core/l10n_extension.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../ui/components/language_badge.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/ai_language_provider.dart';
import '../widgets/privacy_settings_section.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _notificationsEnabled = true;

  // ── Edit Profile ──────────────────────────────────────────────────────────

  void _showEditProfileSheet() {
    final l10n = context.l10n;
    final user = ref.read(authNotifierProvider);
    final nameCtrl = TextEditingController(text: user?.name ?? '');
    final emailCtrl = TextEditingController(text: user?.email ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.profileEdit, style: Theme.of(ctx).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(labelText: l10n.profileName),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(labelText: l10n.profileEmail),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.success)));
              },
              child: Text(l10n.profileSave),
            ),
          ],
        ),
      ),
    );
  }

  // ── Delete Account ────────────────────────────────────────────────────────

  void _showDeleteAccountDialog() {
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteAccountTitle),
        content: Text(l10n.deleteAccountContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final router = GoRouter.of(context);
              Navigator.of(ctx).pop();
              await ref.read(authNotifierProvider.notifier).deleteAccount();
              router.go('/login');
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  // ── Language Picker ────────────────────────────────────────────────────────

  void _showLanguagePicker() {
    final currentLocale = ref.read(languageProvider);
    _showPickerSheet(
      title: context.l10n.settingsLanguageTitle,
      items: supportedLanguages,
      selectedCode: currentLocale.languageCode,
      onSelect: (code) =>
          ref.read(languageProvider.notifier).setLocale(Locale(code)),
    );
  }

  void _showAiLanguagePicker() {
    final current = ref.read(aiLanguageProvider);
    _showPickerSheet(
      title: context.l10n.settingsAiOutputLanguage,
      items: aiLanguageOptions,
      selectedCode: current,
      onSelect: (code) => ref.read(aiLanguageProvider.notifier).set(code),
    );
  }

  void _showPickerSheet({
    required String title,
    required List<({String code, String name, String flag})> items,
    required String selectedCode,
    required void Function(String code) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
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
                      title,
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
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  controller: scrollCtrl,
                  itemCount: items.length,
                  itemBuilder: (ctx, i) {
                    final item = items[i];
                    final isSel = item.code == selectedCode;
                    return ListTile(
                      leading: LanguageBadge(code: item.code, size: 34),
                      title: Text(item.name),
                      trailing: isSel
                          ? Icon(Icons.check_rounded, color: AppColors.primary)
                          : null,
                      selected: isSel,
                      selectedTileColor: AppColors.primary.withValues(
                        alpha: 0.06,
                      ),
                      onTap: () {
                        onSelect(item.code);
                        Navigator.of(ctx).pop();
                      },
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

  // ── Theme Picker ──────────────────────────────────────────────────────────

  void _showThemePicker() {
    final current = ref.read(themeModeProvider);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                child: Row(
                  children: [
                    Text(
                      context.l10n.settingsAppearance,
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
              const Divider(height: 1),
              _ThemeOption(
                icon: Icons.light_mode_rounded,
                label: context.l10n.settingsThemeLight,
                selected: current == ThemeMode.light,
                onTap: () {
                  ref.read(themeModeProvider.notifier).set(ThemeMode.light);
                  Navigator.of(ctx).pop();
                },
              ),
              Divider(color: context.appBorder, height: 1, indent: 56),
              _ThemeOption(
                icon: Icons.contrast_rounded,
                label: context.l10n.settingsThemeSystemDefault,
                selected: current == ThemeMode.system,
                onTap: () {
                  ref.read(themeModeProvider.notifier).set(ThemeMode.system);
                  Navigator.of(ctx).pop();
                },
              ),
              Divider(color: context.appBorder, height: 1, indent: 56),
              _ThemeOption(
                icon: Icons.dark_mode_rounded,
                label: context.l10n.settingsThemeDark,
                selected: current == ThemeMode.dark,
                onTap: () {
                  ref.read(themeModeProvider.notifier).set(ThemeMode.dark);
                  Navigator.of(ctx).pop();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(languageProvider);
    final aiLang = ref.watch(aiLanguageProvider);

    final currentLang = supportedLanguages.firstWhere(
      (l) => l.code == locale.languageCode,
      orElse: () => supportedLanguages.first,
    );
    final aiLangOpt = aiLanguageOptions.firstWhere(
      (o) => o.code == aiLang,
      orElse: () => aiLanguageOptions.first,
    );

    final themeLabel = switch (themeMode) {
      ThemeMode.light => l10n.settingsThemeLight,
      ThemeMode.dark => l10n.settingsThemeDark,
      ThemeMode.system => l10n.settingsThemeSystem,
    };
    final themeIcon = switch (themeMode) {
      ThemeMode.light => Icons.light_mode_rounded,
      ThemeMode.dark => Icons.dark_mode_rounded,
      ThemeMode.system => Icons.contrast_rounded,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // ── Account ─────────────────────────────────────────────────────
          _SectionLabel(l10n.settingsAccount),
          const SizedBox(height: AppSpacing.sm),
          _Card(
            children: [
              _Row(
                icon: Icons.person_outline_rounded,
                iconColor: AppColors.primary,
                label: l10n.profileEdit,
                onTap: _showEditProfileSheet,
              ),
              _Row(
                icon: Icons.notifications_outlined,
                iconColor: const Color(0xFFF59E0B),
                label: l10n.settingsNotifications,
                trailing: Switch.adaptive(
                  value: _notificationsEnabled,
                  onChanged: (v) => setState(() => _notificationsEnabled = v),
                  activeColor: AppColors.primary,
                ),
              ),
              _Row(
                icon: Icons.upload_file_outlined,
                iconColor: const Color(0xFF00C2A8),
                label: l10n.cvUploadTitle,
                onTap: () => context.push('/cv-upload'),
                isLast: true,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Appearance & Language ────────────────────────────────────────
          _SectionLabel(l10n.settingsAppearance),
          const SizedBox(height: AppSpacing.sm),
          _Card(
            children: [
              _Row(
                icon: themeIcon,
                iconColor: const Color(0xFF8B5CF6),
                label: l10n.settingsTheme,
                trailing: Text(
                  themeLabel,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.appText2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: _showThemePicker,
              ),
              _Row(
                icon: Icons.language_rounded,
                iconColor: const Color(0xFF3B82F6),
                label: l10n.settingsLanguage,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LanguageBadge(code: currentLang.code, size: 22),
                    const SizedBox(width: 6),
                    Text(
                      currentLang.name,
                      style: TextStyle(fontSize: 13, color: context.appText2),
                    ),
                  ],
                ),
                onTap: _showLanguagePicker,
              ),
              _Row(
                icon: Icons.translate_rounded,
                iconColor: const Color(0xFF00C2A8),
                label: l10n.settingsAiOutputLanguage,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LanguageBadge(code: aiLangOpt.code, size: 22),
                    const SizedBox(width: 6),
                    Text(
                      aiLangOpt.code == 'auto'
                          ? l10n.profileAutoLanguage
                          : aiLangOpt.name,
                      style: TextStyle(fontSize: 13, color: context.appText2),
                    ),
                  ],
                ),
                onTap: _showAiLanguagePicker,
                isLast: true,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Subscription ────────────────────────────────────────────────
          _SectionLabel(l10n.settingsSubscription),
          const SizedBox(height: AppSpacing.sm),
          _Card(
            children: [
              _Row(
                icon: Icons.star_outline_rounded,
                iconColor: const Color(0xFFF59E0B),
                label: l10n.profileUpgrade,
                onTap: () => context.push('/paywall'),
              ),
              _Row(
                icon: Icons.restore_rounded,
                iconColor: const Color(0xFF6B7280),
                label: l10n.paywallRestore,
                onTap: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l10n.loading)));
                },
                isLast: true,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── About & Legal ───────────────────────────────────────────────
          _SectionLabel(l10n.settingsAbout),
          const SizedBox(height: AppSpacing.sm),
          _Card(
            children: [
              _Row(
                icon: Icons.info_outline_rounded,
                iconColor: AppColors.primary,
                label: l10n.settingsAbout,
                subtitle: l10n.settingsAboutSubtitle,
                onTap: () => context.push('/about'),
              ),
              _Row(
                icon: Icons.privacy_tip_outlined,
                iconColor: const Color(0xFF6B7280),
                label: l10n.settingsPrivacy,
                onTap: () {},
              ),
              _Row(
                icon: Icons.description_outlined,
                iconColor: const Color(0xFF6B7280),
                label: l10n.settingsTerms,
                onTap: () {},
              ),
              _Row(
                icon: Icons.smartphone_rounded,
                iconColor: const Color(0xFF6B7280),
                label: l10n.settingsAppVersion,
                trailing: Text(
                  'v1.0.0',
                  style: TextStyle(fontSize: 13, color: context.appText2),
                ),
                showChevron: false,
                isLast: true,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Privacy & AI ─────────────────────────────────────────────────
          const PrivacySettingsSection(),

          const SizedBox(height: AppSpacing.lg),

          // ── Danger Zone ─────────────────────────────────────────────────
          _SectionLabel(l10n.settingsDangerZone),
          const SizedBox(height: AppSpacing.sm),
          _Card(
            children: [
              _Row(
                icon: Icons.delete_outline_rounded,
                iconColor: AppColors.error,
                label: l10n.settingsDeleteAccount,
                labelColor: AppColors.error,
                onTap: _showDeleteAccountDialog,
              ),
              _Row(
                icon: Icons.logout_rounded,
                iconColor: AppColors.error,
                label: l10n.profileSignOut,
                labelColor: AppColors.error,
                onTap: () async {
                  await ref.read(authNotifierProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                },
                isLast: true,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

// ── Section label ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text.toUpperCase(),
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

// ── Card container ──────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appBorder),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(children: children),
    );
  }
}

// ── Setting row ─────────────────────────────────────────────────────────────

class _Row extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? subtitle;
  final Color? labelColor;
  final Widget? trailing;
  final bool showChevron;
  final bool isLast;
  final VoidCallback? onTap;

  const _Row({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.subtitle,
    this.labelColor,
    this.trailing,
    this.showChevron = true,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 17, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: labelColor ?? context.appText1,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 1),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 11,
                            color: context.appText2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 8), trailing!],
                if (showChevron && onTap != null && trailing == null) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: context.appText2,
                  ),
                ] else if (showChevron &&
                    onTap != null &&
                    trailing != null) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: context.appText2,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (!isLast) Divider(color: context.appBorder, height: 1, indent: 56),
      ],
    );
  }
}

// ── Theme option ────────────────────────────────────────────────────────────

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: selected ? AppColors.primary : context.appText2,
        size: 22,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          color: selected ? AppColors.primary : context.appText1,
        ),
      ),
      trailing: selected
          ? Icon(Icons.check_rounded, color: AppColors.primary)
          : null,
      onTap: onTap,
    );
  }
}
