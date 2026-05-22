import 'package:flutter/material.dart';

/// A drag-to-compare before/after image slider.
class BeforeAfterSlider extends StatefulWidget {
  final Widget before;
  final Widget after;
  final double initialPosition;

  const BeforeAfterSlider({
    super.key,
    required this.before,
    required this.after,
    this.initialPosition = 0.5,
  });

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  late double _position;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final dividerX = w * _position;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: (d) {
            setState(() {
              _position = (_position + d.delta.dx / w).clamp(0.05, 0.95);
            });
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Before image (full) ───────────────────────────────────────
              widget.before,

              // ── After image (clipped to right portion) ────────────────────
              ClipRect(clipper: _SideClipper(_position), child: widget.after),

              // ── Divider line ──────────────────────────────────────────────
              Positioned(
                left: dividerX - 1,
                top: 0,
                bottom: 0,
                width: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Drag handle ───────────────────────────────────────────────
              Positioned(
                left: dividerX - 20,
                top: 0,
                bottom: 0,
                width: 40,
                child: Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.compare_arrows_rounded,
                      size: 20,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),

              // ── Labels ───────────────────────────────────────────────────
              Positioned(left: 10, top: 10, child: _SliderLabel('Before')),
              Positioned(right: 10, top: 10, child: _SliderLabel('After')),
            ],
          ),
        );
      },
    );
  }
}

class _SideClipper extends CustomClipper<Rect> {
  final double position;
  const _SideClipper(this.position);

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(size.width * position, 0, size.width, size.height);

  @override
  bool shouldReclip(_SideClipper old) => old.position != position;
}

class _SliderLabel extends StatelessWidget {
  final String text;
  const _SliderLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
