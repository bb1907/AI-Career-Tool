import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/core/l10n_extension.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  static const String _termsUrl = 'https://aicareercopilot.com/terms';
  static const String _privacyUrl = 'https://aicareercopilot.com/privacy';

  bool _loading = false;
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () => _openUrl(_termsUrl);
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () => _openUrl(_privacyUrl);
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      _showError(context.l10n.errorGeneric);
    }
  }

  Future<void> _signInWithGoogle() async {
    await _performSignIn(
      () => ref.read(authNotifierProvider.notifier).signInWithGoogle(),
    );
  }

  Future<void> _signInWithApple() async {
    await _performSignIn(
      () => ref.read(authNotifierProvider.notifier).signInWithApple(),
    );
  }

  Future<void> _performSignIn(Future<void> Function() signIn) async {
    setState(() => _loading = true);
    try {
      await signIn();
      if (!mounted) return;
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      final onboardingDone = prefs.getBool('onboarding_complete') ?? false;
      context.go(onboardingDone ? '/home' : '/onboarding');
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.badge),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final isDark = context.isDark;
    final l10n = context.l10n;

    final sheetColor = isDark ? AppColors.darkSurface : Colors.white;
    final titleColor = context.appText1;
    final subtitleColor = context.appText2;
    final termsColor = isDark ? AppColors.darkText2 : const Color(0xFF9CA3AF);

    return Scaffold(
      body: Stack(
        children: [
          // ── Top gradient (upper ~55% of screen) ──────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.58,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4A4EDE), Color(0xFF9B5DE5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // ── BG color for bottom ───────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: size.height * 0.5,
            child: Container(color: sheetColor),
          ),

          // ── Main content ──────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Logo area (on gradient)
                Expanded(
                  flex: 5,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Glow behind logo
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.25),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              size: 46,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Bottom sheet ──────────────────────────────────────
                Expanded(
                  flex: 7,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: sheetColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(28, 32, 28, 24 + bottomPad),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title
                        Text(
                          l10n.loginTitle,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                            height: 1.2,
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          l10n.loginSubtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: subtitleColor,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Google button
                        _SocialButton(
                          onTap: _loading ? null : _signInWithGoogle,
                          icon: const _GoogleIcon(),
                          label: l10n.loginContinueWithGoogle,
                          loading: _loading,
                        ),

                        const SizedBox(height: 12),

                        // Apple button (only on iOS)
                        if (Platform.isIOS)
                          _SocialButton(
                            onTap: _loading ? null : _signInWithApple,
                            icon: const _AppleIcon(),
                            label: l10n.loginContinueWithApple,
                            loading: _loading,
                          ),

                        const Spacer(),

                        // Terms
                        Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 12,
                                color: termsColor,
                                height: 1.5,
                              ),
                              children: [
                                TextSpan(text: l10n.loginAgreePrefix),
                                TextSpan(
                                  text: l10n.loginTermsOfService,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  recognizer: _termsRecognizer,
                                ),
                                TextSpan(text: l10n.loginAgreeAnd),
                                TextSpan(
                                  text: l10n.loginPrivacyPolicy,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  recognizer: _privacyRecognizer,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Social button
// ─────────────────────────────────────────────────────────────────────────────

class _SocialButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget icon;
  final String label;
  final bool loading;

  const _SocialButton({
    required this.onTap,
    required this.icon,
    required this.label,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bgColor = isDark ? Colors.white : const Color(0xFF111827);
    final textColor = isDark ? const Color(0xFF111827) : Colors.white;
    final spinnerColor = isDark ? const Color(0xFF111827) : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: onTap == null ? 0.6 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: spinnerColor,
                    strokeWidth: 2,
                  ),
                )
              else ...[
                icon,
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Google "G" icon (colored)
// ─────────────────────────────────────────────────────────────────────────────

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GoogleGPainter()),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // Blue arc (top-right)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -1.57,
      1.57,
      false,
      Paint()
        ..color = const Color(0xFF4285F4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.38,
    );
    // Red arc (top-left)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -3.14,
      1.57,
      false,
      Paint()
        ..color = const Color(0xFFEA4335)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.38,
    );
    // Yellow arc (bottom-left)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      1.57,
      0.79,
      false,
      Paint()
        ..color = const Color(0xFFFBBC05)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.38,
    );
    // Green arc (bottom-right)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      2.36,
      0.78,
      false,
      Paint()
        ..color = const Color(0xFF34A853)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.38,
    );
    // Right horizontal bar of the G
    canvas.drawRect(
      Rect.fromLTWH(cx, cy - r * 0.19, r * 0.95, r * 0.38),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Apple icon (SF Symbol on iOS)
// ─────────────────────────────────────────────────────────────────────────────

class _AppleIcon extends StatelessWidget {
  const _AppleIcon();

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Icon(
      Icons.apple,
      size: 22,
      color: isDark ? const Color(0xFF111827) : Colors.white,
    );
  }
}
