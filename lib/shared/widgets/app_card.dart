import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Equivalent of the React prototype's `Card` component.
/// White (or dark-surface) container with border radius 16 and a 1px border.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final Border? customBorder;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.customBorder,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? c.white,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border: customBorder ?? Border.all(color: borderColor ?? c.border, width: 1),
      ),
      child: child,
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: card,
      ),
    );
  }
}

/// A card with a coloured left accent border (used for alerts, status cards).
class AccentCard extends StatelessWidget {
  final Widget child;
  final Color accentColor;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;

  const AccentCard({
    super.key,
    required this.child,
    required this.accentColor,
    this.backgroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? c.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          top: BorderSide(color: c.border, width: 1),
          right: BorderSide(color: c.border, width: 1),
          bottom: BorderSide(color: c.border, width: 1),
          left: BorderSide(color: accentColor, width: 4),
        ),
      ),
      child: child,
    );
  }
}
