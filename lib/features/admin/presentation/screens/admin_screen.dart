import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../branches/domain/branch_models.dart';

// ── Demo state ────────────────────────────────────────────────────────
class _BusinessRecord {
  final String id;
  final String name;
  final String owner;
  final String region;
  final String plan;
  String status; // 'active' | 'suspended' | 'pending'
  final int agentCount;
  final DateTime createdAt;

  _BusinessRecord({required this.id, required this.name, required this.owner, required this.region, required this.plan, required this.status, required this.agentCount, required this.createdAt});
}

class _PendingAd {
  final String id;
  final String title;
  final String seller;
  final String category;
  final String value;
  final String fee;
  final bool flagged;
  String status;

  _PendingAd({required this.id, required this.title, required this.seller, required this.category, required this.value, required this.fee, this.flagged = false, this.status = 'pending'});
}

final _adminBusinessesProvider = StateProvider<List<_BusinessRecord>>((_) => [
  _BusinessRecord(id: '1', name: 'GoldCoast MoMo Ltd', owner: 'Kwame Asante Snr.', region: 'Greater Accra', plan: 'Business', status: 'active', agentCount: 14, createdAt: DateTime(2025, 1)),
  _BusinessRecord(id: '2', name: 'Ashanti MoMo Agency', owner: 'Ama Osei', region: 'Ashanti', plan: 'Business', status: 'active', agentCount: 8, createdAt: DateTime(2025, 2)),
  _BusinessRecord(id: '3', name: 'Western Float Hub', owner: 'Kofi Boateng', region: 'Western', plan: 'Business', status: 'suspended', agentCount: 3, createdAt: DateTime(2025, 4)),
  _BusinessRecord(id: '4', name: 'Volta MoMo Services', owner: 'Akua Darko', region: 'Volta', plan: 'Free', status: 'pending', agentCount: 0, createdAt: DateTime(2025, 6)),
]);

final _adminPendingAdsProvider = StateProvider<List<_PendingAd>>((_) => [
  _PendingAd(id: '1', title: 'Toyota Camry 2019', seller: 'Kwabena D.', category: 'Vehicles', value: 'GH₵ 85,000', fee: 'GH₵ 850', flagged: false),
  _PendingAd(id: '2', title: 'iPhone 15 Pro Max', seller: 'Ama S.', category: 'Phones', value: 'GH₵ 9,500', fee: 'GH₵ 95', flagged: false),
  _PendingAd(id: '3', title: 'Office Space Rental', seller: 'GoldCoast Props', category: 'Real Estate', value: 'GH₵ 3,500/mo', fee: 'GH₵ 35', flagged: true),
]);

// ── Admin Screen ───────────────────────────────────────────────────────
class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  String _tab = 'Dashboard';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final businesses = ref.watch(_adminBusinessesProvider);
    final pendingAds = ref.watch(_adminPendingAdsProvider);
    final pendingBiz = businesses.where((b) => b.status == 'pending').length;
    final pendingAdCount = pendingAds.where((a) => a.status == 'pending').length;

    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppTopBar(
        title: 'Admin Portal',
        trailing: AppBadge(label: 'Superuser', color: c.gold),
      ),
      body: Column(children: [
        AppTabs(
          tabs: [
            'Dashboard',
            'Companies',
            'Ads ${pendingAdCount > 0 ? "($pendingAdCount)" : ""}',
            'Config',
          ],
          active: _tab,
          onChanged: (t) => setState(() => _tab = t.split(' ').first),
        ),
        Expanded(child: switch (_tab) {
          'Companies' => _CompaniesTab(),
          'Ads' => _AdModerationTab(),
          'Config' => const _ConfigTab(),
          _ => const _DashboardTab(),
        }),
      ]),
    );
  }
}

// ── Dashboard tab ─────────────────────────────────────────────────────
class _DashboardTab extends ConsumerStatefulWidget {
  const _DashboardTab();

  @override
  ConsumerState<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends ConsumerState<_DashboardTab> {
  String _period = 'Month';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final businesses = ref.watch(_adminBusinessesProvider);

    final barData = [40, 52, 48, 60, 72, 68, 80, 76, 88, 84, 95, 100];
    final maxBar = barData.reduce((a, b) => a > b ? a : b).toDouble();

    return ListView(padding: const EdgeInsets.all(13), children: [
      // Period selector
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(children: ['Week', 'Month', 'Quarter', 'Year'].map((p) {
          final sel = _period == p;
          return Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: InkWell(
              onTap: () => setState(() => _period = p),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: sel ? c.greenLight : Colors.transparent,
                  border: Border.all(color: sel ? c.green : c.border, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(p, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: sel ? c.green : c.muted)),
              ),
            ),
          ));
        }).toList()),
      ),
      const SizedBox(height: 12),

      // MRR card
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [c.charcoal, const Color(0xFF2D2D3A)]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('PLATFORM MRR', style: TextStyle(fontSize: 11, color: Colors.white60)),
          const SizedBox(height: 4),
          Text('GH₵ 1,420', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: c.gold)),
          const SizedBox(height: 12),
          Row(children: [
            _HeroStat('BUSINESSES', '${businesses.length}'),
            _HeroStat('ACTIVE', '${businesses.where((b) => b.status == 'active').length}', green: true),
            _HeroStat('PENDING', '${businesses.where((b) => b.status == 'pending').length}', red: true),
            _HeroStat('USERS', '1,204'),
          ]),
        ]),
      ),
      const SizedBox(height: 12),

      // KPI row
      Row(children: [
        Expanded(child: _KpiCard(label: 'TRANSACTIONS', value: '24.8K', sub: 'This month', color: c.green)),
        const SizedBox(width: 10),
        Expanded(child: _KpiCard(label: 'AD REVENUE', value: 'GH₵ 8,400', sub: 'Active ads: 38', color: c.gold)),
        const SizedBox(width: 10),
        Expanded(child: _KpiCard(label: 'CHURN', value: '4', sub: 'This month', color: c.red)),
      ]),
      const SizedBox(height: 12),

      // MRR chart
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('MRR Trend (12 months)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
        const SizedBox(height: 14),
        SizedBox(
          height: 80,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: barData.asMap().entries.map((e) {
              final isLast = e.key == barData.length - 1;
              return Expanded(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Container(
                  height: ((e.value / maxBar) * 70).clamp(4, 70),
                  decoration: BoxDecoration(
                    color: isLast ? c.gold : c.green.withOpacity(0.55),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ),
              ));
            }).toList(),
          ),
        ),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Jan 2026', style: TextStyle(fontSize: 10, color: c.muted)),
          Text('Now', style: TextStyle(fontSize: 10, color: c.gold, fontWeight: FontWeight.w700)),
        ]),
      ])),
      const SizedBox(height: 12),

      // Regional breakdown
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Businesses by Region', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
        const SizedBox(height: 12),
        ...[('Greater Accra', 68, 48), ('Ashanti', 32, 23), ('Western', 18, 13), ('Central', 14, 10), ('Others', 10, 7)].map((r) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(r.$1, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Text('${r.$2} (${r.$3}%)', style: TextStyle(fontSize: 12, color: c.muted)),
            ]),
            const SizedBox(height: 4),
            ClipRRect(borderRadius: BorderRadius.circular(100), child: LinearProgressIndicator(value: r.$3 / 100, minHeight: 5, backgroundColor: c.border, color: c.blue)),
          ]),
        )),
      ])),
      const SizedBox(height: 12),

      // Quick actions
      Row(children: [
        Expanded(child: AppButton(label: '➕ Create Owner', onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateOwnerScreen())))),
        const SizedBox(width: 10),
        Expanded(child: AppButton(label: '📄 Export', variant: AppButtonVariant.outline, onPressed: () {})),
      ]),
    ]);
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final bool green;
  final bool red;
  const _HeroStat(this.label, this.value, {this.green = false, this.red = false});

  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(label, style: const TextStyle(fontSize: 9, color: Colors.white60)),
    Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: green ? const Color(0xFF7EFFC5) : red ? const Color(0xFFFF9999) : Colors.white)),
  ]));
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color color;
  const _KpiCard({required this.label, required this.value, required this.sub, required this.color});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: c.muted)),
      const SizedBox(height: 2),
      Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
      Text(sub, style: TextStyle(fontSize: 10, color: c.muted)),
    ]));
  }
}

// ── Companies tab ─────────────────────────────────────────────────────
class _CompaniesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final businesses = ref.watch(_adminBusinessesProvider);

    return ListView(padding: const EdgeInsets.all(13), children: [
      Row(children: [
        Expanded(child: AppButton(label: '➕ Create Business Owner', onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateOwnerScreen())))),
      ]),
      const SizedBox(height: 12),
      ...businesses.map((b) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(b.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              Text('Owner: ${b.owner}  ·  ${b.region}', style: TextStyle(fontSize: 12, color: c.muted)),
              Text('${b.agentCount} agents  ·  ${b.plan} Plan  ·  Since ${DateFormat('MMM yyyy').format(b.createdAt)}', style: TextStyle(fontSize: 11, color: c.muted)),
            ])),
            AppBadge(
              label: b.status[0].toUpperCase() + b.status.substring(1),
              color: b.status == 'active' ? c.green : b.status == 'pending' ? c.gold : c.red,
            ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: AppButton(label: 'View', variant: AppButtonVariant.ghost, onPressed: () {}, padding: const EdgeInsets.symmetric(vertical: 8))),
            const SizedBox(width: 8),
            Expanded(child: AppButton(
              label: b.status == 'active' ? 'Suspend' : b.status == 'pending' ? 'Approve' : 'Activate',
              variant: b.status == 'active' ? AppButtonVariant.danger : AppButtonVariant.primary,
              padding: const EdgeInsets.symmetric(vertical: 8),
              onPressed: () {
                ref.read(_adminBusinessesProvider.notifier).update((list) => list.map((biz) {
                  if (biz.id == b.id) {
                    biz.status = b.status == 'active' ? 'suspended' : 'active';
                  }
                  return biz;
                }).toList());
              },
            )),
          ]),
        ])),
      )),
    ]);
  }
}

// ── Ad Moderation tab ─────────────────────────────────────────────────
class _AdModerationTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final ads = ref.watch(_adminPendingAdsProvider);
    final pending = ads.where((a) => a.status == 'pending').toList();
    final reviewed = ads.where((a) => a.status != 'pending').toList();

    void act(String id, String action) {
      ref.read(_adminPendingAdsProvider.notifier).update(
        (list) => list.map((a) => a.id == id ? (_PendingAd(id: a.id, title: a.title, seller: a.seller, category: a.category, value: a.value, fee: a.fee, flagged: a.flagged, status: action))).toList(),
      );
    }

    return ListView(padding: const EdgeInsets.all(13), children: [
      Row(children: [
        _AModStat('Pending', pending.length, c.gold, c),
        const SizedBox(width: 10),
        _AModStat('Approved', ads.where((a) => a.status == 'approved').length, c.green, c),
        const SizedBox(width: 10),
        _AModStat('Rejected', ads.where((a) => a.status == 'rejected').length, c.red, c),
      ]),
      const SizedBox(height: 12),
      if (pending.isNotEmpty) ...[
        Text('AWAITING REVIEW', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: c.muted)),
        const SizedBox(height: 8),
        ...pending.map((ad) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AccentCard(
            accentColor: ad.flagged ? c.red : c.gold,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(ad.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  Text('${ad.seller}  ·  ${ad.category}  ·  Fee: ${ad.fee}', style: TextStyle(fontSize: 12, color: c.muted)),
                  Text(ad.value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: c.green)),
                ])),
                if (ad.flagged) AppBadge(label: '🚩 Flagged', color: c.red),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: AppButton(label: '✓ Approve', onPressed: () => act(ad.id, 'approved'), padding: const EdgeInsets.symmetric(vertical: 8))),
                const SizedBox(width: 8),
                Expanded(child: AppButton(label: '✕ Reject', variant: AppButtonVariant.danger, onPressed: () => act(ad.id, 'rejected'), padding: const EdgeInsets.symmetric(vertical: 8))),
                const SizedBox(width: 8),
                Expanded(child: AppButton(label: '🚩 Flag', variant: AppButtonVariant.ghost, onPressed: () => act(ad.id, 'flagged'), padding: const EdgeInsets.symmetric(vertical: 8))),
              ]),
            ]),
          ),
        )),
      ],
      if (reviewed.isNotEmpty) ...[
        Text('RECENTLY REVIEWED', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: c.muted)),
        const SizedBox(height: 8),
        ...reviewed.map((ad) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AppCard(child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(ad.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              Text('${ad.seller}  ·  ${ad.category}', style: TextStyle(fontSize: 11, color: c.muted)),
            ])),
            AppBadge(label: ad.status[0].toUpperCase() + ad.status.substring(1), color: ad.status == 'approved' ? c.green : c.red),
          ])),
        )),
      ],
    ]);
  }
}

Widget _AModStat(String label, int value, Color color, AppColors c) => Expanded(
  child: AppCard(padding: const EdgeInsets.all(12), child: Column(children: [
    Text('$value', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: color)),
    Text(label, style: TextStyle(fontSize: 11, color: c.muted)),
  ])),
);

// ── Config tab ─────────────────────────────────────────────────────────
class _ConfigTab extends ConsumerStatefulWidget {
  const _ConfigTab();

  @override
  ConsumerState<_ConfigTab> createState() => _ConfigTabState();
}

class _ConfigTabState extends ConsumerState<_ConfigTab> {
  final _subPriceCtrl = TextEditingController(text: '10.00');
  final _adFeeCtrl = TextEditingController(text: '1');
  final _gracePeriodCtrl = TextEditingController(text: '7');
  bool _saved = false;

  @override
  void dispose() { _subPriceCtrl.dispose(); _adFeeCtrl.dispose(); _gracePeriodCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListView(padding: const EdgeInsets.all(13), children: [
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Platform Pricing', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
        const SizedBox(height: 12),
        AppTextField(label: 'BUSINESS PLAN PRICE (GH₵/month)', controller: _subPriceCtrl, keyboardType: TextInputType.number, onChanged: (_) => setState(() {})),
        const SizedBox(height: 12),
        AppTextField(label: 'AD LISTING FEE (% of ad value)', controller: _adFeeCtrl, keyboardType: TextInputType.number, onChanged: (_) => setState(() {})),
        const SizedBox(height: 12),
        AppTextField(label: 'SUBSCRIPTION GRACE PERIOD (days)', controller: _gracePeriodCtrl, keyboardType: TextInputType.number, onChanged: (_) => setState(() {})),
      ])),
      const SizedBox(height: 12),
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Platform Modules', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
        const SizedBox(height: 10),
        ...[
          ('Market Centre', true),
          ('eCash Transfers', true),
          ('AI Assistant', true),
          ('USSD Navigator', true),
          ('Fraud Monitoring', true),
        ].map((item) => Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.border))),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            Switch(value: item.$2, onChanged: (_) {}, activeColor: c.green),
          ]),
        )),
      ])),
      const SizedBox(height: 12),
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Quick Links', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
        const SizedBox(height: 8),
        ...[
          ('📈 Platform Analytics', '/platformanalytics'),
          ('🤖 AI Knowledge Base', '/aiknowledge'),
          ('➕ Create Business Owner', null),
        ].map((item) => InkWell(
          onTap: item.$2 != null
              ? () => Navigator.of(context).pushNamed(item.$2!)
              : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateOwnerScreen())),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.border))),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              Icon(Icons.chevron_right, color: c.muted),
            ]),
          ),
        )),
      ])),
      const SizedBox(height: 12),
      if (_saved) ...[
        AppCard(backgroundColor: c.greenLight, borderColor: c.green.withOpacity(0.3),
          child: Center(child: Text('✅ Configuration saved', style: TextStyle(fontWeight: FontWeight.w700, color: c.green)))),
        const SizedBox(height: 12),
      ],
      AppButton(label: 'Save Configuration', width: double.infinity, onPressed: () {
        setState(() => _saved = true);
        Future.delayed(const Duration(seconds: 3), () { if (mounted) setState(() => _saved = false); });
      }),
    ]);
  }
}

// ── Create Business Owner screen ──────────────────────────────────────
class CreateOwnerScreen extends ConsumerStatefulWidget {
  const CreateOwnerScreen({super.key});

  @override
  ConsumerState<CreateOwnerScreen> createState() => _CreateOwnerScreenState();
}

class _CreateOwnerScreenState extends ConsumerState<CreateOwnerScreen> {
  int _step = 1;
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _bizNameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String _region = 'Greater Accra';
  String _plan = 'Business';
  bool _done = false;

  static const _regions = ['Greater Accra','Ashanti','Western','Central','Eastern','Volta','Northern','Upper East','Upper West','Bono'];

  @override
  void dispose() { _nameCtrl.dispose(); _phoneCtrl.dispose(); _emailCtrl.dispose(); _bizNameCtrl.dispose(); _addressCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    if (_done) return Scaffold(
      backgroundColor: c.surface,
      body: Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('✅', style: TextStyle(fontSize: 72)),
        const SizedBox(height: 16),
        Text('Business Owner Created!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: c.green)),
        const SizedBox(height: 8),
        Text('${_nameCtrl.text} registered as owner of ${_bizNameCtrl.text}.\nCredentials sent via SMS to ${_phoneCtrl.text}.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: c.muted, height: 1.6)),
        const SizedBox(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          AppButton(label: 'Add Another', variant: AppButtonVariant.outline, onPressed: () => setState(() { _done = false; _step = 1; _nameCtrl.clear(); _phoneCtrl.clear(); _bizNameCtrl.clear(); })),
          const SizedBox(width: 10),
          AppButton(label: 'Back to Admin', onPressed: () => Navigator.of(context).pop()),
        ]),
      ]))),
    );

    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppTopBar(
        title: 'Create Business Owner',
        onBack: _step > 1 ? () => setState(() => _step--) : () => Navigator.of(context).pop(),
      ),
      body: Column(children: [
        // Step progress
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          color: c.white,
          child: Row(children: ['Owner Info', 'Business', 'Plan & Access'].asMap().entries.map((e) => Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Column(children: [
              Container(height: 4, decoration: BoxDecoration(color: _step > e.key ? c.green : c.border, borderRadius: BorderRadius.circular(100))),
              const SizedBox(height: 3),
              Text(e.value, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: _step > e.key ? c.green : c.muted)),
            ]),
          ))).toList()),
        ),
        Expanded(
          child: ListView(padding: const EdgeInsets.all(14), children: [
            if (_step == 1) AppCard(child: Column(children: [
              AppTextField(label: 'FULL NAME', controller: _nameCtrl, placeholder: 'Business owner full name', onChanged: (_) => setState(() {})),
              const SizedBox(height: 12),
              AppTextField(label: 'PHONE NUMBER', controller: _phoneCtrl, placeholder: '024 XXX XXXX', keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              AppTextField(label: 'EMAIL', controller: _emailCtrl, placeholder: 'owner@business.com'),
              const SizedBox(height: 12),
              AppTextField(label: 'GHANA CARD NUMBER', controller: TextEditingController(), placeholder: 'GHA-XXXXXXXXX-X'),
            ])),
            if (_step == 2) AppCard(child: Column(children: [
              AppTextField(label: 'BUSINESS NAME', controller: _bizNameCtrl, placeholder: 'e.g. GoldCoast MoMo Ltd', onChanged: (_) => setState(() {})),
              const SizedBox(height: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('REGION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.slate, letterSpacing: 0.5)),
                const SizedBox(height: 5),
                Container(
                  decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(11), border: Border.all(color: c.border, width: 1.5)),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(child: DropdownButton<String>(
                    value: _region, isExpanded: true,
                    items: _regions.map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 14)))).toList(),
                    onChanged: (r) => setState(() => _region = r!),
                  )),
                ),
              ]),
              const SizedBox(height: 12),
              AppTextField(label: 'BUSINESS ADDRESS', controller: _addressCtrl, placeholder: 'Street, City'),
            ])),
            if (_step == 3) Column(children: [
              AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Subscription Plan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                const SizedBox(height: 10),
                ...['Free', 'Business'].map((p) => RadioListTile<String>(
                  value: p, groupValue: _plan, onChanged: (v) => setState(() => _plan = v!),
                  title: Text('$p Plan${p == 'Business' ? ' · GH₵ 10/mo' : ' · GH₵ 0'}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  activeColor: c.green, contentPadding: EdgeInsets.zero,
                )),
              ])),
              const SizedBox(height: 12),
              AppCard(backgroundColor: c.goldLight, borderColor: c.gold.withOpacity(0.4), child: Text('A temporary password will be sent to ${_phoneCtrl.text.isEmpty ? 'their phone' : _phoneCtrl.text} via SMS. They must change it on first login.', style: TextStyle(fontSize: 12, color: c.goldDark, height: 1.6))),
            ]),
            const SizedBox(height: 16),
            AppButton(
              label: _step == 3 ? 'Create Business Owner ✓' : 'Continue →',
              width: double.infinity,
              onPressed: (_step == 1 && _nameCtrl.text.isEmpty) || (_step == 2 && _bizNameCtrl.text.isEmpty)
                  ? null
                  : () {
                      if (_step < 3) setState(() => _step++);
                      else {
                        ref.read(_adminBusinessesProvider.notifier).update((list) => [
                          ...list,
                          _BusinessRecord(id: DateTime.now().millisecondsSinceEpoch.toString(), name: _bizNameCtrl.text, owner: _nameCtrl.text, region: _region, plan: _plan, status: 'active', agentCount: 0, createdAt: DateTime.now()),
                        ]);
                        setState(() => _done = true);
                      }
                    },
            ),
          ]),
        ),
      ]),
    );
  }
}
