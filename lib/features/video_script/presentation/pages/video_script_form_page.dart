import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/core/l10n_extension.dart';
import '../../../../services/ai/ai_router.dart';
import '../../../../services/privacy/consent_guard.dart';
import '../../../../services/subscription/subscription_provider.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/widgets/ai_loading_dialog.dart';
import '../../domain/video_script.dart';

class VideoScriptFormPage extends ConsumerStatefulWidget {
  const VideoScriptFormPage({super.key});

  @override
  ConsumerState<VideoScriptFormPage> createState() =>
      _VideoScriptFormPageState();
}

class _VideoScriptFormPageState extends ConsumerState<VideoScriptFormPage> {
  final _roleController = TextEditingController();
  final _achievementController = TextEditingController();
  String _duration = '60s';
  String _tone = 'confident';
  bool _isGenerating = false;

  @override
  void dispose() {
    _roleController.dispose();
    _achievementController.dispose();
    super.dispose();
  }

  String _generateScript() {
    final role = _roleController.text.trim().isNotEmpty
        ? _roleController.text.trim()
        : 'professional';
    final achievement = _achievementController.text.trim();

    final wordTarget = _duration == '30s'
        ? 75
        : _duration == '60s'
        ? 150
        : 225;

    final toneOpener = switch (_tone) {
      'formal' =>
        'Good day. I am a dedicated $role with a proven track record of delivering exceptional results.',
      'casual' =>
        "Hey there! I'm a passionate $role who loves solving real-world problems with clean, effective solutions.",
      _ =>
        "Hi, I'm an experienced $role who brings both technical excellence and strong leadership to every project.",
    };

    final achievementLine = achievement.isNotEmpty
        ? 'One of my proudest achievements: $achievement. '
        : '';

    final closingByTone = switch (_tone) {
      'formal' =>
        'I am eager to bring this level of dedication to your organisation and would welcome the opportunity to discuss further.',
      'casual' =>
        "I'd love to bring this energy to your team — let's connect and see if we'd be a great fit!",
      _ =>
        "I'm ready to hit the ground running and make an immediate impact on your team.",
    };

    final scripts = {
      '30s':
          "$toneOpener ${achievementLine}I'm excited about bringing my expertise to the right team. $closingByTone",
      '60s':
          '''$toneOpener

${achievementLine}Throughout my career, I've consistently delivered high-quality results while collaborating effectively with cross-functional teams. I combine deep technical knowledge with strong communication skills to bridge the gap between complex problems and practical solutions.

$closingByTone''',
      '90s':
          '''$toneOpener

${achievementLine}Throughout my career, I've consistently delivered high-quality results while collaborating effectively with cross-functional teams. I combine deep technical knowledge with strong communication skills to bridge the gap between complex problems and practical solutions.

What sets me apart is my ability to adapt quickly to new challenges and drive initiatives from conception to launch. I'm passionate about continuous learning and staying at the forefront of my field.

$closingByTone''',
    };

    String script = scripts[_duration] ?? scripts['60s']!;

    // Trim to approximate word count
    final words = script.split(' ');
    if (words.length > wordTarget + 20) {
      script = '${words.take(wordTarget).join(' ')}...';
    }

    return script;
  }

  Future<void> _onGenerate() async {
    if (_roleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.videoScriptEnterRole)),
      );
      return;
    }
    if (!await ensureAiDataConsent(context, ref)) return;

    // Compute teaser flag BEFORE recordUsage (first gen free, 2nd+ teaser)
    final isTeaser = ref
        .read(subscriptionProvider)
        .shouldShowTeaser(FeatureType.videoScript);

    setState(() => _isGenerating = true);
    showAiLoading(
      context,
      messages: [
        context.l10n.aiLoadingAnalyzingProfile,
        context.l10n.aiLoadingCraftingIntro,
        context.l10n.aiLoadingPolishingScript,
      ],
    );

    String text;
    try {
      final router = ref.read(aiRouterProvider);
      if (router.hasAnyProvider) {
        text = await router.generateVideoScript(
          role: _roleController.text.trim(),
          duration: _duration,
          tone: _tone,
          keySkills: _achievementController.text.trim().isNotEmpty
              ? _achievementController.text.trim()
              : null,
        );
      } else {
        await Future.delayed(const Duration(milliseconds: 3200));
        text = _generateScript();
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Generation failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final script = VideoScript(
      id: const Uuid().v4(),
      durationType: _duration,
      scriptText: text,
      tone: _tone,
      createdAt: DateTime.now(),
    );

    if (!mounted) return;
    Navigator.of(context).pop();
    setState(() => _isGenerating = false);
    await ref
        .read(subscriptionProvider.notifier)
        .recordUsage(FeatureType.videoScript);
    if (!mounted) return;
    context.push(
      '/video-script/result',
      extra: {'script': script, 'isTeaser': isTeaser},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.videoScriptTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.cardPadding),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadius.card),
                boxShadow: AppShadows.elevated(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.video_camera_front_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    context.l10n.videoScriptHeroTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    context.l10n.videoScriptHeroSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Target role
            TextFormField(
              controller: _roleController,
              decoration: InputDecoration(
                labelText: context.l10n.videoScriptTargetRole,
                hintText: context.l10n.videoScriptTargetRoleHint,
                prefixIcon: const Icon(Icons.work_outline_rounded),
              ),
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: AppSpacing.lg),

            Text(
              context.l10n.videoScriptDuration,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.sm),
            Consumer(
              builder: (context, ref, _) {
                final allowed = ref
                    .watch(subscriptionProvider)
                    .allowedVideoDurations;
                final isProMax = allowed.length == 3;
                return SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: '30s',
                      label: Text(context.l10n.videoScript30s),
                    ),
                    ButtonSegment(
                      value: '60s',
                      label: Text(context.l10n.videoScript60s),
                      enabled: isProMax,
                    ),
                    ButtonSegment(
                      value: '90s',
                      label: Text(context.l10n.videoScript90s),
                      enabled: isProMax,
                    ),
                  ],
                  selected: {_duration},
                  onSelectionChanged: (s) =>
                      setState(() => _duration = s.first),
                );
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            Text(
              context.l10n.videoScriptTone,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'formal',
                  label: Text(context.l10n.chatVideoChipFormal),
                ),
                ButtonSegment(
                  value: 'casual',
                  label: Text(context.l10n.chatVideoChipCasual),
                ),
                ButtonSegment(
                  value: 'confident',
                  label: Text(context.l10n.chatVideoChipConfident),
                ),
              ],
              selected: {_tone},
              onSelectionChanged: (s) => setState(() => _tone = s.first),
            ),

            const SizedBox(height: AppSpacing.lg),

            TextFormField(
              controller: _achievementController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: context.l10n.videoScriptKeyAchievement,
                hintText: context.l10n.videoScriptKeyAchievementHint,
                alignLabelWithHint: true,
              ),
              textInputAction: TextInputAction.done,
            ),

            const SizedBox(height: AppSpacing.xl),

            FilledButton.icon(
              onPressed: _isGenerating ? null : _onGenerate,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: Text(context.l10n.videoScriptGenerate),
            ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
