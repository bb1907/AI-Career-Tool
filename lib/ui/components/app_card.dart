import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';

/// General-purpose surface card with adaptive dark mode support.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final bool showBorder;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? context.appSurface;

    final container = Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: showBorder ? Border.all(color: context.appBorder) : null,
        boxShadow: AppShadows.card(context),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppTheme.cardPadding),
        child: child,
      ),
    );

    if (onTap == null) return container;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: container,
      ),
    );
  }
}
