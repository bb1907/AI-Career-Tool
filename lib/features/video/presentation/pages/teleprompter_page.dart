import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/core/l10n_extension.dart';
import '../../../../app/theme/app_theme.dart';

class TeleprompterPage extends StatefulWidget {
  final String scriptText;
  const TeleprompterPage({super.key, required this.scriptText});

  @override
  State<TeleprompterPage> createState() => _TeleprompterPageState();
}

class _TeleprompterPageState extends State<TeleprompterPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isPlaying = false;
  double _fontSize = 20.0;
  double _scrollSpeed = 1.0;
  bool _isMirrored = false;
  int? _countdown; // null = no countdown, 3/2/1 = counting
  Timer? _scrollTimer;
  Timer? _countdownTimer;

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _countdownTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    setState(() => _countdown = 3);
    int count = 3;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      count--;
      if (count <= 0) {
        t.cancel();
        setState(() => _countdown = null);
        _startScrolling();
      } else {
        setState(() => _countdown = count);
      }
    });
  }

  void _startScrolling() {
    setState(() => _isPlaying = true);
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      if (!_scrollController.hasClients) return;
      final maxScroll = _scrollController.position.maxScrollExtent;
      final current = _scrollController.offset;
      final increment = _scrollSpeed * 0.8;
      if (current >= maxScroll) {
        t.cancel();
        setState(() => _isPlaying = false);
      } else {
        _scrollController.jumpTo((current + increment).clamp(0, maxScroll));
      }
    });
  }

  void _pause() {
    _scrollTimer?.cancel();
    setState(() => _isPlaying = false);
  }

  void _restart() {
    _scrollTimer?.cancel();
    _countdownTimer?.cancel();
    setState(() {
      _isPlaying = false;
      _countdown = null;
    });
    _scrollController.jumpTo(0);
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _pause();
    } else if (_countdown == null) {
      _startCountdown();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scriptToShow = widget.scriptText.isNotEmpty
        ? widget.scriptText
        : 'No script loaded. Generate a script first and tap "Practice with Teleprompter".';

    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        foregroundColor: Colors.white,
        title: Text(
          context.l10n.teleprompterTitle,
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Camera preview placeholder
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1F2937), Color(0xFF111827)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.videocam_rounded,
                        size: 48,
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Camera Preview',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                    ],
                  ),
                  // Countdown overlay
                  if (_countdown != null)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        key: ValueKey(_countdown),
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.85),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$_countdown',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Script scroll area
          Expanded(
            flex: 5,
            child: GestureDetector(
              onTap: _togglePlayPause,
              child: Container(
                width: double.infinity,
                color: const Color(0xFF0D1117),
                child: Transform(
                  alignment: Alignment.center,
                  transform: _isMirrored
                      ? (Matrix4.identity()..scaleByDouble(-1.0, 1.0, 1.0, 1.0))
                      : Matrix4.identity(),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.xxl,
                    ),
                    child: Text(
                      scriptToShow,
                      style: TextStyle(
                        fontSize: _fontSize,
                        color: Colors.white,
                        height: 1.7,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Controls
          Container(
            color: const Color(0xFF1F2937),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Font size slider
                  Row(
                    children: [
                      Icon(
                        Icons.text_fields_rounded,
                        size: 16,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                      Expanded(
                        child: Slider(
                          value: _fontSize,
                          min: 12,
                          max: 28,
                          divisions: 16,
                          activeColor: AppColors.primary,
                          inactiveColor: Colors.white.withValues(alpha: 0.2),
                          onChanged: (v) => setState(() => _fontSize = v),
                        ),
                      ),
                      Text(
                        '${_fontSize.round()}sp',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  // Speed slider
                  Row(
                    children: [
                      Icon(
                        Icons.speed_rounded,
                        size: 16,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                      Expanded(
                        child: Slider(
                          value: _scrollSpeed,
                          min: 0.3,
                          max: 3.0,
                          divisions: 27,
                          activeColor: AppColors.accent,
                          inactiveColor: Colors.white.withValues(alpha: 0.2),
                          onChanged: (v) => setState(() => _scrollSpeed = v),
                        ),
                      ),
                      Text(
                        context.l10n.teleprompterSpeed,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  // Control buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Mirror
                      IconButton(
                        icon: Icon(
                          Icons.flip_rounded,
                          color: _isMirrored
                              ? AppColors.accent
                              : Colors.white.withValues(alpha: 0.7),
                        ),
                        onPressed: () =>
                            setState(() => _isMirrored = !_isMirrored),
                        tooltip: context.l10n.teleprompterMirror,
                      ),
                      // Restart
                      IconButton(
                        icon: Icon(
                          Icons.replay_rounded,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                        onPressed: _restart,
                        tooltip: 'Restart',
                      ),
                      // Play / Pause
                      GestureDetector(
                        onTap: _togglePlayPause,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                      // Placeholder spacers for symmetry
                      const SizedBox(width: 48),
                      const SizedBox(width: 48),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
