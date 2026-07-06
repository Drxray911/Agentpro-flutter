import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/app_providers.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_widgets.dart';

/// Port of the prototype's Agent DashboardScreen.
/// Shows float stats, eCash wallet card, quick actions, today's targets,
/// USSD quick dialler, and recent transactions.
///
/// NOTE: For Manager / Owner / Auditor roles, the spec calls for separate
/// dashboard widgets (ManagerDashboard, OwnerDashboard, AuditorDashboard).
/// Wire role-based switching at the router level using [currentRoleProvider].
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const _recentTxns = [
    (name: 'Ama Boateng', type: 'Cash In', amount: '+GH₵ 500', provider: 'MTN', time: '10:42 AM', ok: true),
    (name: 'Kofi Mensah', type: 'Cash Out', amount: '-GH₵ 300', provider: 'Telecel', time: '10:15 AM', ok: true),
    (name: 'ECG Prepaid', type: 'Bill Payment', amount: '-GH₵ 150', provider: 'AT Money', time: '9:58 AM', ok: false),
    (name: 'Akua Sarpong', type: 'Send Money', amount: '-GH₵ 800', provider: 'MTN', time: '9:30 AM', ok: true),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final userName = ref.watch(currentUserNameProvider);
    final role = ref.watch(currentRoleProvider);

    return Scaffold(
      backgroundColor: c.surface,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(userName: userName, roleLabel: role.label),
            Padding(
              padding: const EdgeInsets.all(13),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _StatTile(label: "TODAY'S FLOAT", value: 'GH₵ 4,820', sub: '↑ 12% vs yesterday', valueColor: c.green)),
                      const SizedBox(width: 10),
                      Expanded(child: _StatTile(label: 'COMMISSION', value: 'GH₵ 237', sub: '18 transactions', valueColor: c.gold)),
                    ],
                  ),
                  const SizedBox(height: 13),
                  const _TodayTargetCard(),
                  const SizedBox(height: 13),
                  _QuickActionsCard(),
                  const SizedBox(height: 13),
                  const _ECashWalletCard(),
                  const SizedBox(height: 13),
                  AccentCard(
                    accentColor: c.red,
                    backgroundColor: c.redLight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('⚠ Alerts (3)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: c.red)),
                        const SizedBox(height: 5),
                        Text(
                          '• MTN float below GH₵ 2,500 threshold\n• 2 advertisement approvals pending\n• Subscription renews in 50 days',
                          style: TextStyle(fontSize: 12, color: c.slate, height: 1.8),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 13),
                  const _QuickUssdDialer(),
                  const SizedBox(height: 13),
                  _RecentTransactionsCard(transactions: _recentTxns),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ───────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final String userName;
  final String roleLabel;
  const _Header({required this.userName, required this.roleLabel});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.greenDark, c.green],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Good morning', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7))),
                    const SizedBox(height: 2),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed('/profile'),
                      child: Text(userName, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: Colors.white)),
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 6,
                      children: [
                        AppBadge(label: roleLabel, color: c.gold, backgroundColor: c.gold.withOpacity(0.3)),
                        AppBadge(label: 'Accra Central', color: const Color(0xFF7EFFC5), backgroundColor: const Color(0xFF7EFFC5).withOpacity(0.12)),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _HeaderIconButton(
                    icon: Icons.person,
                    onTap: () => Navigator.of(context).pushNamed('/profile'),
                  ),
                  const SizedBox(width: 8),
                  Stack(
                    children: [
                      _HeaderIconButton(
                        icon: Icons.notifications_rounded,
                        onTap: () => Navigator.of(context).pushNamed(AppRoutes.notifications),
                      ),
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: c.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: c.green, width: 2),
                          ),
                          alignment: Alignment.center,
                          child: const Text('3', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.13),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                    children: const [
                      TextSpan(text: 'Business Plan · Expires '),
                      TextSpan(text: 'Aug 15, 2026', style: TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                AppBadge(label: 'Active ✓', color: c.gold, backgroundColor: c.gold.withOpacity(0.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }
}

// ── Stat tile ────────────────────────────────────────────────────────
class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color valueColor;
  const _StatTile({required this.label, required this.value, required this.sub, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: c.muted, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: valueColor)),
          const SizedBox(height: 2),
          Text(sub, style: TextStyle(fontSize: 11, color: c.muted)),
        ],
      ),
    );
  }
}

// ── Today's target widget ───────────────────────────────────────────
class _TodayTargetCard extends StatelessWidget {
  const _TodayTargetCard();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    const target = 50, actual = 18, volTarget = 20000, volActual = 12400;
    final pct = ((actual / target) * 100).round();
    final volPct = ((volActual / volTarget) * 100).round();

    Color barColor(int p) => p >= 100 ? c.green : (p >= 60 ? c.gold : c.red);

    Widget bar(String label, int pct, String suffix) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                Text('$suffix ($pct%)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: barColor(pct))),
              ],
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: (pct / 100).clamp(0, 1),
                minHeight: 8,
                backgroundColor: c.border,
                color: barColor(pct),
              ),
            ),
          ],
        ),
      );
    }

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('🎯 Today\'s Targets', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              TextButton(
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.reports),
                child: const Text('Details →'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          bar('Transactions', pct, '$actual/$target'),
          bar('Volume', volPct, 'GH₵${(volActual / 1000).toStringAsFixed(1)}k/GH₵${(volTarget / 1000).toStringAsFixed(0)}k'),
        ],
      ),
    );
  }
}

// ── Quick actions grid ──────────────────────────────────────────────
class _QuickActionsCard extends StatelessWidget {
  static const _actions = [
    (icon: Icons.south_west_rounded, label: 'Cash In', route: AppRoutes.momo),
    (icon: Icons.north_east_rounded, label: 'Cash Out', route: AppRoutes.momo),
    (icon: Icons.send_rounded, label: 'Send', route: AppRoutes.momo),
    (icon: Icons.bar_chart_rounded, label: 'Float', route: AppRoutes.float),
    (icon: Icons.swap_horiz_rounded, label: 'eCash', route: AppRoutes.ecash),
    (icon: Icons.dialpad_rounded, label: 'USSD', route: AppRoutes.ussd),
    (icon: Icons.storefront_rounded, label: 'Market', route: AppRoutes.market),
    (icon: Icons.bar_chart_rounded, label: 'Reports', route: AppRoutes.reports),
    (icon: Icons.smart_toy_rounded, label: 'AI Help', route: AppRoutes.ai),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.95,
            children: _actions.map((a) {
              return InkWell(
                onTap: () => Navigator.of(context).pushNamed(a.route),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: c.surface,
                    border: Border.all(color: c.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(a.icon, size: 22, color: c.slate),
                      const SizedBox(height: 4),
                      Text(a.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c.slate)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── eCash wallet card ────────────────────────────────────────────────
class _ECashWalletCard extends StatelessWidget {
  const _ECashWalletCard();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [c.purple, const Color(0xFF5B21B6)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ECASH WALLET', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.8))),
                const SizedBox(height: 4),
                const Text('GH₵ 1,250.00', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 2),
                Text('ID: APG-KA-00421', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.75))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _PillButton(label: 'Send →', onTap: () => Navigator.of(context).pushNamed(AppRoutes.ecash)),
              const SizedBox(height: 6),
              _PillButton(label: 'Receive', outlined: true, onTap: () => Navigator.of(context).pushNamed(AppRoutes.ecash)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool outlined;
  const _PillButton({required this.label, required this.onTap, this.outlined = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(outlined ? 0.15 : 0.2),
          border: outlined ? Border.all(color: Colors.white.withOpacity(0.3)) : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(color: Colors.white, fontWeight: outlined ? FontWeight.w600 : FontWeight.w700, fontSize: outlined ? 11 : 12)),
      ),
    );
  }
}

// ── Quick USSD dialer ────────────────────────────────────────────────
class _QuickUssdDialer extends StatefulWidget {
  const _QuickUssdDialer();

  @override
  State<_QuickUssdDialer> createState() => _QuickUssdDialerState();
}

class _QuickUssdDialerState extends State<_QuickUssdDialer> {
  bool _expanded = false;
  String _input = '';

  static const _providers = [('MTN', '*170#'), ('Telecel', '*110#'), ('AT', '*500#')];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    if (!_expanded) {
      return AppCard(
        onTap: () => setState(() => _expanded = true),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('📟', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Quick USSD', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    Text('Dial *170# · *110# · *500# fast', style: TextStyle(fontSize: 11, color: c.muted)),
                  ],
                ),
              ],
            ),
            Icon(Icons.chevron_right, color: c.muted),
          ],
        ),
      );
    }

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('📟 Quick Dial', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => setState(() {
                  _expanded = false;
                  _input = '';
                }),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: c.charcoal, borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.only(bottom: 12),
            child: Text(
              _input.isEmpty ? '*170#' : _input,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _input.isEmpty ? Colors.white.withOpacity(0.4) : const Color(0xFF7EFFC5),
                letterSpacing: 2,
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            children: _providers.map((p) {
              return ActionChip(
                label: Text(p.$1, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                onPressed: () => setState(() => _input = p.$2),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _input = _input.isEmpty ? '' : _input.substring(0, _input.length - 1)),
                  child: const Text('⌫'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: c.green),
                  onPressed: () {
                    setState(() => _expanded = false);
                    Navigator.of(context).pushNamed(AppRoutes.ussd);
                  },
                  child: const Text('Dial & Open USSD'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Recent transactions ──────────────────────────────────────────────
class _RecentTransactionsCard extends StatelessWidget {
  final List<({String name, String type, String amount, String provider, String time, bool ok})> transactions;
  const _RecentTransactionsCard({required this.transactions});

  IconData _iconFor(String type) {
    switch (type) {
      case 'Cash In':
        return Icons.south_west_rounded;
      case 'Cash Out':
        return Icons.north_east_rounded;
      case 'Send Money':
        return Icons.send_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Transactions', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              TextButton(
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.reports),
                child: const Text('See all →'),
              ),
            ],
          ),
          ...transactions.map((t) {
            final isCredit = t.amount.startsWith('+');
            return InkWell(
              onTap: () => Navigator.of(context).pushNamed('/txndetail'),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: t.ok ? c.greenLight : c.goldLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Icon(_iconFor(t.type), size: 18, color: c.slate),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          Text('${t.type} · ${t.provider} · ${t.time}', style: TextStyle(fontSize: 11, color: c.muted)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(t.amount, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: isCredit ? c.green : c.charcoal)),
                        AppBadge(label: t.ok ? 'Done' : 'Pending', color: t.ok ? c.green : c.goldDark),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
