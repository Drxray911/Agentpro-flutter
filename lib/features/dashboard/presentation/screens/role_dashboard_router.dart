import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/app_providers.dart';
import '../../../../shared/models/user_role.dart';
import '../../../auth/data/auth_repository.dart';
import 'dashboard_screen.dart';
import 'role_dashboards.dart';

/// Smart router: watches [resolvedRoleProvider] and renders the correct
/// dashboard variant per spec §3.2.
///
/// Role → screen mapping:
///   agent    → DashboardScreen   (MoMo operations focus)
///   manager  → ManagerDashboard  (branch supervision focus)
///   owner    → OwnerDashboard    (business P&L focus)
///   auditor  → AuditorDashboard  (read-only metrics)
///   superuser→ redirects to /admin
class RoleDashboard extends ConsumerWidget {
  const RoleDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Prefer real auth user role; fall back to demo selector
    final role = ref.watch(resolvedRoleProvider);

    return switch (role) {
      UserRole.agent => const DashboardScreen(),
      UserRole.manager => const ManagerDashboard(),
      UserRole.owner => const OwnerDashboard(),
      UserRole.auditor => const _AuditorDashboard(),
      UserRole.superuser => const _SuperuserRedirect(),
    };
  }
}

// ── Auditor Dashboard (read-only overview) ─────────────────────────────
class _AuditorDashboard extends StatelessWidget {
  const _AuditorDashboard();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    final modules = [
      (icon: Icons.receipt_long_rounded, label: 'Transactions', route: '/reports', count: '482'),
      (icon: Icons.account_balance_wallet_rounded, label: 'Float', route: '/float', count: 'GH₵ 4.8k'),
      (icon: Icons.payments_rounded, label: 'Commission', route: '/commission', count: 'GH₵ 3,740'),
      (icon: Icons.people_rounded, label: 'Agents', route: '/branches', count: '14'),
      (icon: Icons.security_rounded, label: 'Fraud Alerts', route: '/fraud', count: '2'),
      (icon: Icons.history_rounded, label: 'Audit Logs', route: '/audit', count: ''),
      (icon: Icons.assessment_rounded, label: 'Reports', route: '/reports', count: ''),
      (icon: Icons.subscriptions_rounded, label: 'Subscriptions', route: '/subscriptions', count: ''),
      (icon: Icons.campaign_rounded, label: 'Advertisements', route: '/market', count: ''),
    ];

    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppBar(
        backgroundColor: c.charcoal,
        foregroundColor: Colors.white,
        title: const Text('Auditor View', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
            child: const Text('🔍 Read Only', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(13),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: c.charcoal, borderRadius: BorderRadius.circular(16)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('PLATFORM SUMMARY', style: TextStyle(fontSize: 11, color: Colors.white70)),
              const SizedBox(height: 4),
              const Text('GH₵ 248,600', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white)),
              const SizedBox(height: 8),
              Row(children: [
                _AStat('TRANSACTIONS', '482'),
                _AStat('AGENTS', '14'),
                _AStat('BRANCHES', '4'),
                _AStat('COMMISSION', 'GH₵ 3,740', gold: true),
              ]),
            ]),
          ),
          const SizedBox(height: 14),
          const Text('AUDIT MODULES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.9,
            children: modules.map((m) => InkWell(
              onTap: () => Navigator.of(context).pushNamed(m.route),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                decoration: BoxDecoration(color: c.white, border: Border.all(color: c.border), borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(m.icon, size: 24, color: c.slate),
                  const SizedBox(height: 5),
                  Text(m.label, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c.slate)),
                  if (m.count.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(m.count, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: c.green)),
                  ],
                ]),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _AStat extends StatelessWidget {
  final String label;
  final String value;
  final bool gold;
  const _AStat(this.label, this.value, {this.gold = false});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(children: [
          Text(label, style: const TextStyle(fontSize: 9, color: Colors.white60)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: gold ? const Color(0xFFFDE68A) : Colors.white)),
        ]),
      );
}

// ── Superuser redirect ────────────────────────────────────────────────
class _SuperuserRedirect extends StatefulWidget {
  const _SuperuserRedirect();

  @override
  State<_SuperuserRedirect> createState() => _SuperuserRedirectState();
}

class _SuperuserRedirectState extends State<_SuperuserRedirect> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed('/admin');
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
}
