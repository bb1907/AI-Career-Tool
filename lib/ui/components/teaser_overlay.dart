import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Wraps [child] with a blur overlay when [isTeaser] is true.
/// The top is transparent so early content is partially visible;
/// the bottom fades to opaque white with an unlock CTA.
class TeaserOverlay extends StatelessWidget {
  final Widget child;
  final bool isTeaser;
  final String featureLabel; // e.g. "Resume", "Cover Letter"
  final String readyMessage; // e.g. "Your ATS-optimized resume is ready!"

  const TeaserOverlay({
    super.key,
    required this.child,
    required this.isTeaser,
    required this.featureLabel,
    required this.readyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (!isTeaser) return child;

    return Stack(
      children: [
        // Blurred content
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: child,
          ),
        ),
        // Gradient overlay (fades from transparent top to opaque bottom, theme-aware)
        Positioned.fill(
          child: Builder(
            builder: (context) {
              final bg = Theme.of(context).scaffoldBackgroundColor;
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.3, 1.0],
                    colors: [
                      bg.withValues(alpha: 0),
                      bg.withValues(alpha: 0.75),
                      bg,
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Lock icon + unlock button anchored to the bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Builder(
            builder: (context) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Lock icon in gradient circle
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF5B5FEF), Color(0xFF9B5DE5)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    readyMessage,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Unlock your full $featureLabel with a free trial',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Gradient unlock button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5B5FEF), Color(0xFF9B5DE5)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF5B5FEF,
                            ).withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: FilledButton(
                        onPressed: () => context.push('/soft-paywall'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Unlock with Free Trial',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.push('/soft-paywall'),
                    child: const Text(
                      'See plans →',
                      style: TextStyle(color: Color(0xFF5B5FEF), fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
