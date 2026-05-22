import 'dart:async';
import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';

/// Raycast-inspired step-by-step AI loading indicator.
/// Pass [messages] and it cycles through them as steps.
class AiLoadingIndicator extends StatefulWidget {
  final List<String> messages;

  const AiLoadingIndicator({super.key, required this.messages});

  @override
  State<AiLoadingIndicator> createState() => _AiLoadingIndicatorState();
}

class _AiLoadingIndicatorState extends State<AiLoadingIndicator>
    with SingleTickerProviderStateMixin {
  int _step = 0;
  Timer? _timer;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _timer = Timer.periodic(const Duration(milliseconds: 1400), (t) {
      if (!mounted) return;
      if (_step < widget.messages.length - 1) {
        setState(() => _step++);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pulsing icon
        ScaleTransition(
          scale: Tween<double>(
            begin: 0.88,
            end: 1.0,
          ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut)),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        Text(
          'Generating with AI',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Step list
        ...widget.messages.asMap().entries.map((e) {
          final i = e.key;
          final msg = e.value;
          final done = i < _step;
          final active = i == _step;

          return AnimatedOpacity(
            opacity: i > _step ? 0.3 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: done
                        ? const Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: AppColors.success,
                          )
                        : active
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary.withValues(alpha: 0.8),
                            ),
                          )
                        : Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFD1D5DB),
                            ),
                          ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    msg,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: active ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
