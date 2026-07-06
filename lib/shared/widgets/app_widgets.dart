import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Small pill-shaped status badge. Equivalent of prototype `Badge`.
class AppBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color? backgroundColor;

  const AppBadge({
    super.key,
    required this.label,
    required this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 0.3),
      ),
    );
  }
}

/// Labelled text field. Equivalent of prototype `Input`.
class AppTextField extends StatelessWidget {
  final String? label;
  final TextEditingController? controller;
  final String? placeholder;
  final TextInputType keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final int maxLines;

  const AppTextField({
    super.key,
    this.label,
    this.controller,
    this.placeholder,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.onChanged,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: c.slate,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 5),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: obscureText ? 1 : maxLines,
          onChanged: onChanged,
          style: TextStyle(fontSize: 14, color: c.charcoal),
          decoration: InputDecoration(hintText: placeholder),
        ),
      ],
    );
  }
}

/// Top app bar matching the prototype's `TopBar`: title + optional back + trailing widget.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  const AppTopBar({super.key, required this.title, this.onBack, this.trailing});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: onBack != null
          ? IconButton(icon: const Icon(Icons.arrow_back, size: 20), onPressed: onBack)
          : null,
      automaticallyImplyLeading: onBack != null,
      title: Text(title),
      actions: trailing != null ? [trailing!, const SizedBox(width: 12)] : null,
    );
  }
}

/// Horizontal scrollable tab row matching the prototype's `Tabs` component.
class AppTabs extends StatelessWidget {
  final List<String> tabs;
  final String active;
  final ValueChanged<String> onChanged;

  const AppTabs({super.key, required this.tabs, required this.active, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.white,
        border: Border(bottom: BorderSide(color: c.border, width: 1)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.map((t) {
            final isActive = t == active;
            return InkWell(
              onTap: () => onChanged(t),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: isActive ? c.green : Colors.transparent, width: 2),
                  ),
                ),
                child: Text(
                  t,
                  style: TextStyle(
                    color: isActive ? c.green : c.muted,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
