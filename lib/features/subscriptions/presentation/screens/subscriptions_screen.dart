import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_widgets.dart';

enum SubscriptionPlan { free, business }

class SubscriptionState {
  final SubscriptionPlan plan;
  final DateTime? expiresAt;
  final bool active;

  const SubscriptionState({required this.plan, this.expiresAt, this.active = true});

  int get daysLeft => expiresAt != null ? expiresAt!.difference(DateTime.now()).inDays.clamp(0, 999) : 0;
  bool get isExpiringSoon => daysLeft <= 14;
}

final subscriptionProvider = StateProvider<SubscriptionState>((_) => SubscriptionState(
  plan: SubscriptionPlan.business,
  expiresAt: DateTime.now().add(const Duration(days: 50)),
));

final billingHistoryProvider = StateProvider<List<_BillingRecord>>((_) => [
  _BillingRecord(date: DateTime.now().subtract(const Duration(days: 15)), amount: 10, ref: 'SUB-A1B2C3', status: 'Paid'),
  _BillingRecord(date: DateTime.now().subtract(const Duration(days: 46)), amount: 10, ref: 'SUB-D4E5F6', status: 'Paid'),
  _BillingRecord(date: DateTime.now().subtract(const Duration(days: 76)), amount: 10, ref: 'SUB-G7H8I9', status: 'Paid'),
]);

class _BillingRecord {
  final DateTime date;
  final double amount;
  final String ref;
  final String status;
  const _BillingRecord({required this.date, required this.amount, required this.ref, required this.status});
}

class SubscriptionsScreen extends ConsumerStatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  ConsumerState<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen> {
  String _tab = 'My Plan';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final sub = ref.watch(subscriptionProvider);

    return Scaffold(
      backgroundColor: c.surface,
      appBar: const AppTopBar(title: 'Subscription'),
      body: Column(children: [
        AppTabs(tabs: const ['My Plan', 'Upgrade', 'History'], active: _tab, onChanged: (t) => setState(() => _tab = t)),
        Expanded(child: switch (_tab) {
          'Upgrade' => _UpgradeTab(current: sub),
          'History' => const _HistoryTab(),
          _ => _MyPlanTab(sub: sub, onRenew: () => setState(() => _tab = 'Upgrade')),
        }),
      ]),
    );
  }
}

// ── My Plan tab ───────────────────────────────────────────────────────
class _MyPlanTab extends StatelessWidget {
  final SubscriptionState sub;
  final VoidCallback onRenew;
  const _MyPlanTab({required this.sub, required this.onRenew});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final features = [
      'All Mobile Money operations (MTN, Telecel, AT Money)',
      'Interactive USSD Navigator',
      'Multi-branch management',
      'Float management & alerts',
      'Commission tracking & payouts',
      'Full reports & analytics',
      'eCash internal transfers',
      'Market Centre listings',
      'AI Assistant (Claude Sonnet 4.6)',
      'Cloud backup & sync',
      'Staff management & invites',
      'Customer KYC records',
    ];

    return ListView(padding: const EdgeInsets.all(13), children: [
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(gradient: LinearGradient(colors: [c.green, c.greenDark]), borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('CURRENT PLAN', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.8))),
          const SizedBox(height: 4),
          const Text('Business Plan', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
          const Text('GH₵ 10.00 / month', style: TextStyle(fontSize: 16, color: Colors.white70)),
          const SizedBox(height: 12),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
              child: Text(
                sub.isExpiringSoon ? '⚠ Expires in ${sub.daysLeft} days' : '✓ Active · ${sub.daysLeft} days left',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ]),
          if (sub.expiresAt != null) ...[
            const SizedBox(height: 6),
            Text('Renews ${DateFormat('MMM d, yyyy').format(sub.expiresAt!)}', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7))),
          ],
        ]),
      ),
      if (sub.isExpiringSoon) ...[
        const SizedBox(height: 12),
        AccentCard(
          accentColor: c.red,
          backgroundColor: c.redLight,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('⚠ Renew Soon', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: c.red)),
              Text('Renew now to avoid service interruption.', style: TextStyle(fontSize: 12, color: c.slate)),
            ])),
            AppButton(label: 'Renew', variant: AppButtonVariant.primary, onPressed: onRenew, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
          ]),
        ),
      ],
      const SizedBox(height: 14),
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Plan Features', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
        const SizedBox(height: 10),
        ...features.map((f) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            Icon(Icons.check_circle, color: c.green, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(f, style: const TextStyle(fontSize: 13))),
          ]),
        )),
      ])),
      const SizedBox(height: 14),
      AppButton(label: 'Renew Subscription →', width: double.infinity, onPressed: onRenew),
    ]);
  }
}

// ── Upgrade tab ───────────────────────────────────────────────────────
class _UpgradeTab extends StatefulWidget {
  final SubscriptionState current;
  const _UpgradeTab({required this.current});

  @override
  State<_UpgradeTab> createState() => _UpgradeTabState();
}

class _UpgradeTabState extends State<_UpgradeTab> {
  bool _showPayment = false;
  String _provider = 'MTN';
  final _phoneCtrl = TextEditingController(text: '0244 000 000');
  bool _paid = false;
  late final String _ref;

  @override
  void initState() {
    super.initState();
    _ref = 'SUB-${Random().nextInt(900000) + 100000}';
  }

  @override
  void dispose() { _phoneCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (_paid) return _buildSuccess(context, c);

    return ListView(padding: const EdgeInsets.all(13), children: [
      // Plan cards
      if (!_showPayment) ...[
        _PlanCard(
          name: 'Free Plan',
          price: 'GH₵ 0',
          desc: 'Basic access',
          features: const ['Browse Market Centre', 'AI Assistant (limited)', 'Push Notifications'],
          isCurrent: widget.current.plan == SubscriptionPlan.free,
          onSelect: null,
          c: c,
        ),
        const SizedBox(height: 10),
        _PlanCard(
          name: 'Business Plan',
          price: 'GH₵ 10/mo',
          desc: 'Full platform access',
          features: const ['All MoMo operations', 'USSD Navigator', 'Multi-branch & staff', 'Float management', 'Commission tracking', 'All reports & exports', 'eCash transfers', 'Market Centre listings', 'Full AI Assistant', 'Cloud backup'],
          isCurrent: widget.current.plan == SubscriptionPlan.business,
          highlighted: true,
          onSelect: () => setState(() => _showPayment = true),
          c: c,
        ),
      ],
      // Payment form
      if (_showPayment) ...[
        AppCard(
          backgroundColor: c.greenLight,
          borderColor: c.green.withOpacity(0.3),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Business Plan · GH₵ 10.00/month', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            Text('Auto-renews monthly · Cancel anytime', style: TextStyle(fontSize: 12, color: c.muted)),
          ]),
        ),
        const SizedBox(height: 12),
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('PAY VIA MOBILE MONEY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.slate, letterSpacing: 0.5)),
          const SizedBox(height: 10),
          Row(children: ['MTN', 'Telecel', 'AT Money'].map((p) => Expanded(child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => _provider = p),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _provider == p ? c.greenLight : c.white,
                  border: Border.all(color: _provider == p ? c.green : c.border, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(p, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _provider == p ? c.green : c.slate)),
              ),
            ),
          ))).toList()),
          const SizedBox(height: 12),
          AppTextField(label: 'MOBILE MONEY NUMBER', controller: _phoneCtrl, placeholder: '024 XXX XXXX', keyboardType: TextInputType.phone),
        ])),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: AppButton(label: '← Back', variant: AppButtonVariant.ghost, onPressed: () => setState(() => _showPayment = false))),
          const SizedBox(width: 10),
          Expanded(flex: 2, child: AppButton(label: 'Pay GH₵ 10.00 →', onPressed: () => setState(() => _paid = true))),
        ]),
      ],
    ]);
  }

  Widget _buildSuccess(BuildContext context, AppColors c) => Center(
    child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('🎉', style: TextStyle(fontSize: 80)),
      const SizedBox(height: 16),
      Text('Subscription Activated!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: c.green)),
      const SizedBox(height: 8),
      Text('Business Plan · GH₵ 10.00/month', style: TextStyle(fontSize: 14, color: c.muted)),
      const SizedBox(height: 4),
      Text('Ref: $_ref · Expires ${DateFormat('MMM d, yyyy').format(DateTime.now().add(const Duration(days: 30)))}', style: TextStyle(fontSize: 12, color: c.muted)),
      const SizedBox(height: 24),
      AppButton(label: 'View My Plan', onPressed: () => Navigator.of(context).pop()),
    ])),
  );
}

class _PlanCard extends StatelessWidget {
  final String name;
  final String price;
  final String desc;
  final List<String> features;
  final bool isCurrent;
  final bool highlighted;
  final VoidCallback? onSelect;
  final AppColors c;

  const _PlanCard({required this.name, required this.price, required this.desc, required this.features, required this.isCurrent, this.highlighted = false, required this.onSelect, required this.c});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: highlighted ? c.greenLight : c.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: highlighted ? c.green : c.border, width: highlighted ? 2 : 1),
    ),
    padding: const EdgeInsets.all(18),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: highlighted ? c.green : c.charcoal)),
          Text(desc, style: TextStyle(fontSize: 12, color: c.muted)),
        ]),
        Text(price, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: c.green)),
      ]),
      const SizedBox(height: 12),
      ...features.map((f) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: [
          Icon(Icons.check, size: 15, color: highlighted ? c.green : c.muted),
          const SizedBox(width: 6),
          Text(f, style: TextStyle(fontSize: 12, color: highlighted ? c.slate : c.muted)),
        ]),
      )),
      const SizedBox(height: 14),
      isCurrent
          ? Container(padding: const EdgeInsets.symmetric(vertical: 10), alignment: Alignment.center, decoration: BoxDecoration(color: c.border, borderRadius: BorderRadius.circular(12)), child: Text('Current Plan', style: TextStyle(fontWeight: FontWeight.w700, color: c.muted)))
          : AppButton(label: 'Select ${name.split(' ').first} Plan', width: double.infinity, onPressed: onSelect),
    ]),
  );
}

// ── History tab ───────────────────────────────────────────────────────
class _HistoryTab extends ConsumerWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final history = ref.watch(billingHistoryProvider);
    return ListView(padding: const EdgeInsets.all(13), children: [
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Billing History', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
        const SizedBox(height: 10),
        ...history.asMap().entries.map((entry) {
          final h = entry.value;
          final isLast = entry.key == history.length - 1;
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: c.border))),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Business Plan', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                Text(DateFormat('MMM d, yyyy').format(h.date), style: TextStyle(fontSize: 11, color: c.muted)),
                Text(h.ref, style: TextStyle(fontSize: 10, color: c.muted)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('GH₵ ${h.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                AppBadge(label: h.status, color: c.green),
              ]),
            ]),
          );
        }),
      ])),
    ]);
  }
}
