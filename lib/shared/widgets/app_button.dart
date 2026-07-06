import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum AppButtonVariant { primary, gold, outline, ghost, danger }

/// Equivalent of the React prototype's `Btn` component.
/// Five variants: primary (green gradient), gold, outline, ghost, danger.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final double fontSize;
  final Widget? icon;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.width,
    this.padding,
    this.fontSize = 15,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final disabled = onPressed == null;

    late Color bg;
    late Color fg;
    Border? border;
    Gradient? gradient;

    switch (variant) {
      case AppButtonVariant.primary:
        gradient = LinearGradient(colors: [c.green, c.greenDark]);
        bg = c.green;
        fg = Colors.white;
        break;
      case AppButtonVariant.gold:
        gradient = LinearGradient(colors: [c.gold, c.goldDark]);
        bg = c.gold;
        fg = Colors.white;
        break;
      case AppButtonVariant.outline:
        bg = c.white;
        fg = c.green;
        border = Border.all(color: c.green, width: 2);
        break;
      case AppButtonVariant.ghost:
        bg = c.surface;
        fg = c.slate;
        border = Border.all(color: c.border, width: 1);
        break;
      case AppButtonVariant.danger:
        bg = c.redLight;
        fg = c.red;
        border = Border.all(color: c.red.withOpacity(0.3), width: 1);
        break;
    }

    return Opacity(
      opacity: disabled ? 0.45 : 1,
      child: SizedBox(
        width: width,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(13),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(13),
            child: Container(
              padding: padding ?? const EdgeInsets.symmetric(vertical: 13, horizontal: 20),
              decoration: BoxDecoration(
                gradient: gradient,
                color: gradient == null ? bg : null,
                borderRadius: BorderRadius.circular(13),
                border: border,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[icon!, const SizedBox(width: 8)],
                  Text(
                    label,
                    style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: fontSize),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
