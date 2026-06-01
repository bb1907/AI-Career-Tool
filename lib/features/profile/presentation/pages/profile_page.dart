import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app.dart';
import '../../../../app/core/app_links.dart';
import '../../../../app/core/l10n_extension.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../settings/providers/ai_language_provider.dart';
import '../../../settings/providers/language_provider.dart';
import '../../../../services/subscription/subscription_provider.dart';
import '../../../../ui/components/language_badge.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  // ── Language picker ────────────────────────────────────────────────────────

  void _showLanguagePicker() {
    final current = ref.read(languageProvider).languageCode;
    _showPickerSheet(
      title: context.l10n.settingsLanguage,
      items: supportedLanguages
          .map((l) => (code: l.code, name: l.name, flag: l.flag))
          .toList(),
      selected: current,
      onSelect: (code) =>
          ref.read(languageProvider.notifier).setLocale(Locale(code)),
    );
  }

  void _showAiLanguagePicker() {
    final current = ref.read(aiLanguageProvider);
    _showPickerSheet(
      title: context.l10n.settingsAiOutputLanguage,
      items: aiLanguageOptions
          .map((o) => (code: o.code, name: o.name, flag: o.flag))
          .toList(),
      selected: current,
      onSelect: (code) => ref.read(aiLanguageProvider.notifier).set(code),
    );
  }

  void _showPickerSheet({
    required String title,
    required List<({String code, String name, String flag})> items,
    required String selected,
    required void Function(String code) onSelect,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.88,
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
                    final isSel = item.code == selected;
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

  // ── Theme picker ──────────────────────────────────────────────────────────

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
    final user = ref.watch(authNotifierProvider);
    final themeMode = ref.watch(themeModeProvider);
    final aiLang = ref.watch(aiLanguageProvider);
    final appLang = ref.watch(languageProvider);
    final sub = ref.watch(subscriptionProvider);

    final aiLangOpt = aiLanguageOptions.firstWhere(
      (o) => o.code == aiLang,
      orElse: () => aiLanguageOptions.first,
    );
    final appLangOpt = supportedLanguages.firstWhere(
      (l) => l.code == appLang.languageCode,
      orElse: () => supportedLanguages.first,
    );

    final l10n = context.l10n;
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

    final initial = (user?.name.isNotEmpty ?? false)
        ? user!.name[0].toUpperCase()
        : 'U';

    return Scaffold(
      backgroundColor: context.appSurface,
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        automaticallyImplyLeading: false,
        backgroundColor: context.appSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
        children: [
          // ── SECTION 1: Profile card ──────────────────────────────────────
          _Card(
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF5B5FEF), Color(0xFF9B5DE5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? l10n.profileDemoUser,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? 'demo@example.com',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.appText2,
                        ),
                      ),
                    ],
                  ),
                ),
                // Plan badge
                if (sub.plan == PlanType.proMax)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          l10n.planProMax,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (sub.isPremium)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5B5FEF), Color(0xFF9B5DE5)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.workspace_premium_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          l10n.planPro,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      l10n.profilePlanFree,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: context.appText2,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── SECTION 2: Plan card ─────────────────────────────────────────
          _Card(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: sub.plan == PlanType.proMax
                        ? const Color(0xFFF59E0B).withValues(alpha: 0.1)
                        : sub.isPremium
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    sub.plan == PlanType.proMax
                        ? Icons.star_rounded
                        : sub.isPremium
                        ? Icons.workspace_premium_rounded
                        : Icons.card_membership_rounded,
                    size: 20,
                    color: sub.plan == PlanType.proMax
                        ? const Color(0xFFF59E0B)
                        : sub.isPremium
                        ? AppColors.primary
                        : context.appText2,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            sub.plan == PlanType.proMax
                                ? l10n.profileProMaxPlan
                                : sub.isPremium
                                ? l10n.profileProPlan
                                : l10n.profilePlanFree,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (sub.isPremium) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF22C55E,
                                ).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                l10n.profilePlanActive,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF22C55E),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sub.plan == PlanType.proMax
                            ? l10n.profileUnlimitedPriority
                            : sub.isPremium
                            ? l10n.paywallFeatureUnlimited
                            : l10n.profileLimitedGenerations,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.appText2,
                        ),
                      ),
                      if (sub.plan == PlanType.proMax) ...[
                        const SizedBox(height: 2),
                        Text(
                          l10n.profilePremiumMember,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (sub.isPremium)
                  OutlinedButton(
                    onPressed: () => context.push('/paywall'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.4),
                      ),
                      foregroundColor: AppColors.primary,
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Text(l10n.profileManage),
                  )
                else
                  FilledButton(
                    onPressed: () => context.push('/soft-paywall'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      backgroundColor: AppColors.primary,
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Text(l10n.upgrade),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── SECTION 3: Settings ──────────────────────────────────────────
          _SectionLabel(l10n.settingsTitle),
          const SizedBox(height: 8),
          _Card(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _Row(
                  iconData: themeIcon,
                  iconColor: const Color(0xFF8B5CF6),
                  label: l10n.settingsAppearance,
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
                _Divider(),
                _Row(
                  iconData: Icons.language_rounded,
                  iconColor: const Color(0xFF3B82F6),
                  label: l10n.settingsLanguage,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LanguageBadge(code: appLangOpt.code, size: 22),
                      const SizedBox(width: 6),
                      Text(
                        appLangOpt.name,
                        style: TextStyle(fontSize: 13, color: context.appText2),
                      ),
                    ],
                  ),
                  onTap: _showLanguagePicker,
                ),
                _Divider(),
                _Row(
                  iconData: Icons.translate_rounded,
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
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── SECTION 4: Legal ─────────────────────────────────────────────
          _SectionLabel(l10n.profileLegal),
          const SizedBox(height: 8),
          _Card(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _Row(
                  iconData: Icons.description_outlined,
                  iconColor: const Color(0xFF6B7280),
                  label: l10n.profileEula,
                  onTap: () =>
                      launchExternalUrl(AppLinks.eula, context: context),
                ),
                _Divider(),
                _Row(
                  iconData: Icons.list_alt_rounded,
                  iconColor: const Color(0xFF6B7280),
                  label: l10n.profileTermsOfUse,
                  onTap: () =>
                      launchExternalUrl(AppLinks.terms, context: context),
                ),
                _Divider(),
                _Row(
                  iconData: Icons.shield_outlined,
                  iconColor: const Color(0xFF6B7280),
                  label: l10n.settingsPrivacy,
                  onTap: () =>
                      launchExternalUrl(AppLinks.privacy, context: context),
                ),
                _Divider(),
                _Row(
                  iconData: Icons.help_outline_rounded,
                  iconColor: const Color(0xFF6B7280),
                  label: l10n.profileHowToUse,
                  onTap: () =>
                      launchExternalUrl(AppLinks.help, context: context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── SECTION 5: Rate ──────────────────────────────────────────────
          _SectionLabel(l10n.profileRating),
          const SizedBox(height: 8),
          _Card(
            padding: EdgeInsets.zero,
            child: _Row(
              iconData: Icons.star_rounded,
              iconColor: const Color(0xFFF59E0B),
              label: l10n.profileRateAppStore,
              onTap: () =>
                  launchExternalUrl(AppLinks.appStoreReview, context: context),
            ),
          ),

          const SizedBox(height: 20),

          // ── SECTION 6: Social ────────────────────────────────────────────
          _SectionLabel(l10n.profileFollowUs),
          const SizedBox(height: 8),
          _Card(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _Row(
                  iconWidget: _SocialIcon(
                    color: const Color(0xFFE1306C),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  label: l10n.profileFollowInstagram,
                  onTap: () =>
                      launchExternalUrl(AppLinks.instagram, context: context),
                ),
                _Divider(),
                _Row(
                  iconWidget: _SocialIcon(
                    color: Colors.black,
                    child: const Icon(
                      Icons.music_note_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  label: l10n.profileFollowTikTok,
                  onTap: () =>
                      launchExternalUrl(AppLinks.tiktok, context: context),
                ),
                _Divider(),
                _Row(
                  iconWidget: _SocialIcon(
                    color: const Color(0xFF0A66C2),
                    child: const Icon(
                      Icons.business_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  label: l10n.profileFollowLinkedIn,
                  onTap: () =>
                      launchExternalUrl(AppLinks.linkedin, context: context),
                ),
                _Divider(),
                _Row(
                  iconWidget: _SocialIcon(
                    color: Colors.black,
                    child: const Text(
                      '𝕏',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  label: l10n.profileFollowX,
                  onTap: () => launchExternalUrl(AppLinks.x, context: context),
                ),
                _Divider(),
                _Row(
                  iconWidget: _SocialIcon(
                    color: const Color(0xFF5865F2),
                    child: const Icon(
                      Icons.headset_mic_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  label: l10n.profileJoinDiscord,
                  onTap: () =>
                      launchExternalUrl(AppLinks.discord, context: context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── SECTION 7: About ─────────────────────────────────────────────
          _SectionLabel(l10n.settingsAbout),
          const SizedBox(height: 8),
          _Card(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _Row(
                  iconData: Icons.info_outline_rounded,
                  iconColor: AppColors.primary,
                  label: l10n.settingsAbout,
                  subtitle: l10n.settingsAboutSubtitle,
                  onTap: () =>
                      launchExternalUrl(AppLinks.domain, context: context),
                ),
                _Divider(),
                _Row(
                  iconData: Icons.smartphone_rounded,
                  iconColor: const Color(0xFF6B7280),
                  label: l10n.settingsAppVersion,
                  trailing: Text(
                    'v1.0.0',
                    style: TextStyle(fontSize: 13, color: context.appText2),
                  ),
                  showChevron: false,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── SECTION 8: Sign Out ──────────────────────────────────────────
          _Card(
            padding: EdgeInsets.zero,
            child: _Row(
              iconData: Icons.logout_rounded,
              iconColor: AppColors.error,
              label: l10n.profileSignOut,
              labelColor: AppColors.error,
              showChevron: false,
              onTap: () async {
                await ref.read(authNotifierProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
            ),
          ),

          const SizedBox(height: 8),
          Center(
            child: Text(
              l10n.profileAppVersionFull,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: context.appText2),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Private widgets ───────────────────────────────────────────────────────────

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

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const _Card({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appBorder),
      ),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(color: context.appBorder, height: 1, indent: 56);
  }
}

class _Row extends StatelessWidget {
  final IconData? iconData;
  final Color? iconColor;
  final Widget? iconWidget;
  final String label;
  final String? subtitle;
  final Color? labelColor;
  final Widget? trailing;
  final bool showChevron;
  final VoidCallback? onTap;

  const _Row({
    this.iconData,
    this.iconColor,
    this.iconWidget,
    required this.label,
    this.subtitle,
    this.labelColor,
    this.trailing,
    this.showChevron = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIcon =
        iconWidget ??
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: (iconColor ?? context.appText2).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            iconData!,
            size: 17,
            color: iconColor ?? context.appText2,
          ),
        );

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            effectiveIcon,
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
                      style: TextStyle(fontSize: 11, color: context.appText2),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            if (showChevron && onTap != null) ...[
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
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final Color color;
  final Widget child;
  const _SocialIcon({required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(child: child),
    );
  }
}

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
