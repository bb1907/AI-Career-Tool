import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../ui/components/app_card.dart';
import '../../../../ui/components/teaser_overlay.dart';
import '../widgets/before_after_slider.dart';

// ---------------------------------------------------------------------------
// Data passed via router extra
// ---------------------------------------------------------------------------

class PhotoResultData {
  final String originalImagePath;
  final Uint8List resultImageBytes;
  final String jobType;
  final String outfitDescription;
  final int qualityScore;
  final bool isPremium;
  final bool isTeaser;

  const PhotoResultData({
    required this.originalImagePath,
    required this.resultImageBytes,
    required this.jobType,
    required this.outfitDescription,
    required this.qualityScore,
    this.isPremium = false,
    this.isTeaser = false,
  });
}

// ---------------------------------------------------------------------------
// Result page
// ---------------------------------------------------------------------------

class AiPhotoResultPage extends ConsumerStatefulWidget {
  final PhotoResultData data;

  const AiPhotoResultPage({super.key, required this.data});

  @override
  ConsumerState<AiPhotoResultPage> createState() => _AiPhotoResultPageState();
}

class _AiPhotoResultPageState extends ConsumerState<AiPhotoResultPage> {
  bool _savedToProfile = false;
  bool _downloading = false;

  Color get _scoreColor {
    final s = widget.data.qualityScore;
    if (s >= 90) return AppColors.success;
    if (s >= 75) return AppColors.warning;
    return AppColors.primary;
  }

  String get _scoreLabel {
    final s = widget.data.qualityScore;
    if (s >= 90) return 'Excellent';
    if (s >= 75) return 'Great';
    return 'Good';
  }

  Future<void> _download() async {
    setState(() => _downloading = true);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'ai_photo_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(widget.data.resultImageBytes);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Photo saved to documents!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not save photo.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _downloading = false);
    }
  }

  void _saveToProfile() {
    // TODO: wire to profile photo provider
    setState(() => _savedToProfile = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Saved as your profile photo!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _share() async {
    await Clipboard.setData(
      const ClipboardData(
        text: 'Check out my AI-generated professional photo!',
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Link copied to clipboard'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    return Scaffold(
      backgroundColor: context.appBG,
      appBar: AppBar(
        backgroundColor: context.appSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Your Professional Look',
          style: TextStyle(
            color: context.appText1,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: _share,
            tooltip: 'Share',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: context.appBorder),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Before / After slider ─────────────────────────────────────
            AspectRatio(
              aspectRatio: 1.0,
              child: TeaserOverlay(
                isTeaser: data.isTeaser,
                featureLabel: 'AI Photo',
                readyMessage: 'Your professional headshot is ready!',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    BeforeAfterSlider(
                      before: Image.file(
                        File(data.originalImagePath),
                        fit: BoxFit.cover,
                      ),
                      after: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.memory(
                            data.resultImageBytes,
                            fit: BoxFit.cover,
                          ),
                          // Watermark for free users
                          if (!data.isPremium)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.7),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                                child: Text(
                                  'AI Career Copilot • Upgrade to remove watermark',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Slide hint
                    Positioned(
                      bottom: data.isPremium ? 12 : 44,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '← Drag to compare →',
                            style: TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Score + outfit info ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: AppCard(
                child: Row(
                  children: [
                    // Score ring
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: data.qualityScore / 100,
                            strokeWidth: 6,
                            backgroundColor: _scoreColor.withValues(
                              alpha: 0.15,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _scoreColor,
                            ),
                          ),
                          Center(
                            child: Text(
                              '${data.qualityScore}',
                              style: TextStyle(
                                color: _scoreColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _scoreLabel,
                                style: TextStyle(
                                  color: _scoreColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _scoreColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'AI Quality',
                                  style: TextStyle(
                                    color: _scoreColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data.jobType,
                            style: TextStyle(
                              color: context.appText1,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            data.outfitDescription,
                            style: TextStyle(
                              color: context.appText2,
                              fontSize: 12,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Premium banner (for free users) ──────────────────────────
            if (!data.isPremium)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: GestureDetector(
                  onTap: () => context.push('/paywall'),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5B5FEF), Color(0xFF9B5DE5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.card),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Upgrade to Premium',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              const Text(
                                'Unlimited photos • No watermark • HD quality',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ── Action buttons ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.xxl,
              ),
              child: Column(
                children: [
                  // Save to profile
                  FilledButton.icon(
                    onPressed: _savedToProfile ? null : _saveToProfile,
                    icon: Icon(
                      _savedToProfile
                          ? Icons.check_circle_rounded
                          : Icons.person_rounded,
                      size: 18,
                    ),
                    label: Text(
                      _savedToProfile ? 'Saved to Profile!' : 'Save to Profile',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: _savedToProfile
                          ? AppColors.success
                          : AppColors.primary,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.button),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Download + Share row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _downloading ? null : _download,
                          icon: _downloading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.download_rounded, size: 18),
                          label: Text(_downloading ? 'Saving...' : 'Download'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 50),
                            side: BorderSide(color: AppColors.primary),
                            foregroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadius.button,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _share,
                          icon: const Icon(Icons.share_rounded, size: 18),
                          label: const Text('Share'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 50),
                            side: BorderSide(color: AppColors.primary),
                            foregroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadius.button,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Try another style
                  TextButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.style_rounded, size: 18),
                    label: const Text('Try Another Style'),
                    style: TextButton.styleFrom(
                      foregroundColor: context.appText2,
                      minimumSize: const Size(double.infinity, 44),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
