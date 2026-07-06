import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/app_routes.dart';

/// The persistent bottom navigation bar.
/// Mirrors NAV_TABS in the prototype: Home, MoMo, Float, Market, More.
/// Wrap each top-level tab's Navigator in an IndexedStack via [AppShell].
class AppShell extends StatefulWidget {
  final Widget Function(int index) screenBuilder;

  const AppShell({super.key, required this.screenBuilder});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _tabs = [
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.account_balance_wallet_rounded, label: 'MoMo'),
    (icon: Icons.bar_chart_rounded, label: 'Float'),
    (icon: Icons.storefront_rounded, label: 'Market'),
    (icon: Icons.more_horiz_rounded, label: 'More'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: List.generate(_tabs.length, (i) => widget.screenBuilder(i)),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: c.white,
          border: Border(top: BorderSide(color: c.border, width: 1)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final tab = _tabs[i];
                final active = _index == i;
                return Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _index = i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(tab.icon, size: 22, color: active ? c.green : c.muted),
                        const SizedBox(height: 2),
                        Text(
                          tab.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: active ? FontWeight.w800 : FontWeight.w400,
                            color: active ? c.green : c.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
