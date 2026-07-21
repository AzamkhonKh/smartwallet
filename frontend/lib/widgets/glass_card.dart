import 'package:flutter/material.dart';

/// Frosted glass card — the `withValues(alpha:0.02)` background +
/// `withValues(alpha:0.05)` border + `BorderRadius.circular(24)` pattern
/// repeated across profile, categories, home, scanner screens.
///
/// Usage:
///   GlassCard(child: myWidget)
///   GlassCard(radius: 16, padding: EdgeInsets.all(20), child: myWidget)
class GlassCard extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final Color? backgroundColor;

  const GlassCard({
    super.key,
    required this.child,
    this.radius = 24,
    this.padding = const EdgeInsets.all(0),
    this.borderColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? Colors.white.withOpacity(0.05),
        ),
      ),
      child: child,
    );
  }
}
