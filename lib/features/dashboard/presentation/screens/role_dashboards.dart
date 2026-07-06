import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/app_providers.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../float/data/float_providers.dart';
import '../../../commission/data/commission_providers.dart';
import '../../../commission/domain/commission_models.dart';
import '../../../branches/domain/branch_models.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';

// ══════════════════════════════════════════════════════════════════════
// MANAGER DASHBOARD
// ══════════════════════════════════════════════════════════════════════

/// Port of the prototype's ManagerDashboard.
/// Shows branch-level stats, pending eCash approvals, agent activity,
/// and quick-action shortcuts for a Manager.
class ManagerDashboard extends ConsumerWidget {
  const ManagerDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final userName = ref.watch(currentUserNameProvider);
    final notifCount = ref.watch(notificationsProvider.select((n) => n.where((x) => !x.isRead).length));

    return Scaffold(
      backgroundColor: c.surface,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 28),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [c.blue, const Color(0xFF1D4ED8)]),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Good morning', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7))),
                    Text(userName, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: Colors.white)),
                    const SizedBox(height: 6),
                    Row(children: [
                      AppBadge(label: 'Manager', color: Colors.white, backgroundColor: Colors.white.withOpacity(0.2)),
                      const SizedBox(width: 6),
                      AppBadge(label: 'Accra Central', color: Colors.white, backgroundColor: Colors.white.withOpacity(0.15)),
                    ]),
                  ])),
                  Stack(children: [
                    _HeaderIconButton(icon: Icons.notifications_rounded, onTap: () => Navigator.of(context).pushNamed(AppRoutes.notifications)),
                    if (notifCount > 0) Positioned(top: 0, right: 0, child: Container(
                      width: 16, height: 16,
                      decoration: BoxDecoration(color: c.red, shape: BoxShape.circle, border: Border.all(color: const Color(0xFF1D4ED8), width: 2)),
                      alignment: Alignment.center,
                      child: Text('$notifCount', style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w800)),
                    )),
                  ]),
                ]),
              ]),
            ),

            Padding(
              padding: const EdgeInsets.all(13),
              child: Column(children: [
                // Today summary
                Row(children: [
                  Expanded(child: _StatCard(label: "TODAY'S VOLUME", value: 'GH₵ 42,600', sub: '2 branches active', color: c.blue)),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(label: 'TOTAL AGENTS', value: '7', sub: '6 active now', color: c.gold)),
                ]),
                const SizedBox(height: 12),

                // Branch overview
                AppCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Branch Performance', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                      TextButton(onPressed: () => Navigator.of(context).pushNamed('/branches'), child: const Text('Manage →')),
                    ]),
                    ...Branch.demoList().take(2).map((b) => Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(border: Border(top: BorderSide(color: c.border))),
                      child: Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(b.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          Text('${b.agentCount} agents · GH₵ ${(b.totalFloat / 1000).toStringAsFixed(1)}k float', style: TextStyle(fontSize: 11, color: c.muted)),
                        ])),
                        AppBadge(label: b.isActive ? 'Active' : 'Inactive', color: b.isActive ? c.green : c.muted),
                      ]),
                    )),
                  ]),
                ),
                const SizedBox(height: 12),

                // Pending eCash approvals
                AccentCard(
                  accentColor: c.gold,
                  backgroundColor: c.goldLight,
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('✅ eCash Approvals', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: c.goldDark)),
                      Text('2 requests pending your approval', style: TextStyle(fontSize: 12, color: c.slate)),
                    ]),
                    AppButton(label: 'Review →', variant: AppButtonVariant.gold, onPressed: () => Navigator.of(context).pushNamed('/ecashapprovals'),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
                  ]),
                ),
                const SizedBox(height: 12),

                // Quick actions
                AppCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    const SizedBox(height: 12),
                    Row(children: [
                      _QuickAction(icon: Icons.bar_chart_rounded, label: 'Float', color: c.blue, onTap: () => Navigator.of(context).pushNamed(AppRoutes.float)),
                      _QuickAction(icon: Icons.monetization_on_rounded, label: 'Commission', color: c.gold, onTap: () => Navigator.of(context).pushNamed(AppRoutes.commission)),
                      _QuickAction(icon: Icons.people_rounded, label: 'Staff', color: c.green, onTap: () => Navigator.of(context).pushNamed('/branches')),
                      _QuickAction(icon: Icons.assessment_rounded, label: 'Reports', color: c.slate, onTap: () => Navigator.of(context).pushNamed(AppRoutes.reports)),
                    ]),
                  ]),
                ),
                const SizedBox(height: 12),

                // Top agents today
                AppCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Top Agents Today', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                      TextButton(onPressed: () => Navigator.of(context).pushNamed(AppRoutes.commission), child: const Text('Leaderboard →')),
                    ]),
                    ...StaffMember.demoList().take(3).map((s) => Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(border: Border(top: BorderSide(color: c.border))),
                      child: Row(children: [
                        Container(width: 36, height: 36, decoration: BoxDecoration(color: c.greenLight, borderRadius: BorderRadius.circular(10)), alignment: Alignment.center,
                          child: Text(s.initials, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: c.green))),
                        const SizedBox(width: 10),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(s.fullName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          Text('${s.todayTransactions} txns', style: TextStyle(fontSize: 11, color: c.muted)),
                        ])),
                        Text('GH₵ ${s.todayCommission.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: c.gold)),
                      ]),
                    )),
                  ]),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// OWNER DASHBOARD
// ══════════════════════════════════════════════════════════════════════

/// Port of the prototype's OwnerDashboard.
/// Business-level P&L: all-branch float, monthly revenue, top branch,
/// subscription status, and business management shortcuts.
class OwnerDashboard extends ConsumerWidget {
  const OwnerDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final balances = ref.watch(floatBalancesProvider);
    final totalFloat = balances.fold<double>(0, (a, b) => a + b.balance);
    final summary = ref.watch(commissionSummaryProvider(CommissionPeriod.month));
    final notifCount = ref.watch(notificationsProvider.select((n) => n.where((x) => !x.isRead).length));

    return Scaffold(
      backgroundColor: c.surface,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 28),
              decoration: BoxDecoration(gradient: LinearGradient(colors: [c.greenDark, c.green, c.gold.withOpacity(0.5)])),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Business Owner', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7))),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed('/bizprofile'),
                      child: const Text('GoldCoast MoMo Ltd', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                    ),
                    const SizedBox(height: 6),
                    Row(children: [
                      AppBadge(label: '✓ Verified', color: const Color(0xFF7EFFC5), backgroundColor: const Color(0xFF7EFFC5).withOpacity(0.15)),
                      const SizedBox(width: 6),
                      AppBadge(label: 'Business Plan', color: c.gold, backgroundColor: c.gold.withOpacity(0.2)),
                    ]),
                  ])),
                  Stack(children: [
                    _HeaderIconButton(icon: Icons.notifications_rounded, onTap: () => Navigator.of(context).pushNamed(AppRoutes.notifications)),
                    if (notifCount > 0) Positioned(top: 0, right: 0, child: Container(
                      width: 16, height: 16,
                      decoration: BoxDecoration(color: c.red, shape: BoxShape.circle, border: Border.all(color: c.green, width: 2)),
                      alignment: Alignment.center,
                      child: Text('$notifCount', style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w800)),
                    )),
                  ]),
                ]),
                const SizedBox(height: 16),
                // Revenue + Float summary
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.13), borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    _RevStat('MONTHLY REVENUE', 'GH₵ 248,600'),
                    _DividerV(),
                    _RevStat('TOTAL FLOAT', 'GH₵ ${totalFloat.toStringAsFixed(0)}'),
                    _DividerV(),
                    _RevStat('COMMISSION', 'GH₵ ${summary.total.toStringAsFixed(0)}', gold: true),
                  ]),
                ),
              ]),
            ),

            Padding(
              padding: const EdgeInsets.all(13),
              child: Column(children: [
                // KPI row
                Row(children: [
                  Expanded(child: _StatCard(label: 'BRANCHES', value: '4', sub: '3 active', color: c.blue)),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(label: 'AGENTS', value: '14', sub: '12 active', color: c.green)),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(label: "MTH TXN'S", value: '482', sub: '+12%', color: c.gold)),
                ]),
                const SizedBox(height: 12),

                // Branch comparison
                AppCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Branch Performance', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                      TextButton(onPressed: () => Navigator.of(context).pushNamed('/floatcomparison'), child: const Text('Compare →')),
                    ]),
                    // Mini bar chart
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 60,
                      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        _OwnBranchBar('Accra', 0.88, c.green),
                        _OwnBranchBar('Kumasi', 0.68, c.blue),
                        _OwnBranchBar('Tema', 0.42, c.gold),
                        _OwnBranchBar('Takdi', 0.28, c.muted),
                      ]),
                    ),
                    const SizedBox(height: 10),
                    ...Branch.demoList().map((b) => Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(border: Border(top: BorderSide(color: c.border))),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(b.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          Text('${b.agentCount} agents', style: TextStyle(fontSize: 11, color: c.muted)),
                        ]),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text('GH₵ ${(b.totalFloat / 1000).toStringAsFixed(1)}k float', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                          AppBadge(label: b.isActive ? 'Active' : 'Inactive', color: b.isActive ? c.green : c.muted),
                        ]),
                      ]),
                    )),
                  ]),
                ),
                const SizedBox(height: 12),

                // Subscription status
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [c.green, c.greenDark]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(children: [
                    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('SUBSCRIPTION', style: TextStyle(fontSize: 11, color: Colors.white70)),
                      Text('Business Plan · GH₵ 10/mo', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white)),
                      Text('Renews Aug 15, 2026 · 50 days left', style: TextStyle(fontSize: 12, color: Colors.white70)),
                    ])),
                    AppButton(label: 'Manage', variant: AppButtonVariant.ghost,
                      onPressed: () => Navigator.of(context).pushNamed(AppRoutes.subscriptions),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                  ]),
                ),
                const SizedBox(height: 12),

                // Management quick actions
                AppCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Business Management', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 0.9,
                      children: [
                        _QuickAction(icon: Icons.account_tree_rounded, label: 'Branches', color: c.blue, onTap: () => Navigator.of(context).pushNamed('/branches')),
                        _QuickAction(icon: Icons.people_alt_rounded, label: 'Staff', color: c.green, onTap: () => Navigator.of(context).pushNamed('/branches')),
                        _QuickAction(icon: Icons.bar_chart_rounded, label: 'Reports', color: c.gold, onTap: () => Navigator.of(context).pushNamed(AppRoutes.reports)),
                        _QuickAction(icon: Icons.business_rounded, label: 'Profile', color: c.slate, onTap: () => Navigator.of(context).pushNamed('/bizprofile')),
                        _QuickAction(icon: Icons.account_balance_wallet_rounded, label: 'Float', color: c.blue, onTap: () => Navigator.of(context).pushNamed(AppRoutes.float)),
                        _QuickAction(icon: Icons.payments_rounded, label: 'Commission', color: c.gold, onTap: () => Navigator.of(context).pushNamed(AppRoutes.commission)),
                        _QuickAction(icon: Icons.storefront_rounded, label: 'Market', color: c.purple, onTap: () => Navigator.of(context).pushNamed(AppRoutes.market)),
                        _QuickAction(icon: Icons.smart_toy_rounded, label: 'AI Help', color: c.green, onTap: () => Navigator.of(context).pushNamed(AppRoutes.ai)),
                      ],
                    ),
                  ]),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevStat extends StatelessWidget {
  final String label;
  final String value;
  final bool gold;
  const _RevStat(this.label, this.value, {this.gold = false});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(children: [
          Text(label, style: const TextStyle(fontSize: 9, color: Colors.white60, fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: gold ? const Color(0xFFFDE68A) : Colors.white), textAlign: TextAlign.center),
        ]),
      );
}

class _DividerV extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 36, color: Colors.white.withOpacity(0.2), margin: const EdgeInsets.symmetric(horizontal: 8));
}

class _OwnBranchBar extends StatelessWidget {
  final String label;
  final double ratio;
  final Color color;
  const _OwnBranchBar(this.label, this.ratio, this.color);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Expanded(child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        Container(height: (ratio * 50).clamp(4, 50), decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(fontSize: 9, color: c.muted, fontWeight: FontWeight.w700)),
      ]),
    ));
  }
}

// ── Shared sub-widgets ───────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.sub, required this.color});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 10, color: c.muted, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
        Text(sub, style: TextStyle(fontSize: 10, color: c.muted)),
      ]),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 42, height: 42,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
          alignment: Alignment.center,
          child: Icon(icon, size: 20, color: Colors.white),
        ),
      );
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.border), borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c.slate)),
        ]),
      ),
    );
  }
}
